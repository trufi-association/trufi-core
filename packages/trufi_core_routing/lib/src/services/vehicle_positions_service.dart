import 'dart:async';

import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../providers/otp_2_4/graphql_client_factory.dart';

/// The vehicle-positions query: the whole fleet, or only [routeIds]
/// (OTP `routes(ids: [...])`).
///
/// OTP route ids carry the feed prefix (`1:1185`). When any id comes
/// without it the filter cannot be built, so the query asks for every
/// route and the caller matches feed-agnostically as before (#1017). An
/// empty set yields the fleet query too; [OtpVehiclePositionsProvider.fetchOnce]
/// answers it without a request.
///
/// `routes(ids:)` is `@deprecated` in OTP's GTFS GraphQL schema since 2.6
/// (opentripplanner/OpenTripPlanner#5869: "it will be moved to a separate
/// [resolver]"); 2.9 and 2.10 still answer it and no replacement exists
/// yet. [OtpVehiclePositionsProvider] falls back to the fleet query the
/// day a server drops the argument.
String buildVehiclePositionsQuery({Set<String>? routeIds}) =>
    _vehiclePositionsQuery(_routeIdsFilter(routeIds));

/// The ids the query can filter by, or null when it must ask for the whole
/// fleet: no ids, or one that is not feed-scoped (`feed:route`, both halves
/// non-empty — OTP rejects `1185` with "invalid feed-scoped-id" and `:1185`
/// with "Missing mandatory feedId").
List<String>? _routeIdsFilter(Set<String>? routeIds) {
  final ids = routeIds?.where((id) => id.trim().isNotEmpty).toList();
  if (ids == null || ids.isEmpty || !ids.every(_isFeedScopedId)) return null;
  return ids;
}

bool _isFeedScopedId(String id) {
  final colon = id.indexOf(':');
  return colon > 0 && colon < id.length - 1;
}

String _vehiclePositionsQuery(List<String>? ids) {
  if (ids == null) return _query;
  final literal = ids
      .map((id) => '"${id.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"')
      .join(', ');
  return _query.replaceFirst('routes {', 'routes(ids: [$literal]) {');
}

const _query = '''
{
  routes {
    gtfsId
    color
    patterns {
      code
      vehiclePositions {
        vehicleId
        label
        lat
        lon
        heading
        speed
        lastUpdate
        lastUpdated
        trip { gtfsId }
      }
    }
  }
}
''';

/// Thrown by [OtpVehiclePositionsProvider.fetchOnce] when OTP answers with
/// GraphQL errors or no data. Network failures propagate untouched.
class OtpVehiclePositionsException implements Exception {
  const OtpVehiclePositionsException(this.message);

  final String message;

  @override
  String toString() => 'OtpVehiclePositionsException: $message';
}

/// OTP-backed implementation of [RealtimeVehiclesProvider]. Polls the OTP
/// GraphQL endpoint periodically for GTFS-Realtime vehicle positions.
///
/// ```dart
/// final provider = OtpVehiclePositionsProvider(
///   endpoint: 'https://otp.example.com',
///   pollInterval: Duration(seconds: 10),
/// );
/// await provider.start();
/// ```
class OtpVehiclePositionsProvider implements RealtimeVehiclesProvider {
  OtpVehiclePositionsProvider({
    required this.endpoint,
    this.pollInterval = const Duration(seconds: 10),
    this.requestTimeout = const Duration(seconds: 10),
    @visibleForTesting Link? link,
  }) : _link = link;

  final String endpoint;
  final Duration pollInterval;
  final Duration requestTimeout;

  /// Test seam: the GraphQL client is built over this [Link] instead of the
  /// HTTP one from [GraphQLClientFactory], so a test can capture the
  /// document sent and script OTP's answer.
  final Link? _link;

  final _controller = StreamController<List<VehiclePosition>>.broadcast();
  Timer? _timer;
  GraphQLClient? _client;
  List<VehiclePosition> _latest = const [];

  /// Cleared the first time the server rejects `routes(ids:)` (deprecated
  /// since OTP 2.6, #5869): from then on every snapshot asks for the whole
  /// fleet, like the poller, instead of failing on every plan.
  bool _routeIdsFilterSupported = true;

