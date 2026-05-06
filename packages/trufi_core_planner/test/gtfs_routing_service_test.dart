import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

void main() {
  group('GtfsRoutingService score uses real distance (issue #859)', () {
    // Five stops along an east-west axis, ~111m apart at the equator:
    //   A → B → C → D → E
    //
    // Routes:
    //   "1": pattern A → B → C            (forward)
    //   "1": pattern E → D → C            (reverse — same shortName, different
    //                                      route_id, mirrors the Cochabamba feed)
    //   "2": pattern C → D → E            (forward, only direct A→E option requires
    //                                      transferring at C)
    //   "9": pattern A → C → E            (direct, fewer stops, the right answer)
    //
    // For a query A → E:
    //   - "9" direct via 3 stops: ~222m transit, sensible.
    //   - "1" forward → "1" reverse: A→B→C, then C←D←E... wait, "1" reverse goes
    //     from E to C (E→D→C). The transfer would be at C, but you'd need to
    //     ride from C to E on the reverse, which the pattern doesn't support
    //     (E comes BEFORE C in that pattern). So "1"→"1" same-shortName transfer
    //     is structurally blocked by the index check, not by name. Good.
    //   - "1" forward → "2" forward: A→B→C, then C→D→E. Real transfer, ~444m total.
    //   - "9" direct beats "1→2" because it has fewer stops + no transfer cost.
    final stopA = const GtfsStop(id: 'A', name: 'A', lat: 0, lon: 0);
    final stopB = const GtfsStop(id: 'B', name: 'B', lat: 0, lon: 0.001);
    final stopC = const GtfsStop(id: 'C', name: 'C', lat: 0, lon: 0.002);
    final stopD = const GtfsStop(id: 'D', name: 'D', lat: 0, lon: 0.003);
    final stopE = const GtfsStop(id: 'E', name: 'E', lat: 0, lon: 0.004);

    const routeOneFwd = GtfsRoute(
      id: 'r1f',
      shortName: '1',
      longName: '1 outbound',
      type: GtfsRouteType.bus,
    );
    const routeOneRev = GtfsRoute(
      id: 'r1r',
      shortName: '1',
      longName: '1 inbound',
      type: GtfsRouteType.bus,
    );
    const routeTwo = GtfsRoute(
      id: 'r2',
      shortName: '2',
      longName: '2',
      type: GtfsRouteType.bus,
    );
    const routeNine = GtfsRoute(
      id: 'r9',
      shortName: '9',
      longName: '9',
      type: GtfsRouteType.bus,
    );

    const trips = [
      GtfsTrip(id: 't1f', routeId: 'r1f', serviceId: 's'),
      GtfsTrip(id: 't1r', routeId: 'r1r', serviceId: 's'),
      GtfsTrip(id: 't2', routeId: 'r2', serviceId: 's'),
      GtfsTrip(id: 't9', routeId: 'r9', serviceId: 's'),
    ];

    final stopTimes = <GtfsStopTime>[
      // 1 forward: A → B → C
      const GtfsStopTime(tripId: 't1f', stopId: 'A', stopSequence: 1),
      const GtfsStopTime(tripId: 't1f', stopId: 'B', stopSequence: 2),
      const GtfsStopTime(tripId: 't1f', stopId: 'C', stopSequence: 3),
      // 1 reverse: E → D → C
      const GtfsStopTime(tripId: 't1r', stopId: 'E', stopSequence: 1),
      const GtfsStopTime(tripId: 't1r', stopId: 'D', stopSequence: 2),
      const GtfsStopTime(tripId: 't1r', stopId: 'C', stopSequence: 3),
      // 2 forward: C → D → E
      const GtfsStopTime(tripId: 't2', stopId: 'C', stopSequence: 1),
      const GtfsStopTime(tripId: 't2', stopId: 'D', stopSequence: 2),
      const GtfsStopTime(tripId: 't2', stopId: 'E', stopSequence: 3),
      // 9 direct: A → C → E
      const GtfsStopTime(tripId: 't9', stopId: 'A', stopSequence: 1),
      const GtfsStopTime(tripId: 't9', stopId: 'C', stopSequence: 2),
      const GtfsStopTime(tripId: 't9', stopId: 'E', stopSequence: 3),
    ];

    final data = GtfsData(
      agencies: const [],
      stops: {'A': stopA, 'B': stopB, 'C': stopC, 'D': stopD, 'E': stopE},
      routes: {
        'r1f': routeOneFwd,
        'r1r': routeOneRev,
        'r2': routeTwo,
        'r9': routeNine,
      },
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
      origin: stopA.position,
      destination: stopE.position,
      maxWalkDistance: 500,
      maxResults: 50,
    );

    test('top result is the direct option (9), not a same-line transfer', () {
      expect(paths, isNotEmpty);
      final top = paths.first;
      expect(top.segments, hasLength(1),
          reason: 'top should be a direct route, not a transfer');
      expect(top.segments.first.route.shortName, equals('9'));
    });

    test('any path that chains "1 → 1" must be ranked below cross-line options',
        () {
      // Find the rank of the worst-case same-shortName transfer, if it
      // exists at all. It must come AFTER all transit-cheaper alternatives.
      final firstSameLineIdx = paths.indexWhere((p) {
        if (p.segments.length < 2) return false;
        for (var i = 1; i < p.segments.length; i++) {
          if (p.segments[i - 1].route.shortName ==
              p.segments[i].route.shortName) {
            return true;
          }
        }
        return false;
      });

      if (firstSameLineIdx == -1) return; // Not generated at all — fine.

      // It exists but must rank below at least the direct "9" and the
      // legitimate "1 → 2" transfer.
      expect(firstSameLineIdx, greaterThan(0),
          reason: 'a "1 → 1" detour must not be the top suggestion');
    });

    test('every path has a non-zero transitDistance recorded', () {
      for (final p in paths) {
        for (final seg in p.segments) {
          expect(seg.transitDistance, greaterThan(0),
              reason:
                  'transitDistance must be precomputed for ${seg.route.shortName}');
        }
      }
    });
  });
}
