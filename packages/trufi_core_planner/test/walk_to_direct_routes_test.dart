import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// Regression for issue #926: the planner must surface a DIRECT line that
/// requires walking a few extra blocks instead of only offering
/// transfer-heavy routes through the nearest stops.
///
/// Layout (0.001 deg ≈ 111 m):
///   - Origin O with 12 decoy stops within ~150 m, all served only by the
///     transfer line T1.
///   - The direct line D1 boards at DS, ~600 m from O — farther than every
///     decoy (outside the old top-10 candidates) and beyond the old 500 m
///     radius.
///   - T1 reaches hub H, where T2 continues to the destination — the
///     2-leg alternative the old parameters were limited to.
void main() {
  const origin = GtfsStop(id: 'O', name: 'origin ref', lat: 0, lon: 0);

  // 12 decoys ring the origin (~55-150 m), closer than the direct stop.
  final decoys = [
    for (var i = 0; i < 12; i++)
      GtfsStop(
        id: 'N$i',
        name: 'near $i',
        lat: 0.0005 + 0.00008 * i,
        lon: 0.00005 * i,
      ),
  ];

  // Direct line boarding stop: ~600 m north of the origin.
  const directStart = GtfsStop(
    id: 'DS',
    name: 'direct start',
    lat: 0.0054,
    lon: 0,
  );
  // Stops near the destination (~3.3 km east).
  const directEnd = GtfsStop(
    id: 'DZ',
    name: 'direct end',
    lat: 0.0005,
    lon: 0.03,
  );
  const hub = GtfsStop(id: 'H', name: 'hub', lat: 0, lon: 0.015);
  const transferEnd = GtfsStop(
    id: 'TZ',
    name: 'transfer end',
    lat: -0.0005,
    lon: 0.03,
  );

  const routes = {
    'd1': GtfsRoute(
      id: 'd1',
      shortName: 'D1',
      longName: 'direct',
      type: GtfsRouteType.bus,
    ),
    't1': GtfsRoute(
      id: 't1',
      shortName: 'T1',
      longName: 'feeder',
      type: GtfsRouteType.bus,
    ),
    't2': GtfsRoute(
      id: 't2',
      shortName: 'T2',
      longName: 'connector',
      type: GtfsRouteType.bus,
    ),
  };

  const trips = {
    'd1t': GtfsTrip(id: 'd1t', routeId: 'd1', serviceId: 's'),
    't1t': GtfsTrip(id: 't1t', routeId: 't1', serviceId: 's'),
    't2t': GtfsTrip(id: 't2t', routeId: 't2', serviceId: 's'),
  };

  final stopTimes = <GtfsStopTime>[
    // D1: DS → DZ (the direct ride).
    const GtfsStopTime(tripId: 'd1t', stopId: 'DS', stopSequence: 1),
    const GtfsStopTime(tripId: 'd1t', stopId: 'DZ', stopSequence: 2),
    // T1: N0 → H (feeder from the closest decoy to the hub).
    const GtfsStopTime(tripId: 't1t', stopId: 'N0', stopSequence: 1),
    const GtfsStopTime(tripId: 't1t', stopId: 'H', stopSequence: 2),
    // T2: H → TZ (hub to destination).
    const GtfsStopTime(tripId: 't2t', stopId: 'H', stopSequence: 1),
    const GtfsStopTime(tripId: 't2t', stopId: 'TZ', stopSequence: 2),
  ];

  final data = GtfsData(
    agencies: const [],
    stops: {
      'O': origin,
      for (final d in decoys) d.id: d,
      'DS': directStart,
      'DZ': directEnd,
      'H': hub,
      'TZ': transferEnd,
    },
    routes: routes,
    trips: trips,
    stopTimes: stopTimes,
    calendars: const {},
    calendarDates: const [],
    frequencies: const [],
    shapes: const {},
  );

  final service = GtfsRoutingService(
    data: data,
    spatialIndex: GtfsSpatialIndex(data.stops),
    routeIndex: GtfsRouteIndex(data),
  );

  final target = transferEnd.position; // destination area

  test('new defaults surface the direct line a short walk away', () {
    final paths = service.findRoutes(
      origin: origin.position,
      destination: target,
      maxWalkDistance: 800,
    );

    expect(paths, isNotEmpty);
    expect(
      paths.first.segments,
      hasLength(1),
      reason: 'walking ~600 m to D1 beats a 2-leg transfer',
    );
    expect(paths.first.segments.first.route.shortName, 'D1');
  });

  test('old stop cap alone hid the direct line even with a wide radius', () {
    final paths = service.findRoutes(
      origin: origin.position,
      destination: target,
      maxWalkDistance: 800,
      maxStopCandidates: 10,
    );

    // The 12 closer decoys crowd out DS from the top-10, so only the
    // transfer survives — the pre-fix behavior this test documents.
    expect(paths, isNotEmpty);
    expect(paths.first.segments.length, greaterThan(1));
  });

  test('old 500 m radius alone hid the direct line too', () {
    final paths = service.findRoutes(
      origin: origin.position,
      destination: target,
      maxWalkDistance: 500,
    );

    expect(paths, isNotEmpty);
    expect(paths.first.segments.length, greaterThan(1));
  });
}