  @override
  Stream<List<VehiclePosition>> get positionsStream => _controller.stream;

  @override
  List<VehiclePosition> get latest => _latest;

  bool get isRunning => _timer != null;

  @override
  Future<void> start() async {
    if (_timer != null) return;
    debugPrint(
      '[RealtimeVehicles] polling $_graphqlEndpoint every $pollInterval',
    );
    // `??=`: a client created lazily by [fetchOnce] is reused, not orphaned
    // with its open HTTP connection pool.
    _client ??= _createClient();
    await _tick();
    _timer = Timer.periodic(pollInterval, (_) => _tick());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    stop();
    await _controller.close();
    // HttpLink.dispose closes the http.Client it was given.
    await _client?.link.dispose();
    _client = null;
  }

  /// Runs ONE vehicle-positions query without touching the polling timer:
  /// creates the GraphQL client lazily and returns the parsed positions.
  /// Lets on-demand consumers (the ETA badges of #1004) take a fresh
  /// snapshot while the "Live buses" layer is off, with no background
  /// polling.
  ///
  /// With [routeIds] the request asks OTP for those routes only (#1017):
  /// `routes(ids:)` when every id is feed-scoped, the whole fleet when one
  /// is not (see [buildVehiclePositionsQuery]) or when the server rejected
  /// the argument before. A fleet-wide answer updates [latest] and emits on
  /// [positionsStream] like a poll tick does; a filtered one is only
  /// returned: the map layer paints every route of the selected itinerary
  /// from that stream, and a subset there made the buses of the other
  /// routes vanish until the next tick. An empty set is "no route at all":
  /// an empty list, no request.
  ///
  /// Throws [OtpVehiclePositionsException] on GraphQL errors or null data;
  /// network errors propagate untouched. The polling path ([start]) keeps
  /// its swallow-and-log behaviour through [_tick]. Logs `snapshot: N
  /// vehicles`, so a `tick:` line in the log always means the poller.
  Future<List<VehiclePosition>> fetchOnce({Set<String>? routeIds}) async {
    if (routeIds != null && routeIds.isEmpty) return const [];
    final positions = await _fetchPositions(routeIds: routeIds);
    debugPrint('[RealtimeVehicles] snapshot: ${positions.length} vehicles');
    return positions;
  }

  /// The query itself, shared by [fetchOnce] and the poller's [_tick]; the
  /// poller always asks for the whole fleet (it feeds the map layer), an
  /// on-demand snapshot may ask for [routeIds] only. Only a fleet-wide
  /// answer is published on [latest] and [positionsStream].
  Future<List<VehiclePosition>> _fetchPositions({Set<String>? routeIds}) async {
    final client = _client ??= _createClient();
    var filter = _routeIdsFilterSupported ? _routeIdsFilter(routeIds) : null;
    var result = await _runQuery(client, _vehiclePositionsQuery(filter));

    if (filter != null && _isValidationError(result)) {
      // The server no longer takes `routes(ids:)` (deprecated since OTP
      // 2.6, #5869, replacement not published yet): one more round trip for
      // the whole fleet now, and no filter from here on. A dropped argument
      // must not cost every badge of every plan.
      debugPrint(
        '[RealtimeVehicles] routes(ids:) rejected, asking for the whole '
        'fleet from now on: ${result.exception}',
      );
      _routeIdsFilterSupported = false;
      filter = null;
      result = await _runQuery(client, _query);
    }

    if (result.hasException) {
      throw OtpVehiclePositionsException(
        'query exception: ${result.exception}',
      );
    }
    if (result.data == null) {
      throw const OtpVehiclePositionsException('query returned null data');
    }

    final routes = result.data!['routes'] as List<dynamic>? ?? const [];
    final positions = <VehiclePosition>[];

    for (final route in routes) {
      // `routes(ids:)` answers `null` for every id the server does not know
      // (a route gone after a GTFS refresh, another feed's id): skip it,
      // the vehicles of the routes it does know are still the answer.
      if (route == null) continue;
      final routeMap = route as Map<String, dynamic>;
      final routeId = routeMap['gtfsId'] as String?;
      final routeColor = routeMap['color'] as String?;
      final patterns = routeMap['patterns'] as List<dynamic>? ?? const [];
      for (final pattern in patterns) {
        final patternMap = pattern as Map<String, dynamic>;
        final vehicles =
            patternMap['vehiclePositions'] as List<dynamic>? ?? const [];
        for (final v in vehicles) {
          final position = _parseVehicle(
            v as Map<String, dynamic>,
            routeId,
            routeColor,
          );
          if (position != null) positions.add(position);
        }
      }
    }

    if (filter == null) {
      _latest = positions;
      if (!_controller.isClosed) _controller.add(positions);
    }
    return positions;
  }

