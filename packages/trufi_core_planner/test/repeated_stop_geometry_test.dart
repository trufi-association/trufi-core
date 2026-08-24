import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

void main() {
  group('transfer at a repeated stop keeps its geometry (issue #986)', () {
    // Circular line L visits stop X twice:
    //   L: S1 → X → S3 → S4 → X → S6      (X at positions 1 and 4)
    //   M: X → M2 → DEST                   (transfer line)
    //
    // Query: origin at S3 (position 2 on L), destination at DEST (only on M).
    // There is no direct line, so the only itinerary is L → transfer at X → M.
    //
    // The valid transfer uses X's SECOND visit (position 4 > 2). The bug:
    // `_resolvePathStops` re-derived the boarding/alighting indices from stop
    // IDs via `indexOfStop`, which returns the FIRST occurrence (position 1),
    // yielding toIdx(1) <= fromIdx(2) — the leg was returned with no stops and
    // no shape, and the map rendered the itinerary as a straight line.
    //
    // Stops sit ~333 m apart (0.003° at the equator): with a 120 m walk
    // limit the only stop near the origin is S3 and the only one near the
    // destination is DEST — otherwise "walk to X, ride M" becomes a direct
    // option and direct results suppress the transfer bucket entirely.
    final stops = <String, GtfsStop>{
      'S1': const GtfsStop(id: 'S1', name: 'S1', lat: 0, lon: 0),
      'X': const GtfsStop(id: 'X', name: 'X', lat: 0, lon: 0.003),
      'S3': const GtfsStop(id: 'S3', name: 'S3', lat: 0, lon: 0.006),
      'S4': const GtfsStop(id: 'S4', name: 'S4', lat: 0, lon: 0.009),
      // The circle comes back to X after S4; then continues to S6.
      'S6': const GtfsStop(id: 'S6', name: 'S6', lat: 0.003, lon: 0.003),
      'M2': const GtfsStop(id: 'M2', name: 'M2', lat: -0.003, lon: 0.003),
      'DEST': const GtfsStop(id: 'DEST', name: 'DEST', lat: -0.006, lon: 0.003),
    };

    const routeL = GtfsRoute(
      id: 'rL',
      shortName: 'L',
      longName: 'Circular L',
      type: GtfsRouteType.bus,
    );
    const routeM = GtfsRoute(
      id: 'rM',
      shortName: 'M',
      longName: 'M',
      type: GtfsRouteType.bus,
    );

    const trips = [
      GtfsTrip(id: 'tL', routeId: 'rL', serviceId: 's'),
      GtfsTrip(id: 'tM', routeId: 'rM', serviceId: 's'),
    ];

    final stopTimes = <GtfsStopTime>[
      const GtfsStopTime(tripId: 'tL', stopId: 'S1', stopSequence: 1),
      const GtfsStopTime(tripId: 'tL', stopId: 'X', stopSequence: 2),
      const GtfsStopTime(tripId: 'tL', stopId: 'S3', stopSequence: 3),
      const GtfsStopTime(tripId: 'tL', stopId: 'S4', stopSequence: 4),
      const GtfsStopTime(tripId: 'tL', stopId: 'X', stopSequence: 5),
      const GtfsStopTime(tripId: 'tL', stopId: 'S6', stopSequence: 6),
      const GtfsStopTime(tripId: 'tM', stopId: 'X', stopSequence: 1),
      const GtfsStopTime(tripId: 'tM', stopId: 'M2', stopSequence: 2),
      const GtfsStopTime(tripId: 'tM', stopId: 'DEST', stopSequence: 3),
    ];

    final data = GtfsData(
      agencies: const [],
      stops: stops,
      routes: {'rL': routeL, 'rM': routeM},
      trips: {for (final t in trips) t.id: t},
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

    final paths = service.findRoutes(
      origin: stops['S3']!.position,
      destination: stops['DEST']!.position,
      maxWalkDistance: 120,
      maxResults: 50,
    );

    test('the L → M transfer itinerary exists', () {
      expect(paths, isNotEmpty);
      expect(
        paths.any((p) => p.segments.length == 2),
        isTrue,
        reason: 'the only way from S3 to DEST is L → transfer at X → M',
      );
    });

    test('every transit leg carries stops and geometry', () {
      for (final p in paths) {
        for (final seg in p.segments) {
          expect(
            seg.stops,
            isNotEmpty,
            reason:
                'leg ${seg.route.shortName} ${seg.fromStop.id}→${seg.toStop.id} '
                'lost its stops — the map would drop it and draw a straight line',
          );
          expect(
            seg.shapePoints,
            isNotEmpty,
            reason:
                'leg ${seg.route.shortName} ${seg.fromStop.id}→${seg.toStop.id} '
                'lost its shape polyline',
          );
        }
      }
    });

    test('the L leg rides S3 → S4 → X (the second visit), not backwards', () {
      final transfer = paths.firstWhere((p) => p.segments.length == 2);
      final legL = transfer.segments.first;
      expect(legL.route.shortName, 'L');
      expect(legL.stops.map((s) => s.id).toList(), ['S3', 'S4', 'X']);
    });
  });
}
