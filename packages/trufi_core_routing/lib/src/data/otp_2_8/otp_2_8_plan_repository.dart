import 'package:graphql/client.dart';
import 'package:gql/language.dart';

import '../../domain/entities/plan.dart';
import '../../domain/entities/routing_location.dart';
import '../../domain/entities/routing_preferences.dart';
import '../../domain/repositories/plan_repository.dart';
import '../graphql/graphql_client_factory.dart';
import 'otp_2_8_queries.dart';
import 'otp_2_8_response_parser.dart';

/// Implementation of [PlanRepository] using OpenTripPlanner 2.8 GraphQL API.
///
/// OTP 2.8 uses the standard OTP GraphQL schema with:
/// - `plan` query
/// - `itineraries` with emissions data
/// - Enhanced booking info support
/// - Better real-time support
/// - Location format: "name::lat,lon" string
/// - Times in milliseconds since epoch
class Otp28PlanRepository implements PlanRepository {
  Otp28PlanRepository({
    required String endpoint,
    this.useSimpleQuery = false,
  }) : _client = GraphQLClientFactory.create(endpoint);

  final GraphQLClient _client;

  /// If true, uses the simple query with fewer parameters.
  final bool useSimpleQuery;

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    RoutingPreferences? preferences,
  }) async {
    final queryString =
        useSimpleQuery ? otp28SimplePlanQuery : otp28PlanQuery;

    final date = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    final variables = <String, dynamic>{
      'fromPlace': _formatLocation(from),
      'toPlace': _formatLocation(to),
      'numItineraries': numItineraries,
      'date': date,
      'time': time,
      if (locale != null) 'locale': locale,
    };

    // Add routing preferences if provided and not using simple query
    if (preferences != null && !useSimpleQuery) {
      if (preferences.wheelchair) {
        variables['wheelchair'] = true;
      }
      variables['walkSpeed'] = preferences.walkSpeed;
      variables['walkReluctance'] = preferences.walkReluctance;
      if (preferences.maxWalkDistance != null) {
        variables['maxWalkDistance'] = preferences.maxWalkDistance;
      }
      // Add bike speed if bicycle mode is selected
      if (preferences.transportModes.contains(RoutingMode.bicycle)) {
        variables['bikeSpeed'] = preferences.bikeSpeed;
      }
      // Transport modes
      variables['transportModes'] = preferences.transportModes
          .map((m) => {'mode': m.otpName})
          .toList();
    }

    final query = QueryOptions(
      document: parseString(queryString),
      variables: variables,
    );

    final result = await _client.query(query);

    if (result.hasException && result.data == null) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
        throw Otp28Exception(
          'Bad request: ${result.exception!.graphqlErrors.first.message}',
        );
      }
      throw Otp28Exception('No internet connection');
    }

    // Handle eager cache responses
    if (result.source?.isEager ?? false) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return Otp28ResponseParser.parsePlan(result.data!);
  }

  /// Formats a location for OTP 2.8.
  ///
  /// OTP 2.8 expects location in format: "name::lat,lon"
  String _formatLocation(RoutingLocation location) {
    final name = location.description.isNotEmpty
        ? location.description
        : 'Location';
    return '$name::${location.position.latitude},${location.position.longitude}';
  }
}

/// Exception thrown by OTP 2.8 operations.
class Otp28Exception implements Exception {
  Otp28Exception(this.message);

  final String message;

  @override
  String toString() => 'Otp28Exception: $message';
}
