import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// #1004: ETAs derived from a GTFS-RT fleet snapshot. Pins the arithmetic
/// (distance over reported-or-average speed), the filters (max distance,
/// stale reports, implausible speeds) and the feed-agnostic route match.
class _FakeVehicles implements RealtimeVehiclesProvider {
  _FakeVehicles(this._latest, {this.latestThrows = false});

  final List<VehiclePosition> _latest;

  /// When true, reading [latest] fails the test: proves the loader path
  /// never touches the stale snapshot.
  final bool latestThrows;

  @override
  List<VehiclePosition> get latest {
    if (latestThrows) throw StateError('latest must not be read');
    return _latest;
  }

  @override
  Stream<List<VehiclePosition>> get positionsStream => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  void stop() {}
}

/// Cochabamba, Plaza 14 de Septiembre.
const _origin = TrufiLatLng(-17.3936, -66.1570);

/// One degree of latitude is ~111.2 km, so this offset is ~1500 m north.
const _dLat1500m = 1500 / 111195.0;

final _now = DateTime(2026, 10, 13, 10, 30);

VehiclePosition _vehicle(
  String id,
  String? route, {
  double northMeters = 1500,
  double? speed,
  DateTime? timestamp,
}) => VehiclePosition(
  vehicleId: id,
  position: TrufiLatLng(
    _origin.latitude + _dLat1500m * (northMeters / 1500),
    _origin.longitude,
  ),
  routeId: route,
  speed: speed,
  timestamp: timestamp,
);

RealtimeVehiclesEtaProvider _provider(
  List<VehiclePosition> fleet, {
  VehicleSnapshotLoader? loader,
  bool latestThrows = false,
}) => RealtimeVehiclesEtaProvider(
  vehicles: _FakeVehicles(fleet, latestThrows: latestThrows),
  snapshotLoader: loader,
  now: () => _now,
);

VehicleEtaRequest _request(Set<String> routes) =>
    VehicleEtaRequest(origin: _origin, routeIds: routes);

