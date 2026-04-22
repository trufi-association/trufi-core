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
        trip { gtfsId }
      }
    }
  }
}
''';

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
    _client = GraphQLClientFactory.create(_graphqlEndpoint, timeout: requestTimeout);
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
  }

  Future<void> _tick() async {
    final client = _client;
    if (client == null) return;
    try {
      final result = await client.query(
        WatchQueryOptions(
          document: parseString(_query),
          fetchResults: true,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        debugPrint('[RealtimeVehicles] query exception: ${result.exception}');
        return;
      }
      if (result.data == null) {
        debugPrint('[RealtimeVehicles] query returned null data');
        return;
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
      _controller.add(positions);
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
      timestamp: DateTime.now(),
    );
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
