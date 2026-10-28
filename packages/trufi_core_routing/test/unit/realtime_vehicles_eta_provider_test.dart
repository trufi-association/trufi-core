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
  double? heading,
  int? directionId,
  DateTime? timestamp,
}) => VehiclePosition(
  vehicleId: id,
  position: TrufiLatLng(
    _origin.latitude + _dLat1500m * (northMeters / 1500),
    _origin.longitude,
  ),
  routeId: route,
  speed: speed,
  heading: heading,
  directionId: directionId,
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
    test('answers the soonest vehicle of each requested route', () async {
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
      expect(
        eta.vehicleId,
        'near',
        reason: 'same (average) speed for both: the nearer one arrives first',
      );
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

    test('a farther bus at speed beats a nearer one that crawls', () async {
      // 1000 m at an implausible 0.5 m/s -> average 15 km/h -> 240 s;
      // 2000 m at 25 m/s -> 80 s. "Soonest", not "nearest".
      final snapshot = await _provider([
        _vehicle('crawling', '1:1132', northMeters: 1000, speed: 0.5),
        _vehicle('fast', '1:1132', northMeters: 2000, speed: 25),
      ]).fetchEtas(_request({'1132'}));
      expect(snapshot.etaForRoute('1132')?.vehicleId, 'fast');
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

  group('direction of travel (#1016)', () {
    // Every vehicle sits 1500 m NORTH of the origin: a heading of 180°
    // (south) points at the rider, 0° (north) points away.
    test(
      'a moving vehicle heading away is dropped, one heading in is kept',
      () async {
        final snapshot = await _provider([
          _vehicle('away', '1:1132', speed: 8, heading: 0),
          _vehicle('in', '1:1132', speed: 8, heading: 180, northMeters: 2500),
        ]).fetchEtas(_request({'1132'}));
        expect(snapshot.etaForRoute('1132')?.vehicleId, 'in');
      },
    );

    test('90° off the bearing is the limit', () {
      final target = _origin;
      final toward = _vehicle('t', '1:1132', speed: 8, heading: 180);
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(toward, target, null),
        isTrue,
      );
      final sideways = _vehicle('s', '1:1132', speed: 8, heading: 90);
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(sideways, target, null),
        isTrue,
      );
      final away = _vehicle('a', '1:1132', speed: 8, heading: 300);
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(away, target, null),
        isFalse,
      );
    });

    test(
      'a stopped or heading-less vehicle is kept whatever it points at',
      () async {
        final snapshot = await _provider([
          _vehicle('stopped', '1:1132', speed: 0.3, heading: 0),
          _vehicle('blind', '1:1481', speed: 8),
        ]).fetchEtas(_request({'1132', '1481'}));
        expect(snapshot.etaForRoute('1132')?.vehicleId, 'stopped');
        expect(snapshot.etaForRoute('1481')?.vehicleId, 'blind');
      },
    );

    test('heading known, speed unknown: the heading still decides', () async {
      // The heading is a compass reading on the GTFS-RT wire, independent of
      // the speed: a feed that publishes one without the other keeps the
      // filter. 200 m past the stop and pointing away, no speed → out.
      final snapshot = await _provider([
        _vehicle('passed', '1:1132', northMeters: 200, heading: 0),
        _vehicle('in', '1:1132', speed: 8, heading: 180, northMeters: 2500),
      ]).fetchEtas(_request({'1132'}));
      expect(snapshot.etaForRoute('1132')?.vehicleId, 'in');
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(
          _vehicle('towards', '1:1132', heading: 180),
          _origin,
          null,
        ),
        isTrue,
        reason: 'no speed but pointing at the stop: kept',
      );
    });

    test('within 30 m of the stop the heading is noise: kept', () {
      // 5 m past the stop (south of it) and heading south, i.e. away:
      // "arriving now" is the right answer, the bearing is GPS jitter.
      final arriving = _vehicle(
        'a',
        '1:1132',
        northMeters: -5,
        speed: 8,
        heading: 180,
      );
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(arriving, _origin, null),
        isTrue,
      );
      // On the stop itself the bearing is atan2(0, 0) = north: still kept.
      final onStop = _vehicle(
        'o',
        '1:1132',
        northMeters: 0,
        speed: 8,
        heading: 180,
      );
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(onStop, _origin, null),
        isTrue,
      );
      // The same vehicle 200 m past the stop is gone.
      final gone = _vehicle(
        'g',
        '1:1132',
        northMeters: -200,
        speed: 8,
        heading: 180,
      );
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(gone, _origin, null),
        isFalse,
      );
    });

    test(
      'the GTFS direction is a pre-filter: the opposite pattern is out',
      () async {
        final request = VehicleEtaRequest(
          origin: _origin,
          routeIds: const {'1132'},
          directions: const {'1:1132': 1},
        );
        expect(request.directionFor('1132'), 1);
        expect(request.directionFor('1:1132'), 1);
        expect(request.directionFor('1481'), isNull);
        final snapshot = await _provider([
          // Nearer and heading in, but on the opposite pattern: never reaches
          // the stop on this trip.
          _vehicle(
            'wrong-way',
            '1:1132',
            speed: 8,
            heading: 180,
            directionId: 0,
          ),
          _vehicle(
            'right-way',
            '1:1132',
            speed: 8,
            heading: 180,
            directionId: 1,
            northMeters: 2500,
          ),
        ]).fetchEtas(request);
        expect(snapshot.etaForRoute('1132')?.vehicleId, 'right-way');
      },
    );

    test('same pattern, past the stop and moving away: dropped', () async {
      // The issue's opening scenario. A direction match is not a pass: the
      // heading still runs, so the bus 200 m past the stop loses to the one
      // coming from 2500 m instead of winning on distance.
      final snapshot =
          await _provider([
            _vehicle(
              'passed',
              '1:1132',
              northMeters: 200,
              speed: 8,
              heading: 0,
              directionId: 1,
            ),
            _vehicle(
              'coming',
              '1:1132',
              northMeters: 2500,
              speed: 8,
              heading: 180,
              directionId: 1,
            ),
          ]).fetchEtas(
            VehicleEtaRequest(
              origin: _origin,
              routeIds: const {'1132'},
              directions: const {'1:1132': 1},
            ),
          );
      expect(snapshot.etaForRoute('1132')?.vehicleId, 'coming');
    });

    test('the opposite pattern is out even when stopped', () async {
      final snapshot =
          await _provider([
            _vehicle(
              'parked-wrong',
              '1:1132',
              northMeters: 300,
              speed: 0.3,
              heading: 180,
              directionId: 0,
            ),
            _vehicle(
              'parked-right',
              '1:1132',
              speed: 0.3,
              heading: 0,
              directionId: 1,
            ),
          ]).fetchEtas(
            VehicleEtaRequest(
              origin: _origin,
              routeIds: const {'1132'},
              directions: const {'1:1132': 1},
            ),
          );
      expect(
        snapshot.etaForRoute('1132')?.vehicleId,
        'parked-right',
        reason:
            'stopped is no free pass for the wrong pattern; the right one '
            'is kept whatever it points at',
      );
    });

    test('a vehicle without direction_id (a loop, an older feed) uses the '
        'heading', () {
      // OTP reports trip.directionId null when the direction is irrelevant.
      final away = _vehicle('x', '1:1132', speed: 8, heading: 0);
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(away, _origin, 1),
        isFalse,
      );
      final towards = _vehicle('y', '1:1132', speed: 8, heading: 180);
      expect(
        RealtimeVehiclesEtaProvider.headsTowards(towards, _origin, 1),
        isTrue,
      );
    });

    test('bearingDegrees: north is 0, east is 90', () {
      const a = TrufiLatLng(0, 0);
      expect(bearingDegrees(a, const TrufiLatLng(1, 0)), closeTo(0, 0.01));
      expect(bearingDegrees(a, const TrufiLatLng(0, 1)), closeTo(90, 0.01));
      expect(bearingDegrees(a, const TrufiLatLng(-1, 0)), closeTo(180, 0.01));
      expect(bearingDegrees(a, const TrufiLatLng(0, -1)), closeTo(270, 0.01));
    });
  });
}
