import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// trufi-lima#13: "no vehicle of this route in the snapshot at all" (no GPS)
/// and "vehicles exist but none heads to the stop" were the same
/// `unavailable`. The snapshot now says which requested routes had any
/// vehicle, whatever the heading filter did to them.
class _NoVehicles implements RealtimeVehiclesProvider {
  @override
  List<VehiclePosition> get latest => const [];
  @override
  Stream<List<VehiclePosition>> get positionsStream => const Stream.empty();
  @override
  Future<void> start() async {}
  @override
  void stop() {}
}

void main() {
  const stop = TrufiLatLng(-12.0464, -77.0428);
  // ~1.5 km south-west of the stop.
  const near = TrufiLatLng(-12.0580, -77.0540);
  final now = DateTime(2026, 11, 26, 12);
  final towards = bearingDegrees(near, stop);

  VehiclePosition bus(String id, String route, {required double heading}) =>
      VehiclePosition(
        vehicleId: id,
        position: near,
        routeId: route,
        heading: heading,
        speed: 8,
        timestamp: now,
      );

  Future<VehicleEtaSnapshot> ask(
    List<VehiclePosition> fleet,
    Set<String> routes,
  ) =>
      RealtimeVehiclesEtaProvider(
        vehicles: _NoVehicles(),
        snapshotLoader: ({Set<String>? routeIds}) async => fleet,
        now: () => now,
      ).fetchEtas(
        VehicleEtaRequest(
          origin: stop,
          routeIds: routes,
          boardingPoints: {for (final r in routes) r: stop},
        ),
      );

  Set<String> bare(VehicleEtaSnapshot s) =>
      s.routesWithVehicles.map(stripGtfsFeedPrefix).toSet();

  test('a route with a bus coming is both in etas and in routesWithVehicles',
      () async {
    final snapshot = await ask([bus('a', '1:A', heading: towards)], {'1:A'});

    expect(snapshot.etas.map((e) => e.routeId), ['1:A']);
    expect(bare(snapshot), {'A'});
  });

  test(
      'buses of the route that all drive away: no eta, but the route has '
      'vehicles (none nearby)', () async {
    final snapshot = await ask(
      [bus('a', '1:A', heading: (towards + 180) % 360)],
      {'1:A'},
    );

    expect(snapshot.etas, isEmpty);
    expect(bare(snapshot), {'A'}, reason: 'there IS live data for A');
  });

  test('no bus of the route in the snapshot: not in routesWithVehicles',
      () async {
    final snapshot = await ask([bus('b', '1:B', heading: towards)], {'1:A'});

    expect(snapshot.etas, isEmpty);
    expect(bare(snapshot), isEmpty, reason: 'B was not asked for, A has none');
  });

  test('decided per route: A has vehicles (leaving), C has none', () async {
    final snapshot = await ask(
      [bus('a', 'A', heading: (towards + 180) % 360)],
      {'1:A', '1:C'},
    );

    expect(bare(snapshot), {'A'});
    expect(bare(snapshot), isNot(contains('C')));
  });

  test('an empty fleet reports no route with vehicles', () async {
    final snapshot = await ask(const [], {'1:A'});
    expect(snapshot.etas, isEmpty);
    expect(snapshot.routesWithVehicles, isEmpty);
  });
}
