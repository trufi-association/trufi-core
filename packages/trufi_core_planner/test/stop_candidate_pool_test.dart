import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// #974: with a candidate pool of 60, a dense downtown query only saw
/// stops within a few hundred meters regardless of the walk radius,
/// hiding valid boarding points. These tests pin the fixed behavior
/// (pool of 150 by default) and guard the query cost across the network
/// shapes we actually operate: dense grids (Cochabamba), fragmented
/// per-trip variants (route 212), star hubs, and the Sana'a dense-center
/// shape that motivated the issue.
///
/// Timing ceilings are deliberately loose — they exist to catch
/// order-of-magnitude regressions (an accidental O(n²) turns
/// milliseconds into seconds), not micro-variance between machines.
void main() {
  const distance = Distance();

  // ~111 m per 0.001° at the equator.
  LatLng at(double lat, double lon) => LatLng(lat, lon);

  GtfsRoutingService buildService(_Network net) {
    final data = GtfsData(
      agencies: const [],
      stops: net.stops,
      routes: net.routes,
      trips: net.trips,
      stopTimes: net.stopTimes,
      calendars: const {},
      calendarDates: const [],
      frequencies: const [],
      shapes: const {},
    );
    return GtfsRoutingService(
      data: data,
      spatialIndex: GtfsSpatialIndex(data.stops),
      routeIndex: GtfsRouteIndex(data),
    );
  }

  group('the Sana\'a shape: dense center hides the connecting line', () {
    // Periphery origin O served only by line A. Line A reaches hub H.
    // Line B goes H → T, where T sits ~440 m from the destination point —
    // but 100 noise stops (5 rings of 20, all within ~330 m, served by
    // 20 unconnected two-stop lines) rank closer. With the old pool of 60
    // the destination candidates were noise only and the query returned
    // nothing; with 150 the pool reaches T and the A→B transfer exists.
    final net = _Network();

    final origin = at(0, 0);
    final destPoint = at(0.05, 0);

    net.addStop('O', 0, 0);
    net.addStop('H', 0.02, 0);
    net.addStop('T', 0.05, 0.004);
    net.addStop('B2', 0.05, 0.010);

    net.addRoute('A', ['O', 'H']);
    net.addRoute('B', ['H', 'T', 'B2']);

    for (var ring = 0; ring < 5; ring++) {
      final r = 0.001 + ring * 0.0005; // 110–330 m
      for (var i = 0; i < 20; i++) {
        final angle = i * 18.0;
        final id = 'N$ring-$i';
        net.addStop(
          id,
          0.05 + r * _cos(angle),
          0 + r * _sin(angle),
        );
      }
    }
    // Noise stops get their own tiny lines so they are transit stops,
    // but none connects to A or B.
    for (var ring = 0; ring < 5; ring++) {
      for (var i = 0; i < 20; i += 2) {
        net.addRoute('noise$ring-$i', ['N$ring-$i', 'N$ring-${i + 1}']);
      }
    }

    final service = buildService(net);

    test('defaults find the transfer through the far boarding stop', () {
      final paths = service.findRoutes(
        origin: origin,
        destination: destPoint,
        maxWalkDistance: 1500,
        maxResults: 5,
      );
      expect(paths, isNotEmpty,
          reason: 'A→B via H must be reachable with the default pool');
      expect(
        paths.first.segments.map((s) => s.route.shortName).toList(),
        ['A', 'B'],
      );
    });

    test('the old pool of 60 reproduces the bug (kept as documentation)', () {
      final paths = service.findRoutes(
        origin: origin,
        destination: destPoint,
        maxWalkDistance: 1500,
        maxResults: 5,
        maxStopCandidates: 60,
      );
      expect(paths, isEmpty,
          reason: 'with 60 candidates the dest pool is noise-only — '
              'this is exactly what #974 reported');
    });
  });

  group('dense grid (the Cochabamba shape)', () {
    // 40×40 grid (1,600 stops, ~110 m spacing). Every row and every
    // column is a route: 80 routes crossing everywhere.
    final net = _Network();
    const n = 40;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        net.addStop('g$r-$c', r * 0.001, c * 0.001);
      }
    }
    for (var r = 0; r < n; r++) {
      net.addRoute('row$r', [for (var c = 0; c < n; c++) 'g$r-$c']);
    }
    for (var c = 0; c < n; c++) {
      net.addRoute('col$c', [for (var r = 0; r < n; r++) 'g$r-$c']);
    }

    final service = buildService(net);

    test('30 cross-city queries stay fast and always find a path', () {
      var totalMs = 0;
      var maxMs = 0;
      for (var i = 0; i < 30; i++) {
        final from = at((i % n) * 0.001, 0.0015);
        final to = at(0.0195, ((i * 7) % n) * 0.001);
        final sw = Stopwatch()..start();
        final paths = service.findRoutes(
          origin: from,
          destination: to,
          maxWalkDistance: 1500,
          maxResults: 5,
        );
        sw.stop();
        totalMs += sw.elapsedMilliseconds;
        if (sw.elapsedMilliseconds > maxMs) maxMs = sw.elapsedMilliseconds;
        expect(paths, isNotEmpty, reason: 'grid is fully connected');
      }
      final avg = totalMs / 30;
      // Locally ~3-5 ms; ceilings catch complexity blowups only.
      expect(avg, lessThan(150), reason: 'avg=${avg.toStringAsFixed(1)}ms');
      expect(maxMs, lessThan(750), reason: 'max=${maxMs}ms');
      // For the record in test logs:
      // ignore: avoid_print
      print('grid: avg=${avg.toStringAsFixed(1)}ms max=${maxMs}ms');
    });
  });

  group('fragmented corridor (the route-212 shape: 40 trip variants)', () {
    // One corridor of 60 stops. 40 trips of the same route, each skipping
    // a different pair of interleaved stops — mirrors Cochabamba's route
    // 212 with its 46 near-identical patterns. Plus 10 cross routes.
    final net = _Network();
    for (var i = 0; i < 60; i++) {
      net.addStop('c$i', 0, i * 0.001);
    }
    for (var v = 0; v < 40; v++) {
      final skip1 = 5 + v;
      final skip2 = 10 + v;
      net.addTripVariant('corr', 'corridor', [
        for (var i = 0; i < 60; i++)
          if (i != skip1 && i != skip2) 'c$i',
      ]);
    }
    for (var x = 0; x < 10; x++) {
      final base = x * 6;
      net.addStop('x$x-a', 0.001, base * 0.001);
      net.addStop('x$x-b', 0.002, base * 0.001);
      net.addRoute('cross$x', ['c$base', 'x$x-a', 'x$x-b']);
    }

    final service = buildService(net);

    test('direct along the corridor is found and fast despite 40 patterns',
        () {
      final sw = Stopwatch()..start();
      final paths = service.findRoutes(
        origin: at(0, 0.0005),
        destination: at(0, 0.0555),
        maxWalkDistance: 1500,
        maxResults: 5,
      );
      sw.stop();
      expect(paths, isNotEmpty);
      expect(paths.first.segments, hasLength(1),
          reason: 'a direct corridor ride must win');
      expect(sw.elapsedMilliseconds, lessThan(750),
          reason: 'took ${sw.elapsedMilliseconds}ms');
      // ignore: avoid_print
      print('fragmented corridor: ${sw.elapsedMilliseconds}ms');
    });
  });

  group('star hub (worst-case connection density)', () {
    // 60 routes all passing through one central stop: the connection
    // list at the hub is ~maximal. The enumeration cap must keep the
    // query bounded.
    final net = _Network();
    net.addStop('HUB', 0.02, 0.02);
    for (var s = 0; s < 60; s++) {
      final angle = s * 6.0;
      net.addStop('s$s-1', 0.02 + 0.01 * _cos(angle), 0.02 + 0.01 * _sin(angle));
      net.addStop('s$s-2', 0.02 + 0.02 * _cos(angle), 0.02 + 0.02 * _sin(angle));
      net.addRoute('spoke$s', ['s$s-2', 's$s-1', 'HUB']);
      // Return direction as a second pattern of the same route, so
      // hub-outbound rides exist (sequences encode direction).
      net.addTripVariant('r_spoke$s', 'spoke$s', ['HUB', 's$s-1', 's$s-2']);
    }
    final service = buildService(net);

    test('spoke-to-spoke through the hub stays bounded', () {
      var totalMs = 0;
      for (var i = 0; i < 20; i++) {
        final sw = Stopwatch()..start();
        final paths = service.findRoutes(
          origin: at(0.02 + 0.02 * _cos(i * 18.0), 0.02 + 0.02 * _sin(i * 18.0)),
          destination: at(
            0.02 + 0.02 * _cos((i * 18.0 + 180) % 360),
            0.02 + 0.02 * _sin((i * 18.0 + 180) % 360),
          ),
          maxWalkDistance: 1500,
          maxResults: 5,
        );
        sw.stop();
        totalMs += sw.elapsedMilliseconds;
        expect(paths, isNotEmpty, reason: 'hub connects every spoke pair');
      }
      final avg = totalMs / 20;
      expect(avg, lessThan(150), reason: 'avg=${avg.toStringAsFixed(1)}ms');
      // ignore: avoid_print
      print('star hub: avg=${avg.toStringAsFixed(1)}ms');
    });
  });

  group('radius interplay', () {
    // Larger radius must never find fewer paths, and both must stay fast.
    final net = _Network();
    for (var i = 0; i < 30; i++) {
      net.addStop('l$i', 0, i * 0.001);
    }
    net.addRoute('L', [for (var i = 0; i < 30; i++) 'l$i']);
    final service = buildService(net);

    test('paths(1500m) >= paths(500m)', () {
      final near = service.findRoutes(
        origin: at(0.006, 0), // ~665 m from the line
        destination: at(0, 0.029),
        maxWalkDistance: 500,
        maxResults: 5,
      );
      final far = service.findRoutes(
        origin: at(0.006, 0),
        destination: at(0, 0.029),
        maxWalkDistance: 1500,
        maxResults: 5,
      );
      expect(near, isEmpty, reason: 'origin is beyond 500 m of any stop');
      expect(far, isNotEmpty);
      expect(far.length, greaterThanOrEqualTo(near.length));
      expect(
        distance.as(
          LengthUnit.Meter,
          at(0.006, 0),
          net.stops['l0']!.position,
        ),
        greaterThan(500),
      );
    });
  });
}

