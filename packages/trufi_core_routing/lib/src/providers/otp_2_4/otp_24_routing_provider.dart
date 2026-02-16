import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:gql/language.dart';
import 'package:graphql/client.dart';

import 'graphql_client_factory.dart';
import '../../models/plan.dart';
import '../../models/routing_location.dart';
import '../../models/stop.dart';
import '../../models/transit_route.dart';
import '../routing_provider.dart';
import 'otp_24_preferences.dart';
import 'otp_2_4_pattern_queries.dart' as pattern_queries;
import 'otp_2_4_queries.dart';
import 'otp_2_4_response_parser.dart';

/// Routing provider for OpenTripPlanner 2.4.
///
/// OTP 2.4 uses the standard OTP GraphQL schema with:
/// - plan query with itineraries
/// - Transit route patterns
/// - Real-time data support
///
/// Example:
/// ```dart
/// final provider = Otp24RoutingProvider(
///   endpoint: 'https://otp.example.com',
/// );
/// ```
class Otp24RoutingProvider implements IRoutingProvider {
  /// The OTP endpoint URL.
  ///
  /// Can be the base URL (e.g., "https://example.com/otp") or
  /// the full GraphQL endpoint.
  final String endpoint;

  /// Whether to use simplified GraphQL queries.
  final bool useSimpleQuery;

  /// Custom display name for this provider.
  final String? displayName;

  /// Custom description for this provider.
  final String? displayDescription;

  /// Optional callback to provide extra HTTP headers per plan request.
  final PlanHeaderProvider? planHeaderProvider;

  Otp24RoutingProvider({
    required this.endpoint,
    this.useSimpleQuery = false,
    this.displayName,
    this.displayDescription,
    this.planHeaderProvider,
  });

  late final _prefs = Otp24PreferencesState();

  @override
  String get id => 'otp_2_4';

  @override
  String get name => displayName ?? 'OTP 2.4';

  @override
  String get description =>
      displayDescription ?? 'OpenTripPlanner 2.4 (Online)';

  @override
  bool get supportsTransitRoutes => true;

  @override
  bool get requiresInternet => true;

  @override
  Widget? buildPreferencesUI(BuildContext context) =>
      Otp24Preferences(state: _prefs);

  @override
  void resetPreferences() => _prefs.reset();

  @override
  Future<void> initialize() async {
    await _prefs.initialize();
  }

  late final GraphQLClient _client = GraphQLClientFactory.create(
    _graphqlEndpoint,
  );

  // --- Plan ---

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async {
    final queryString = useSimpleQuery ? otp24SimplePlanQuery : otp24PlanQuery;

    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    final variables = <String, dynamic>{
      'fromPlace': _formatLocation(from),
      'toPlace': _formatLocation(to),
      'numItineraries': numItineraries,
      'date': date,
      'time': time,
      if (arriveBy) 'arriveBy': true,
      if (locale != null) 'locale': locale,
    };

    if (!useSimpleQuery) {
      if (_prefs.wheelchair) {
        variables['wheelchair'] = true;
      }
      variables['walkSpeed'] = _prefs.walkSpeed;
      variables['walkReluctance'] = _prefs.walkReluctance;
      if (_prefs.maxWalkDistance != null) {
        variables['maxWalkDistance'] = _prefs.maxWalkDistance;
      }
      if (_prefs.transportModes.contains(RoutingMode.bicycle)) {
        variables['bikeSpeed'] = _prefs.bikeSpeed;
      }
      variables['transportModes'] = _prefs.transportModes
          .map((m) => {'mode': m.otpName})
          .toList();
    }

    Context? requestContext;
    if (planHeaderProvider != null) {
      final extraHeaders = await planHeaderProvider!(from, to);
      requestContext = Context().withEntry(
        HttpLinkHeaders(headers: extraHeaders),
      );
    }

    final query = QueryOptions(
      document: parseString(queryString),
      variables: variables,
      context: requestContext,
    );

    final result = await _client.query(query);

    if (result.hasException && result.data == null) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
        throw Otp24Exception(
          'Bad request: ${result.exception!.graphqlErrors.first.message}',
        );
      }
      throw Otp24Exception('No internet connection');
    }

    if (result.source?.isEager ?? false) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return Otp24ResponseParser.parsePlan(result.data!);
  }

  // --- Transit routes ---

  @override
  Future<List<TransitRoute>> fetchTransitRoutes() async {
    final options = WatchQueryOptions(
      document: parseString(pattern_queries.allPatterns),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    if (result.hasException && result.data == null) {
      throw result.exception!.graphqlErrors.isNotEmpty
          ? Exception('Bad request')
          : Exception('Connection error');
    }

    final patterns =
        result.data!['patterns']
                ?.map<TransitRoute>(
                  (dynamic json) =>
                      TransitRoute.fromJson(json as Map<String, dynamic>),
                )
                ?.toList()
            as List<TransitRoute>;

    return patterns;
  }

  @override
  Future<TransitRoute?> fetchTransitRouteById(String id) async {
    final options = WatchQueryOptions(
      document: parseString(pattern_queries.patternById),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
      variables: <String, dynamic>{'id': id},
    );

    final result = await _client.query(options);

    if (result.hasException && result.data == null) {
      throw result.exception!.graphqlErrors.isNotEmpty
          ? Exception('Bad request')
          : Exception('Connection error');
    }

    final patternData = TransitRoute.fromJson(
      result.data!['pattern'] as Map<String, dynamic>,
    );

    // For cities that don't use stops like Cochabamba (uses street intersection).
    // Workaround: remove the name of the adjacent stops that are repeated.
    final newListStops = <Stop>[];
    if (patternData.stops != null && patternData.stops!.isNotEmpty) {
      newListStops.add(patternData.stops!.first);
      for (final stop in patternData.stops!) {
        if (stop.name != newListStops.last.name) {
          newListStops.add(stop);
        }
      }
    }

    return patternData.copyWith(stops: newListStops);
  }

  // --- Helpers ---

  String _formatLocation(RoutingLocation location) {
    final name = location.description.isNotEmpty
        ? location.description
        : 'Location';
    return '$name::${location.position.latitude},${location.position.longitude}';
  }

  String get _graphqlEndpoint {
    if (endpoint.contains('/graphql')) {
      return endpoint;
    }
    final base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    return '$base/otp/routers/default/index/graphql';
  }
}

/// Exception thrown by OTP 2.4 operations.
class Otp24Exception implements Exception {
  Otp24Exception(this.message);

  final String message;

  @override
  String toString() => 'Otp24Exception: $message';
}
