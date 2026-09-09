import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// Unit coverage for the transfer connection table of [GtfsRouteIndex]:
/// walkable transfers between distinct stops, the conditional same-name
/// rule, and the sorted columnar layout the routing service relies on.
///
/// Geometry: at the equator 0.001° ≈ 111 m, 0.000135° ≈ 15 m.
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

  /// All (from route, to route) pairs that have at least one connection.
  Set<String> connectedRoutePairs(GtfsRouteIndex index) {
    final pairs = <String>{};
    for (var p = 0; p < index.patternCount; p++) {
      final from = index.patternById(p).routeId;
      for (final c in index.getConnectionsFor(p)) {
        pairs.add('$from>${index.patternById(c.otherPatternId).routeId}');
      }
    }
    return pairs;
  }

  group('walkable transfer between two kerbs (distinct stop ids)', () {
    // Line A runs east along lat 0; line B starts 15 m north of A's middle
    // stop and continues east. No stop is shared.
    //   A: a0 (0,0) → a1 (0,0.010) → a2 (0,0.020)
    //   B: b0 (0.000135,0.010) → b1 (0.000135,0.030) → b2 (0.000135,0.040)
    final stops = {
      'a0': const GtfsStop(id: 'a0', name: 'a0', lat: 0, lon: 0),
      'a1': const GtfsStop(id: 'a1', name: 'a1', lat: 0, lon: 0.010),
      'a2': const GtfsStop(id: 'a2', name: 'a2', lat: 0, lon: 0.020),
      'b0': const GtfsStop(id: 'b0', name: 'b0', lat: 0.000135, lon: 0.010),
      'b1': const GtfsStop(id: 'b1', name: 'b1', lat: 0.000135, lon: 0.030),
      'b2': const GtfsStop(id: 'b2', name: 'b2', lat: 0.000135, lon: 0.040),
    };
    final data = feed(
      stops: stops,
      routes: {'A': bus('A', '1'), 'B': bus('B', '2')},
      tripStops: {
        'A': ['a0', 'a1', 'a2'],
        'B': ['b0', 'b1', 'b2'],
      },
    );
    final spatial = GtfsSpatialIndex(data.stops);

    List<RoutingPath> plan(GtfsRouteIndex index) =>
        GtfsRoutingService(
          data: data,
          spatialIndex: spatial,
          routeIndex: index,
        ).findRoutes(
          origin: stops['a0']!.position,
          destination: stops['b2']!.position,
          maxWalkDistance: 500,
          maxResults: 5,
        );

    test('default radius links a1 → b0 with the measured walk', () {
      final index = GtfsRouteIndex(data, spatialIndex: spatial);
      final a = index.getPattern('A')!;
      final conns = index.getConnectionsFor(a.id);
      expect(conns, hasLength(1));
      final c = conns.single;
      expect(index.patternById(c.otherPatternId).routeId, 'B');
      expect(c.myStopIdx, 1);
      expect(c.otherStopIdx, 0);
      expect(c.walkMeters, closeTo(15, 1));
      // Symmetric: B's stops are also within 15 m of A's.
      expect(connectedRoutePairs(index), {'A>B', 'B>A'});
    });

    test('the itinerary alights at a1, walks 15 m, boards at b0', () {
      final paths = plan(GtfsRouteIndex(data, spatialIndex: spatial));
      expect(paths, hasLength(1));
      final p = paths.single;
      expect(p.segments.map((s) => s.route.id), ['A', 'B']);
      expect(p.segments[0].toStop.id, 'a1');
      expect(p.segments[1].fromStop.id, 'b0');
      expect(p.segments[1].stops.map((s) => s.id), ['b0', 'b1', 'b2']);
      expect(p.transferWalkDistance, closeTo(15, 1));
      expect(
        p.totalWalkDistance,
        closeTo(15, 1),
        reason: 'origin and destination are exactly on the stops',
      );
      // Walked meters are penalised like any other walk (reluctance 2).
      final transit =
          p.segments[0].transitDistance + p.segments[1].transitDistance;
      expect(p.score, closeTo(transit + 2 * p.transferWalkDistance, 1));
    });

    test('radius 0 restores shared-stop-only transfers: no itinerary', () {
      final index = GtfsRouteIndex(
        data,
        spatialIndex: spatial,
        transferRadiusMeters: 0,
      );
      expect(index.connectionCount, 0);
      expect(plan(index), isEmpty);
    });

    test('a radius smaller than the gap does not link them', () {
      final index = GtfsRouteIndex(
        data,
        spatialIndex: spatial,
        transferRadiusMeters: 10,
      );
      expect(index.connectionCount, 0);
    });

    test('the index builds its own spatial index when none is given', () {
      expect(GtfsRouteIndex(data).connectionCount, 2);
    });
  });

  group('thinning: one walkable connection per crossing', () {
    // Two lines running side by side for five stops 33 m apart, on kerbs
    // 20 m from each other (the dense-feed shape: every stop of A is within
    // 100 m of several stops of B). No stop is shared.
    final stops = <String, GtfsStop>{
      for (var k = 0; k < 5; k++)
        'a$k': GtfsStop(id: 'a$k', name: 'a$k', lat: 0, lon: 0.0003 * k),
      for (var k = 0; k < 5; k++)
        'b$k': GtfsStop(id: 'b$k', name: 'b$k', lat: 0.00018, lon: 0.0003 * k),
    };
    final data = feed(
      stops: stops,
      routes: {'A': bus('A', '1'), 'B': bus('B', '2')},
      tripStops: {
        'A': ['a0', 'a1', 'a2', 'a3', 'a4'],
        'B': ['b0', 'b1', 'b2', 'b3', 'b4'],
      },
    );

    test('a parallel stretch yields a single connection each way', () {
      final index = GtfsRouteIndex(data);
      final a = index.getConnectionsFor(index.getPattern('A')!.id);
      final b = index.getConnectionsFor(index.getPattern('B')!.id);
      // Without thinning every stop would link to up to 4 stops of the
      // other line (20 connections per direction).
      expect(a, hasLength(1));
      expect(b, hasLength(1));
      // The first stop of the stretch: boarding there reaches everything
      // downstream, and the stretch itself is served by A directly.
      expect(a.single.myStopIdx, 0);
      expect(a.single.otherStopIdx, 0);
      expect(a.single.walkMeters, closeTo(20, 1));
    });

    test('two separate crossings keep one connection each', () {
      // Line C crosses A near a0 and again near a4, far apart.
      final crossing = feed(
        stops: {
          ...stops,
          'c0': const GtfsStop(id: 'c0', name: 'c0', lat: -0.00018, lon: 0),
          'c1': const GtfsStop(id: 'c1', name: 'c1', lat: -0.02, lon: 0.0006),
          'c2': const GtfsStop(
            id: 'c2',
            name: 'c2',
            lat: -0.00018,
            lon: 0.0012,
          ),
        },
        routes: {'A': bus('A', '1'), 'C': bus('C', '3')},
        tripStops: {
          'A': ['a0', 'a1', 'a2', 'a3', 'a4'],
          'C': ['c0', 'c1', 'c2'],
        },
      );
      final index = GtfsRouteIndex(crossing);
      final a = index.getConnectionsFor(index.getPattern('A')!.id);
      expect(a.map((c) => c.myStopIdx), [0, 4]);
      expect(a.map((c) => c.otherStopIdx), [0, 2]);
    });
  });

  group('same-name rule', () {
    // A shared corridor: every line visits the hub stops h0 → h1 → h2.
    final hub = {
      'h0': const GtfsStop(id: 'h0', name: 'h0', lat: 0, lon: 0),
      'h1': const GtfsStop(id: 'h1', name: 'h1', lat: 0, lon: 0.010),
      'h2': const GtfsStop(id: 'h2', name: 'h2', lat: 0, lon: 0.020),
    };

    test(
      'Cochabamba: "209" as route_id 67 and 68 is one line — never chained',
      () {
        final data = feed(
          stops: hub,
          routes: {
            '67': bus('67', '209'),
            '68': bus('68', '209'),
            '12': bus('12', '110'),
          },
          tripStops: {
            '67': ['h0', 'h1', 'h2'],
            '68': ['h2', 'h1', 'h0'],
            '12': ['h0', 'h1', 'h2'],
          },
        );
        final index = GtfsRouteIndex(data);
        expect(index.lineKeyForRoute('67'), index.lineKeyForRoute('68'));
        expect(index.lineKeyForRoute('67'), isNot(index.lineKeyForRoute('12')));
        final pairs = connectedRoutePairs(index);
        expect(pairs, isNot(contains('67>68')));
        expect(pairs, isNot(contains('68>67')));
        expect(pairs, containsAll(['67>12', '12>67', '68>12', '12>68']));
      },
    );

    test('three route_ids sharing a name are still one line (the limit)', () {
      final data = feed(
        stops: hub,
        routes: {
          for (final id in ['a', 'b', 'c']) id: bus(id, '5'),
          'z': bus('z', '9'),
        },
        tripStops: {
          for (final id in ['a', 'b', 'c', 'z']) id: ['h0', 'h1', 'h2'],
        },
      );
      final pairs = connectedRoutePairs(GtfsRouteIndex(data));
      expect(
        pairs.where((p) => !p.contains('z')),
        isEmpty,
        reason: 'no 5 → 5 connection',
      );
      expect(pairs, containsAll(['a>z', 'z>a']));
    });

    test(
      'Sana\'a: a name carried by many routes is not a line — "7 → 7" allowed',
      () {
        final ids = ['r1', 'r2', 'r3', 'r4', 'r5'];
        final data = feed(
          stops: hub,
          routes: {for (final id in ids) id: bus(id, '7')},
          tripStops: {
            for (final id in ids) id: ['h0', 'h1', 'h2'],
          },
        );
        final index = GtfsRouteIndex(data);
        expect(index.lineKeyForRoute('r1'), isNot(index.lineKeyForRoute('r2')));
        final pairs = connectedRoutePairs(index);
        // 5 routes, all pairs both ways.
        expect(pairs, hasLength(5 * 4));
      },
    );

    test('the limit is configurable', () {
      final ids = ['r1', 'r2', 'r3', 'r4', 'r5'];
      final data = feed(
        stops: hub,
        routes: {for (final id in ids) id: bus(id, '7')},
        tripStops: {
          for (final id in ids) id: ['h0', 'h1', 'h2'],
        },
      );
      expect(GtfsRouteIndex(data, sameNameRouteLimit: 5).connectionCount, 0);
      expect(
        GtfsRouteIndex(data, sameNameRouteLimit: 4).connectionCount,
        greaterThan(0),
      );
    });

    test('same route_id is always one line, whatever its name', () {
      final data = feed(
        stops: hub,
        routes: {'x': bus('x', '')},
        tripStops: {
          'out': ['h0', 'h1', 'h2'],
          'back': ['h2', 'h1', 'h0'],
        },
        tripRoute: {'out': 'x', 'back': 'x'},
      );
      final index = GtfsRouteIndex(data);
      expect(index.patternCount, 2);
      expect(index.connectionCount, 0);
    });
  });

  group('columnar layout', () {
    // Line P passes p0 → p1 → p2. At p1 three other lines can be boarded:
    // Q at the same stop (walk 0), R 15 m away, S 60 m away. At p2 line T
    // boards at the same stop. Each of Q/R/S/T ends at its own far-away
    // terminal so they only meet around p1/p2.
    final stops = {
      'p0': const GtfsStop(id: 'p0', name: 'p0', lat: 0, lon: 0),
      'p1': const GtfsStop(id: 'p1', name: 'p1', lat: 0, lon: 0.010),
      'p2': const GtfsStop(id: 'p2', name: 'p2', lat: 0, lon: 0.020),
      'r0': const GtfsStop(id: 'r0', name: 'r0', lat: 0.000135, lon: 0.010),
      's0': const GtfsStop(id: 's0', name: 's0', lat: 0.00054, lon: 0.010),
      'farQ': const GtfsStop(id: 'farQ', name: 'farQ', lat: 0.05, lon: 0.05),
      'farR': const GtfsStop(id: 'farR', name: 'farR', lat: 0.05, lon: -0.05),
      'farS': const GtfsStop(id: 'farS', name: 'farS', lat: -0.05, lon: 0.05),
      'farT': const GtfsStop(id: 'farT', name: 'farT', lat: -0.05, lon: -0.05),
    };
    final data = feed(
      stops: stops,
      routes: {
        for (final id in ['P', 'Q', 'R', 'S', 'T']) id: bus(id, id),
      },
      tripStops: {
        'P': ['p0', 'p1', 'p2'],
        'Q': ['p1', 'farQ'],
        'R': ['r0', 'farR'],
        'S': ['s0', 'farS'],
        'T': ['p2', 'farT'],
      },
    );
    final index = GtfsRouteIndex(data);
    final conns = index.getConnectionsFor(index.getPattern('P')!.id);

    test('sorted by alight position, then by walk distance', () {
      expect(conns, hasLength(4));
      expect(conns.map((c) => c.myStopIdx), [1, 1, 1, 2]);
      expect(conns.map((c) => c.walkMeters).take(3), isSorted);
      expect(conns.map((c) => index.patternById(c.otherPatternId).routeId), [
        'Q',
        'R',
        'S',
        'T',
      ]);
      expect(conns[0].walkMeters, 0);
      expect(conns[1].walkMeters, closeTo(15, 1));
      expect(conns[2].walkMeters, closeTo(60, 1));
    });

    test('firstIndexAfter skips connections at or before a boarding stop', () {
      expect(conns.firstIndexAfter(-1), 0);
      expect(conns.firstIndexAfter(0), 0);
      expect(conns.firstIndexAfter(1), 3);
      expect(conns.firstIndexAfter(2), 4);
      expect(conns.firstIndexAfter(99), conns.length);
    });

    test('accessors agree with the materialised records', () {
      for (var i = 0; i < conns.length; i++) {
        expect(conns.otherPatternIdAt(i), conns[i].otherPatternId);
        expect(conns.myStopIdxAt(i), conns[i].myStopIdx);
        expect(conns.otherStopIdxAt(i), conns[i].otherStopIdx);
        expect(conns.walkMetersAt(i), conns[i].walkMeters);
      }
    });

    test('is read-only and safe for unknown patterns', () {
      expect(() => conns[0] = conns[1], throwsUnsupportedError);
      expect(() => conns.length = 0, throwsUnsupportedError);
      expect(index.getConnectionsFor(-1), isEmpty);
      expect(index.getConnectionsFor(999), isEmpty);
      // P: 4 (Q, R, S at p1; T at p2). Q, R, S: 3 each (the other two of
      // the p1 cluster + P). T: 1 (P at p2). Terminals are all distinct.
      expect(index.connectionCount, 4 + 3 * 3 + 1);
    });
  });

  group('GtfsSpatialIndex.findStopsInRadius', () {
    test('is an exact range query (no cap), nearest first', () {
      final stops = <String, GtfsStop>{
        for (var i = 0; i < 300; i++)
          's$i': GtfsStop(
            id: 's$i',
            name: 's$i',
            lat: 0.0001 * (i % 20) - 0.001,
            lon: 0.0001 * (i ~/ 20) - 0.00075,
          ),
      };
      final spatial = GtfsSpatialIndex(stops);
      const center = LatLng(0, 0);
      // Brute force with the index's own haversine (latlong2's `Distance`
      // rounds to whole meters, which shifts stops sitting on the edge).
      final expected = stops.values
          .where((s) => haversine(center, s.position) <= 100)
          .map((s) => s.id)
          .toSet();
      final got = spatial.findStopsInRadius(center, 100);
      expect(got.map((n) => n.stop.id).toSet(), expected);
      expect(expected.length, greaterThan(100), reason: 'the old cap was 100');
      expect(got.map((n) => n.distance), isSorted);
    });
  });
}

/// Great-circle distance in meters (same constants as the spatial index).
double haversine(LatLng a, LatLng b) {
  const r = 6371000.0;
  final dLat = (b.latitude - a.latitude) * pi / 180;
  final dLon = (b.longitude - a.longitude) * pi / 180;
  final h =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(a.latitude * pi / 180) *
          cos(b.latitude * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  return r * 2 * atan2(sqrt(h), sqrt(1 - h));
}

/// Matcher: an iterable of numbers in non-decreasing order.
const Matcher isSorted = _IsSorted();

class _IsSorted extends Matcher {
  const _IsSorted();

  @override
  bool matches(Object? item, Map matchState) {
    final list = (item as Iterable).cast<num>().toList();
    for (var i = 1; i < list.length; i++) {
      if (list[i] < list[i - 1]) return false;
    }
    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('sorted ascending');
}