  Future<QueryResult<Object?>> _runQuery(
    GraphQLClient client,
    String document,
  ) => client.query(
    WatchQueryOptions(
      document: parseString(document),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  /// graphql-java tags a document it refuses (unknown argument, undefined
  /// field) as `ValidationError` in `extensions.classification`, unlike a
  /// `DataFetchingException` raised while resolving a valid one.
  static bool _isValidationError(QueryResult<Object?> result) {
    final errors = result.exception?.graphqlErrors;
    if (errors == null) return false;
    return errors.any(
      (e) =>
          e.extensions?['classification'] == 'ValidationError' ||
          e.message.startsWith('Validation error'),
    );
  }

  GraphQLClient _createClient() {
    final link = _link;
    if (link == null) {
      return GraphQLClientFactory.create(
        _graphqlEndpoint,
        timeout: requestTimeout,
      );
    }
    // Same cache setup as the factory, over the injected link.
    return GraphQLClient(
      cache: GraphQLCache(
        store: InMemoryStore(),
        partialDataPolicy: PartialDataCachePolicy.accept,
      ),
      link: link,
      queryRequestTimeout: requestTimeout,
    );
  }

  Future<void> _tick() async {
    if (_client == null) return;
    try {
      final positions = await _fetchPositions();
      debugPrint('[RealtimeVehicles] tick: ${positions.length} vehicles');
    } catch (e, st) {
      debugPrint('[RealtimeVehicles] tick error: $e\n$st');
    }
  }

  VehiclePosition? _parseVehicle(
    Map<String, dynamic> json,
    String? routeId,
    String? routeColor,
  ) {
    final lat = (json['lat'] as num?)?.toDouble();
    final lon = (json['lon'] as num?)?.toDouble();
    final vehicleId = json['vehicleId'] as String?;
    if (lat == null || lon == null || vehicleId == null) return null;

    final trip = json['trip'] as Map<String, dynamic>?;
    return VehiclePosition(
      vehicleId: vehicleId,
      position: TrufiLatLng(lat, lon),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      label: json['label'] as String?,
      routeId: routeId,
      routeColor: routeColor,
      tripId: trip?['gtfsId'] as String?,
      timestamp: parseVehicleTimestamp(json),
    );
  }

  /// When the vehicle actually reported, per the GTFS-RT feed — NOT when we
  /// polled. `lastUpdate` is OTP's ISO-8601 timestamp; `lastUpdated` is the
  /// deprecated epoch-seconds twin kept as a fallback for older servers.
  /// Falls back to the poll time only when the feed carries neither, so
  /// downstream freshness UI degrades to "fresh" instead of lying with a
  /// per-vehicle age that was never real (found by review on #981).
  @visibleForTesting
  static DateTime parseVehicleTimestamp(Map<String, dynamic> json) {
    final iso = json['lastUpdate'] as String?;
    if (iso != null) {
      final parsed = DateTime.tryParse(iso);
      if (parsed != null) return parsed;
    }
    final epoch = json['lastUpdated'] as num?;
    if (epoch != null && epoch > 0) {
      return DateTime.fromMillisecondsSinceEpoch(
        (epoch * 1000).round(),
        isUtc: true,
      );
    }
    return DateTime.now();
  }

  String get _graphqlEndpoint {
    if (endpoint.contains('/graphql') || endpoint.contains('/gtfs/v1')) {
      return endpoint;
    }
    final base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    return '$base/otp/gtfs/v1';
  }
}

/// Deprecated alias kept for callers that haven't migrated yet.
@Deprecated('Use OtpVehiclePositionsProvider')
typedef VehiclePositionsService = OtpVehiclePositionsProvider;
