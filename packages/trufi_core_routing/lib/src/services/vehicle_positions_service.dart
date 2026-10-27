import 'dart:async';

import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../providers/otp_2_4/graphql_client_factory.dart';

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
  });

  final String endpoint;
  final Duration pollInterval;
  final Duration requestTimeout;

  final _controller = StreamController<List<VehiclePosition>>.broadcast();
  Timer? _timer;
  GraphQLClient? _client;
  List<VehiclePosition> _latest = const [];

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
    _client ??= GraphQLClientFactory.create(
      _graphqlEndpoint,
      timeout: requestTimeout,
    );
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
  /// creates the GraphQL client lazily, updates [latest], emits on
  /// [positionsStream] and returns the parsed fleet. Lets on-demand
  /// consumers (the ETA badges of #1004) take a fresh snapshot while the
  /// "Live buses" layer is off, with no background polling.
  ///
  /// Throws [OtpVehiclePositionsException] on GraphQL errors or null data;
  /// network errors propagate untouched. The polling path ([start]) keeps
  /// its swallow-and-log behaviour through [_tick]. Logs `snapshot: N
  /// vehicles`, so a `tick:` line in the log always means the poller.
  Future<List<VehiclePosition>> fetchOnce() async {
    final positions = await _fetchPositions();
    debugPrint('[RealtimeVehicles] snapshot: ${positions.length} vehicles');
    return positions;
  }

  /// The query itself, shared by [fetchOnce] and the poller's [_tick].
  Future<List<VehiclePosition>> _fetchPositions() async {
    final client = _client ??= GraphQLClientFactory.create(
      _graphqlEndpoint,
      timeout: requestTimeout,
    );
    final result = await client.query(
      WatchQueryOptions(
        document: parseString(_query),
        fetchResults: true,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

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

    _latest = positions;
    if (!_controller.isClosed) _controller.add(positions);
    return positions;
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