// Minimal deterministic trig (degrees) to avoid importing dart:math with
// doubles that vary — precision is irrelevant for stop placement.
double _cos(double deg) => _cosTable[(deg.round() % 360 + 360) % 360];
double _sin(double deg) => _cosTable[(450 - deg.round()) % 360];
final _cosTable = List.generate(360, (d) {
  const pi = 3.141592653589793;
  final r = d * pi / 180;
  var t = 1.0, s = 1.0;
  for (var i = 1; i <= 10; i++) {
    t *= -r * r / ((2 * i - 1) * (2 * i));
    s += t;
  }
  return s;
});

/// Tiny builder for synthetic networks in the GtfsData shape.
class _Network {
  final stops = <String, GtfsStop>{};
  final routes = <String, GtfsRoute>{};
  final trips = <String, GtfsTrip>{};
  final stopTimes = <GtfsStopTime>[];
  var _tripSeq = 0;

  void addStop(String id, double lat, double lon) {
    stops[id] = GtfsStop(id: id, name: id, lat: lat, lon: lon);
  }

  void addRoute(String shortName, List<String> stopIds) {
    final rid = 'r_$shortName';
    routes[rid] = GtfsRoute(
      id: rid,
      shortName: shortName,
      longName: shortName,
      type: GtfsRouteType.bus,
    );
    _addTrip(rid, stopIds);
  }

  /// Adds another trip (pattern variant) to an existing or new route.
  void addTripVariant(String routeId, String shortName, List<String> stopIds) {
    routes.putIfAbsent(
      routeId,
      () => GtfsRoute(
        id: routeId,
        shortName: shortName,
        longName: shortName,
        type: GtfsRouteType.bus,
      ),
    );
    _addTrip(routeId, stopIds);
  }

  void _addTrip(String routeId, List<String> stopIds) {
    final tid = 't${_tripSeq++}';
    trips[tid] = GtfsTrip(id: tid, routeId: routeId, serviceId: 's');
    for (var i = 0; i < stopIds.length; i++) {
      stopTimes.add(
        GtfsStopTime(tripId: tid, stopId: stopIds[i], stopSequence: i + 1),
      );
    }
  }
}