void main() {
  group('RealtimeVehiclesEtaProvider.estimate', () {
    final provider = _provider(const []);

    test('uses the average speed when no speed is reported', () {
      expect(
        provider.estimate(distanceMeters: 1500),
        const Duration(seconds: 360),
        reason: '1500 m at 15 km/h (4.1667 m/s) is 360 s',
      );
    });

    test('uses the reported speed when plausible', () {
      expect(
        provider.estimate(distanceMeters: 1500, reportedSpeedMps: 10),
        const Duration(seconds: 150),
        reason: 'fails if the reported speed is ignored',
      );
    });

    test('falls back to the average for implausible speeds', () {
      expect(
        provider.estimate(distanceMeters: 1500, reportedSpeedMps: 0.2),
        const Duration(seconds: 360),
        reason: '0.2 m/s is a bus at a red light, not its cruising speed',
      );
      expect(
        provider.estimate(distanceMeters: 1500, reportedSpeedMps: 50),
        const Duration(seconds: 360),
        reason: '180 km/h is a GPS glitch',
      );
    });
  });

  group('RealtimeVehiclesEtaProvider.fetchEtas', () {
    test('answers the nearest vehicle of each requested route', () async {
      final near = _vehicle('near', '1:1132', northMeters: 1500);
      final snapshot = await _provider([
        _vehicle('far', '1:1132', northMeters: 3000),
        near,
        _vehicle('other', '1:1185', northMeters: 1500),
      ]).fetchEtas(_request({'1132'}));

      expect(snapshot.source, RealtimeVehiclesEtaProvider.source);
      expect(snapshot.fetchedAt, _now);
      expect(snapshot.etas, hasLength(1));
      final eta = snapshot.etas.single;
      expect(eta.vehicleId, 'near', reason: 'the nearer vehicle wins');
      expect(eta.routeId, '1132', reason: 'keyed by the REQUESTED id');
      // Geodesic distance (latlong2 Vincenty, rounded to whole meters), so
      // the oracle is computed with the same function the provider uses;
      // the pure arithmetic is pinned by the `estimate` tests above.
      final distance = near.position.distanceTo(_origin);
      expect(distance, closeTo(1500, 10));
      expect(eta.distanceMeters, distance);
      expect(
        eta.eta,
        Duration(seconds: (distance / (15 / 3.6)).round()),
        reason: 'no speed reported → average 15 km/h',
      );
      expect(eta.timestamp, _now, reason: 'no report time → now');
    });

    test('matches prefixed vehicles against a bare request id', () async {
      final snapshot = await _provider([
        _vehicle('A', '1:1132'),
      ]).fetchEtas(_request({'1132'}));
      expect(
        snapshot.etaForRoute('1132'),
        isNotNull,
        reason:
            'strict equality would hide every OTP vehicle from a '
            'bundled-GTFS plan',
      );
    });

    test(
      'measures to the boarding stop when the request carries one',
      () async {
        // Bus 1500 m north of the rider, boarding stop 1000 m north: the bus
        // is ~500 m from the stop, which is what the badge must count down.
        final boarding = TrufiLatLng(
          _origin.latitude + _dLat1500m * (1000 / 1500),
          _origin.longitude,
        );
        final bus = _vehicle('A', '1:1132', northMeters: 1500);
        final other = _vehicle('B', '1:1185', northMeters: 1500);
        final snapshot = await _provider([bus, other]).fetchEtas(
          VehicleEtaRequest(
            origin: _origin,
            routeIds: const {'1132', '1185'},
            boardingPoints: {'1:1132': boarding},
          ),
        );

        final toStop = bus.position.distanceTo(boarding);
        expect(toStop, closeTo(500, 10));
        final eta = snapshot.etaForRoute('1132')!;
        expect(
          eta.distanceMeters,
          toStop,
          reason: 'measured to the stop, not to where the rider stands',
        );
        expect(eta.eta, Duration(seconds: (toStop / (15 / 3.6)).round()));
        expect(
          snapshot.etaForRoute('1185')?.distanceMeters,
          other.position.distanceTo(_origin),
          reason:
              'a route without a boarding point still measures to the origin',
        );
      },
    );

    test(
      'the max distance applies to the boarding stop, not the rider',
      () async {
        // Stop 9 km away with the bus 500 m before it: fine. The same bus is
        // 9.5 km from the rider — irrelevant, the rider walks/rides elsewhere.
        final boarding = TrufiLatLng(
          _origin.latitude + _dLat1500m * (9000 / 1500),
          _origin.longitude,
        );
        final snapshot =
            await _provider([
              _vehicle('A', '1:1132', northMeters: 9500),
            ]).fetchEtas(
              VehicleEtaRequest(
                origin: _origin,
                routeIds: const {'1132'},
                boardingPoints: {'1132': boarding},
              ),
            );
        expect(snapshot.etaForRoute('1132')?.distanceMeters, closeTo(500, 10));
      },
    );

    test('drops vehicles beyond the max distance', () async {
      final snapshot = await _provider([
        _vehicle('A', '1:1132', northMeters: 12000),
      ]).fetchEtas(_request({'1132'}));
      expect(snapshot.etas, isEmpty);
    });

    test('drops stale reports', () async {
      final snapshot = await _provider([
        _vehicle(
          'old',
          '1:1132',
          timestamp: _now.subtract(const Duration(minutes: 10)),
        ),
        _vehicle(
          'fresh',
          '1:1185',
          timestamp: _now.subtract(const Duration(minutes: 1)),
        ),
      ]).fetchEtas(_request({'1132', '1185'}));
      expect(snapshot.etaForRoute('1132'), isNull);
      expect(snapshot.etaForRoute('1185')?.vehicleId, 'fresh');
      expect(
        snapshot.etaForRoute('1185')?.timestamp,
        _now.subtract(const Duration(minutes: 1)),
        reason: 'the report time is the vehicle\'s own, not the poll time',
      );
    });

    test('uses the snapshot loader and never reads latest', () async {
      var loads = 0;
      final snapshot = await _provider(
        const [],
        latestThrows: true,
        loader: () async {
          loads++;
          return [_vehicle('L', '1:1132')];
        },
      ).fetchEtas(_request({'1132'}));
      expect(loads, 1);
      expect(snapshot.etaForRoute('1132')?.vehicleId, 'L');
    });

    test('wraps loader failures in VehicleEtaException', () {
      final provider = _provider(
        const [],
        loader: () async => throw StateError('otp down'),
      );
      expect(
        provider.fetchEtas(_request({'1132'})),
        throwsA(
          isA<VehicleEtaException>().having(
            (e) => e.cause,
            'cause',
            isA<StateError>(),
          ),
        ),
      );
    });

    test('an empty fleet is a valid empty answer', () async {
      final snapshot = await _provider(const []).fetchEtas(_request({'1132'}));
      expect(snapshot.etas, isEmpty);
    });
  });
}
