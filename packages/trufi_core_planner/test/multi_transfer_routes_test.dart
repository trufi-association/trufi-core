import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// Phase 3 of [GtfsRoutingService.findRoutes]: itineraries with two or more
/// transfers through the round-based search over the pattern graph (#998).
///
/// Geometry: at the equator 0.001° ≈ 111 m. Lines are laid out along
/// lat 0 so that reaching the far end needs a chain of buses; a second
/// street 15 m north (lat 0.000135) provides walkable transfers.
void main() {
  GtfsData feed({
    required Map<String, GtfsStop> stops,
    required Map<String, GtfsRoute> routes,
    required Map<String, List<String>> tripStops, // tripId → stop ids
    Map<String, String>? tripRoute, // tripId → routeId (default: same id)
  }) {
    return GtfsData(
      agencies: const [],
      stops: stops,
      routes: routes,
      trips: {
        for (final t in tripStops.keys)
          t: GtfsTrip(id: t, routeId: tripRoute?[t] ?? t, serviceId: 's'),
      },
      stopTimes: [
        for (final e in tripStops.entries)
          for (var i = 0; i < e.value.length; i++)
            GtfsStopTime(tripId: e.key, stopId: e.value[i], stopSequence: i),
      ],
      calendars: const {},
      calendarDates: const [],
      frequencies: const [],
      shapes: const {},
    );
  }

  GtfsRoute bus(String id, String shortName) => GtfsRoute(
    id: id,
    shortName: shortName,
    longName: 'line $id',
    type: GtfsRouteType.bus,
  );

  GtfsStop at(String id, double lon, {double lat = 0}) =>
      GtfsStop(id: id, name: id, lat: lat, lon: lon);

  List<String> chain(RoutingPath p) =>
      p.segments.map((s) => s.route.id).toList();

  group('three lines in a row: A → B → C (shared stops)', () {
    // A: s0 → s1 → s2        (0 … 222 m)
    // B:           s2 → s3 → s4   (222 … 444 m)
    // C:                     s4 → s5 → s6   (444 … 666 m)
    // s0 → s6 needs A, B and C: two transfers, none shared by any pair.
    final stops = {for (var i = 0; i <= 6; i++) 's$i': at('s$i', 0.001 * i)};
    final data = feed(
      stops: stops,
      routes: {'A': bus('A', '1'), 'B': bus('B', '2'), 'C': bus('C', '3')},
      tripStops: {
        'A': ['s0', 's1', 's2'],
        'B': ['s2', 's3', 's4'],
        'C': ['s4', 's5', 's6'],
      },
    );
    final spatial = GtfsSpatialIndex(data.stops);
    final index = GtfsRouteIndex(data, spatialIndex: spatial);

    List<RoutingPath> plan(
      GtfsRoutingService service, {
      required int maxTransfers,
      LatLng? from,
      LatLng? to,
    }) => service.findRoutes(
      origin: from ?? stops['s0']!.position,
      destination: to ?? stops['s6']!.position,
      maxWalkDistance: 50,
      maxResults: 5,
      maxTransfers: maxTransfers,
    );

    GtfsRoutingService service() => GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: index,
    );

    test('default (1 transfer) finds nothing — today\'s behaviour', () {
      final s = service();
      expect(plan(s, maxTransfers: 1), isEmpty);
      expect(s.multiTransferSearches, 0, reason: 'phase 3 is opt-in');
    });

    test('maxTransfers: 2 finds A → B → C with the right stops', () {
      final s = service();
      final paths = plan(s, maxTransfers: 2);
      expect(paths, hasLength(1));
      final p = paths.single;
      expect(chain(p), ['A', 'B', 'C']);
      expect(p.transfers, 2);
      expect(p.segments[0].fromStop.id, 's0');
      expect(p.segments[0].toStop.id, 's2');
      expect(p.segments[1].fromStop.id, 's2');
      expect(p.segments[1].toStop.id, 's4');
      expect(p.segments[2].fromStop.id, 's4');
      expect(p.segments[2].toStop.id, 's6');
      // Board/alight positions are recorded, and the resolved stop lists
      // start and end at the real stops.
      expect(p.segments.map((s) => (s.fromIdx, s.toIdx)), [
        (0, 2),
        (0, 2),
        (0, 2),
      ]);
      expect(p.segments[1].stops.map((s) => s.id), ['s2', 's3', 's4']);
      expect(p.transferWalkDistance, 0);
      expect(p.originWalkDistance, 0);
      expect(p.destinationWalkDistance, 0);
      // Score is the usual walk × 2 + transit: 6 hops of ~111 m.
      expect(p.totalTransitDistance, closeTo(666, 2));
      expect(p.score, closeTo(p.totalTransitDistance, 0.001));
      expect(s.multiTransferSearches, 1);
    });

    test('maxTransfers: 3 returns the same two-transfer answer, not more', () {
      final s = service();
      final two = plan(s, maxTransfers: 2);
      final three = plan(s, maxTransfers: 3);
      expect(three.map(chain), two.map(chain));
      expect(three.single.score, two.single.score);
    });

    test('maxTransfers: 0 is direct only', () {
      // s0 → s2 is a direct ride on A; s0 → s4 needs one transfer.
      final s = service();
      expect(plan(s, maxTransfers: 0, to: stops['s2']!.position).map(chain), [
        ['A'],
      ]);
      expect(plan(s, maxTransfers: 0, to: stops['s4']!.position), isEmpty);
      expect(plan(s, maxTransfers: 1, to: stops['s4']!.position).map(chain), [
        ['A', 'B'],
      ]);
      expect(s.multiTransferSearches, 0);
    });

    test('phase 3 does not run when phases 1 or 2 already answered', () {
      final s = service();
      // Direct answer.
      expect(plan(s, maxTransfers: 2, to: stops['s2']!.position), hasLength(1));
      // One-transfer answer.
      expect(plan(s, maxTransfers: 2, to: stops['s4']!.position), hasLength(1));
      expect(s.multiTransferSearches, 0);
      // Only the unreachable-with-one query pays for the search.
      plan(s, maxTransfers: 2);
      expect(s.multiTransferSearches, 1);
    });

    test('the reverse trip is not found: patterns are directed', () {
      // Every line runs west → east only, so s6 → s0 has no chain.
      final s = service();
      expect(
        plan(
          s,
          maxTransfers: 3,
          from: stops['s6']!.position,
          to: stops['s0']!.position,
        ),
        isEmpty,
      );
    });

    test('negative maxTransfers is rejected', () {
      expect(
        () => plan(service(), maxTransfers: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a scan budget of zero yields nothing, never a broken path', () {
      final s = GtfsRoutingService(
        data: data,
        spatialIndex: spatial,
        routeIndex: index,
        maxMultiTransferScans: 0,
      );
      expect(plan(s, maxTransfers: 2), isEmpty);
      expect(s.multiTransferSearches, 1);
    });

    test('the service default is one transfer: phase 3 never runs unasked', () {
      final s = service();
      expect(
        s.findRoutes(
          origin: stops['s0']!.position,
          destination: stops['s6']!.position,
          maxWalkDistance: 50,
          maxResults: 5,
        ),
        isEmpty,
      );
      expect(s.multiTransferSearches, 0);
    });
  });

  group('four lines in a row: three transfers', () {
    final stops = {for (var i = 0; i <= 8; i++) 's$i': at('s$i', 0.001 * i)};
    final data = feed(
      stops: stops,
      routes: {
        'A': bus('A', '1'),
        'B': bus('B', '2'),
        'C': bus('C', '3'),
        'D': bus('D', '4'),
      },
      tripStops: {
        'A': ['s0', 's1', 's2'],
        'B': ['s2', 's3', 's4'],
        'C': ['s4', 's5', 's6'],
        'D': ['s6', 's7', 's8'],
      },
    );
    final spatial = GtfsSpatialIndex(data.stops);
    final service = GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: GtfsRouteIndex(data, spatialIndex: spatial),
    );
    List<RoutingPath> plan(int maxTransfers) => service.findRoutes(
      origin: stops['s0']!.position,
      destination: stops['s8']!.position,
      maxWalkDistance: 50,
      maxResults: 5,
      maxTransfers: maxTransfers,
    );

    test('2 is not enough, 3 finds A → B → C → D', () {
      expect(plan(2), isEmpty);
      final paths = plan(3);
      expect(paths.map(chain), [
        ['A', 'B', 'C', 'D'],
      ]);
      expect(paths.single.transfers, 3);
      expect(paths.single.totalTransitDistance, closeTo(888, 2));
    });

    test('a larger limit stops on its own at the first round that answers', () {
      expect(plan(10).map(chain), [
        ['A', 'B', 'C', 'D'],
      ]);
    });
  });

  group('walkable transfers and ranking of alternatives', () {
    // Two ways from s0 to the east end, both with two transfers:
    //   A: s0 → s1 → s2 (lat 0)
    //   B: s2 → s3 → s4 (lat 0)            shared stops with A and C
    //   C: s4 → s5 → s6 (lat 0)
    //   N: n2 → n3 → n4 (lat 15 m north)   n2 is 15 m from s2, n4 15 m from s4
    // The chain A → N → C walks 15 m twice (30 m × 2 reluctance = 60 m of
    // score) where A → B → C walks nothing; both ride the same meters. So
    // both must be offered, A → B → C first.
    final stops = {
      for (var i = 0; i <= 6; i++) 's$i': at('s$i', 0.001 * i),
      for (var i = 2; i <= 4; i++) 'n$i': at('n$i', 0.001 * i, lat: 0.000135),
    };
    final data = feed(
      stops: stops,
      routes: {
        'A': bus('A', '1'),
        'B': bus('B', '2'),
        'C': bus('C', '3'),
        'N': bus('N', '9'),
      },
      tripStops: {
        'A': ['s0', 's1', 's2'],
        'B': ['s2', 's3', 's4'],
        'C': ['s4', 's5', 's6'],
        'N': ['n2', 'n3', 'n4'],
      },
    );
    final spatial = GtfsSpatialIndex(data.stops);
    final service = GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: GtfsRouteIndex(data, spatialIndex: spatial),
    );
    final paths = service.findRoutes(
      origin: stops['s0']!.position,
      destination: stops['s6']!.position,
      maxWalkDistance: 50,
      maxResults: 5,
      maxTransfers: 2,
    );

    test('both chains are offered, the one without walks first', () {
      expect(paths.map(chain), [
        ['A', 'B', 'C'],
        ['A', 'N', 'C'],
      ]);
      expect(paths[0].score, lessThan(paths[1].score));
    });

    test('the walked transfer is measured and boards at the real stop', () {
      final viaN = paths[1];
      expect(viaN.segments[0].toStop.id, 's2');
      expect(viaN.segments[1].fromStop.id, 'n2');
      expect(viaN.segments[1].toStop.id, 'n4');
      expect(viaN.segments[2].fromStop.id, 's4');
      expect(viaN.transferWalkDistance, closeTo(30, 2));
      expect(
        viaN.totalWalkDistance,
        viaN.originWalkDistance +
            viaN.destinationWalkDistance +
            viaN.transferWalkDistance,
      );
      // Score = 2 × walked + ridden, as everywhere else in the service.
      expect(
        viaN.score,
        closeTo(2 * viaN.totalWalkDistance + viaN.totalTransitDistance, 0.01),
      );
      expect(paths[1].score - paths[0].score, closeTo(60, 4));
    });
  });

  group('chain rule: a line already ridden is not boarded again', () {
    // A: s0 → s1 → s2 → s3 → s4 (lat 0), then continues; X leaves A at s2
    // northwards and comes back to A's street at s4 — a pointless detour:
    //   X: s2 → x → s4
    // and to make the destination need two transfers:
    //   B: s4 → s5 → s6, C: s6 → s7 → s8, destination s8.
    // Any chain "A → X → A" must not appear; A → B → C must.
    final stops = {
      for (var i = 0; i <= 8; i++) 's$i': at('s$i', 0.001 * i),
      'x': at('x', 0.003, lat: 0.002),
    };
    final data = feed(
      stops: stops,
      routes: {
        'A': bus('A', '1'),
        'X': bus('X', '5'),
        'B': bus('B', '2'),
        'C': bus('C', '3'),
      },
      tripStops: {
        'A': ['s0', 's1', 's2', 's3', 's4'],
        'X': ['s2', 'x', 's4'],
        'B': ['s4', 's5', 's6'],
        'C': ['s6', 's7', 's8'],
      },
    );
    final spatial = GtfsSpatialIndex(data.stops);
    final service = GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: GtfsRouteIndex(data, spatialIndex: spatial),
    );

    test('A → X → A never appears; A → B → C does', () {
      final paths = service.findRoutes(
        origin: stops['s0']!.position,
        destination: stops['s8']!.position,
        maxWalkDistance: 50,
        maxResults: 5,
        maxTransfers: 3,
      );
      expect(paths, isNotEmpty);
      for (final p in paths) {
        final lines = chain(p);
        expect(lines.toSet().length, lines.length, reason: 'no line twice');
      }
      expect(paths.first.transfers, 2);
      expect(chain(paths.first), ['A', 'B', 'C']);
    });
  });

  group('label dominance keeps the cheaper boarding and the earlier one', () {
    // Two first legs reach line B at different points:
    //   A1: s0 → s1 → s2          boards B at s2 (B's first stop)
    //   A2: s0 → t  → s3          boards B at s3, but A2 detours north via t
    //   B : s2 → s3 → s4 → s5
    //   C : s5 → s6 → s7          destination s7 (two transfers)
    //   D : s3 → d1               destination d1 reachable only from s3
    // A1 boards B earlier and cheaper than A2, so A2's label on B is
    // dominated and every chain to s7 goes A1 → B → C. For d1 (B's stop s3
    // → D) the earlier A1 label also serves. The point pinned here is that
    // the ranking picks the cheap boarding and that a dominated label never
    // produces a path.
    final stops = {
      for (var i = 0; i <= 7; i++) 's$i': at('s$i', 0.001 * i),
      't': at('t', 0.0015, lat: 0.003), // 333 m north: a long detour
      'd1': at('d1', 0.003, lat: -0.002),
    };
    final data = feed(
      stops: stops,
      routes: {
        'A1': bus('A1', '1'),
        'A2': bus('A2', '11'),
        'B': bus('B', '2'),
        'C': bus('C', '3'),
        'D': bus('D', '4'),
      },
      tripStops: {
        'A1': ['s0', 's1', 's2'],
        'A2': ['s0', 't', 's3'],
        'B': ['s2', 's3', 's4', 's5'],
        'C': ['s5', 's6', 's7'],
        'D': ['s3', 'd1'],
      },
    );
    final spatial = GtfsSpatialIndex(data.stops);
    final service = GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: GtfsRouteIndex(data, spatialIndex: spatial),
    );

    test('the chain through the cheaper boarding wins; the detour is gone', () {
      final paths = service.findRoutes(
        origin: stops['s0']!.position,
        destination: stops['s7']!.position,
        maxWalkDistance: 50,
        maxResults: 5,
        maxTransfers: 2,
      );
      expect(paths.map(chain), [
        ['A1', 'B', 'C'],
      ]);
    });

    test('a later but cheaper boarding survives next to an earlier one', () {
      // Here the detour line is the SHORT one: A2 goes straight to s3
      // (s0 → s3 in one hop of 333 m) while A1 wanders north to reach s2.
      // Boarding B at s3 via A2 is cheaper than at s2 via A1, but only the
      // s2 boarding reaches destination stop s3 … which is served by both.
      // Use d1 (only via D from s3) and s7 to see both labels used.
      final data2 = feed(
        stops: {
          for (var i = 0; i <= 7; i++) 's$i': at('s$i', 0.001 * i),
          't': at('t', 0.001, lat: 0.003),
          'd1': at('d1', 0.003, lat: -0.002),
          'm': at('m', 0.0025, lat: -0.001), // between s2 and s3, only via E
        },
        routes: {
          'A1': bus('A1', '1'),
          'A2': bus('A2', '11'),
          'B': bus('B', '2'),
          'C': bus('C', '3'),
          'E': bus('E', '5'),
        },
        tripStops: {
          'A1': ['s0', 't', 's2'], // long way to s2
          'A2': ['s0', 's3'], // straight to s3
          'B': ['s2', 'm', 's3', 's4', 's5'],
          'C': ['s5', 's6', 's7'],
          'E': ['m', 'd1'],
        },
      );
      final spatial2 = GtfsSpatialIndex(data2.stops);
      final s = GtfsRoutingService(
        data: data2,
        spatialIndex: spatial2,
        routeIndex: GtfsRouteIndex(data2, spatialIndex: spatial2),
      );
      // To s7: the cheap boarding at s3 (A2) must win.
      final toEnd = s.findRoutes(
        origin: stops['s0']!.position,
        destination: stops['s7']!.position,
        maxWalkDistance: 50,
        maxResults: 5,
        maxTransfers: 2,
      );
      expect(toEnd.first.segments.map((x) => x.route.id), ['A2', 'B', 'C']);
      // To d1: only B's stop m (before s3) connects to E, so the earlier
      // boarding at s2 (A1) must still be there.
      final toD1 = s.findRoutes(
        origin: stops['s0']!.position,
        destination: stops['d1']!.position,
        maxWalkDistance: 50,
        maxResults: 5,
        maxTransfers: 2,
      );
      expect(toD1.map(chain), [
        ['A1', 'B', 'E'],
      ]);
    });
  });

  group('fewest transfers win across rounds', () {
    // A → B → C reaches s6 with two transfers; A → B → D → E reaches it
    // with three (D leaves B's last stop northwards, E comes back down to
    // s6). The first round that yields an itinerary ends the search, so a
    // limit of 3 — or any larger one — offers the two-transfer chain only.
    final stops = {
      for (var i = 0; i <= 6; i++) 's$i': at('s$i', 0.001 * i),
      'd': at('d', 0.005, lat: 0.002),
      'e': at('e', 0.006, lat: 0.002),
    };
    final data = feed(
      stops: stops,
      routes: {
        'A': bus('A', '1'),
        'B': bus('B', '2'),
        'C': bus('C', '3'),
        'D': bus('D', '4'),
        'E': bus('E', '5'),
      },
      tripStops: {
        'A': ['s0', 's1', 's2'],
        'B': ['s2', 's3', 's4'],
        'C': ['s4', 's5', 's6'],
        'D': ['s4', 'd', 'e'],
        'E': ['e', 's6'],
      },
    );
    final spatial = GtfsSpatialIndex(data.stops);
    final service = GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: GtfsRouteIndex(data, spatialIndex: spatial),
    );
    List<RoutingPath> plan(int maxTransfers) => service.findRoutes(
      origin: stops['s0']!.position,
      destination: stops['s6']!.position,
      maxWalkDistance: 50,
      maxResults: 5,
      maxTransfers: maxTransfers,
    );

    test(
      'a three-transfer chain is not offered next to a two-transfer one',
      () {
        expect(plan(3).map(chain), [
          ['A', 'B', 'C'],
        ]);
        expect(plan(10).map(chain), [
          ['A', 'B', 'C'],
        ]);
      },
    );
  });

  group('chain-rule fallback stays within its round', () {
    // Case L. Route X has an outbound pattern Xout (boards 89 m from the
    // origin) and a return pattern Xback, the only one serving the
    // destination y20. P detours north, meets Xout at p10 (56 m) and Xback
    // at p50 (56 m) — 3.3 km past a destination 2.2 km away, so phase 2
    // prunes the one-transfer P → Xback by its destination-bbox rule. The
    // only two-transfer chain, Xout → P → Xback, rides X twice. In round 2
    // P's cheapest label (via Xout) is vetoed for the hop into Xback; a
    // fallback to P's round-0 label would emit P → Xback from phase 3 with
    // ONE transfer — the very chain phase 2 pruned. Nothing is the answer.
    final stopsL = {
      's0': at('s0', 0),
      'x0': at('x0', 0, lat: -0.0008),
      'x10': at('x10', 0.010, lat: 0.0005),
      'x50': at('x50', 0.050, lat: 0.001),
      'y50': at('y50', 0.050, lat: -0.0005),
      'y20': at('y20', 0.020, lat: -0.001),
      'y0': at('y0', 0.001, lat: -0.001),
      'pd': at('pd', 0.005, lat: 0.004),
      'p10': at('p10', 0.010),
      'p50': at('p50', 0.050),
    };
    final dataL = feed(
      stops: stopsL,
      routes: {'X': bus('X', 'X'), 'P': bus('P', '1')},
      tripStops: {
        'Xout': ['x0', 'x10', 'x50'],
        'Xback': ['y50', 'y20', 'y0'],
        'P': ['s0', 'pd', 'p10', 'p50'],
      },
      tripRoute: {'Xout': 'X', 'Xback': 'X', 'P': 'P'},
    );

    test('case L: a vetoed label never falls back to an earlier round', () {
      final spatial = GtfsSpatialIndex(dataL.stops);
      final s = GtfsRoutingService(
        data: dataL,
        spatialIndex: spatial,
        routeIndex: GtfsRouteIndex(dataL, spatialIndex: spatial),
      );
      List<RoutingPath> plan(int maxTransfers) => s.findRoutes(
        origin: stopsL['s0']!.position,
        destination: stopsL['y20']!.position,
        maxWalkDistance: 100,
        maxResults: 5,
        maxTransfers: maxTransfers,
      );
      expect(plan(1), isEmpty, reason: 'phase 2 prunes P → Xback (bbox)');
      expect(s.multiTransferSearches, 0);
      expect(
        plan(2),
        isEmpty,
        reason:
            'the only two-transfer chain rides X twice; no one-transfer '
            'itinerary may come out of phase 3',
      );
      expect(s.multiTransferSearches, 1);
      expect(plan(3), isEmpty);
    });

    // Case F. The same-round fallback is genuinely needed: A boards P at
    // p2 cheaply, B detours north and boards P at p1 — earlier and dearer,
    // so both labels live on P's front. Only Aback, route A's return trip,
    // serves the destination z, from p8. The A-label owns the alight at p8
    // but rides A → vetoed; B's label, of the same round, takes it.
    final stopsF = {
      's0': at('s0', 0),
      for (var i = 0; i <= 9; i++) 'p$i': at('p$i', 0.002 + 0.001 * i),
      'n': at('n', 0.0015, lat: 0.003),
      'z': at('z', 0.011, lat: -0.002),
    };
    final dataF = feed(
      stops: stopsF,
      routes: {'A': bus('A', '1'), 'B': bus('B', '2'), 'P': bus('P', '9')},
      tripStops: {
        'A': ['s0', 'p2'],
        'Aback': ['p8', 'z'],
        'B': ['s0', 'n', 'p1'],
        'P': [for (var i = 0; i <= 9; i++) 'p$i'],
      },
      tripRoute: {'A': 'A', 'Aback': 'A', 'B': 'B', 'P': 'P'},
    );

    test('case F: the earlier boarding of the same round takes the vetoed '
        'connection', () {
      final spatial = GtfsSpatialIndex(dataF.stops);
      final s = GtfsRoutingService(
        data: dataF,
        spatialIndex: spatial,
        routeIndex: GtfsRouteIndex(dataF, spatialIndex: spatial),
      );
      final paths = s.findRoutes(
        origin: stopsF['s0']!.position,
        destination: stopsF['z']!.position,
        maxWalkDistance: 50,
        maxResults: 5,
        maxTransfers: 2,
      );
      expect(paths.map(chain), [
        ['B', 'P', 'A'],
      ]);
      final p = paths.single;
      expect(p.transfers, 2);
      expect(p.segments[0].toStop.id, 'p1');
      expect(p.segments[1].fromStop.id, 'p1');
      expect(p.segments[1].toStop.id, 'p8');
      expect(p.segments[2].fromStop.id, 'p8');
      expect(p.segments[2].toStop.id, 'z');
      // Ridden only: s0 → n → p1 (746 m), P p1 → p8 (778 m), Aback p8 → z
      // (249 m); no walks anywhere.
      expect(p.score, closeTo(1773, 3));
      expect(p.score, closeTo(p.totalTransitDistance, 0.001));
    });

    // Case H — a known limitation, documented in _findMultiTransferRoutes.
    // Q runs east; route 2 has R2out (s0 → q3, the cheap way onto Q) and
    // R2back (q9 → z, the only pattern serving z); route 1 detours north
    // and joins Q at q6, dearer. R1 → Q at q6 is dominated by R2out → Q at
    // q3 and dropped — yet it carried the only history the chain rule
    // accepts for Q → R2back (R2out → Q → R2back rides route 2 twice), so
    // the legal itinerary R1 → Q → R2back is not found. On the Sana'a,
    // Cochabamba and Lima feeds this never removed a reachable pair. The
    // control gives the return trip its own route: the chain is found as
    // soon as the rule does not veto it.
    final stopsH = {
      's0': at('s0', 0),
      for (var i = 0; i <= 9; i++) 'q$i': at('q$i', 0.002 + 0.001 * i),
      'n': at('n', 0.004, lat: 0.003),
      'z': at('z', 0.012, lat: -0.002),
    };
    const tripsH = {
      'R2out': ['s0', 'q3'],
      'R2back': ['q9', 'z'],
      'R1': ['s0', 'n', 'q6'],
      'Q': ['q0', 'q1', 'q2', 'q3', 'q4', 'q5', 'q6', 'q7', 'q8', 'q9'],
    };
    List<RoutingPath> planH(GtfsData data) {
      final spatial = GtfsSpatialIndex(data.stops);
      return GtfsRoutingService(
        data: data,
        spatialIndex: spatial,
        routeIndex: GtfsRouteIndex(data, spatialIndex: spatial),
      ).findRoutes(
        origin: stopsH['s0']!.position,
        destination: stopsH['z']!.position,
        maxWalkDistance: 50,
        maxResults: 5,
        maxTransfers: 2,
      );
    }

    test('case H (known limitation): dominance can drop the only history '
        'the chain rule accepts', () {
      final limitation = feed(
        stops: stopsH,
        routes: {
          'R1': bus('R1', '1'),
          'R2': bus('R2', '2'),
          'Q': bus('Q', '9'),
        },
        tripStops: tripsH,
        tripRoute: {'R2out': 'R2', 'R2back': 'R2', 'R1': 'R1', 'Q': 'Q'},
      );
      expect(
        planH(limitation),
        isEmpty,
        reason: 'R1 → Q → R2back exists, but R1\'s label on Q is dominated',
      );
      final control = feed(
        stops: stopsH,
        routes: {
          'R1': bus('R1', '1'),
          'R2': bus('R2', '2'),
          'R2x': bus('R2x', '3'),
          'Q': bus('Q', '9'),
        },
        tripStops: tripsH,
        tripRoute: {'R2out': 'R2', 'R2back': 'R2x', 'R1': 'R1', 'Q': 'Q'},
      );
      expect(planH(control).map(chain), [
        ['R2', 'Q', 'R2x'],
      ]);
    });
  });
}
