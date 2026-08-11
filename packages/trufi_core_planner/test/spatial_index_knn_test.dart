import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// #977: the KD-tree's k-NN evicted an arbitrary element once the result
/// list filled (it was never kept sorted), so `findNearestStops(k)` could
/// miss most of the true k nearest — 34 of 60 on the real Sana'a feed —
/// and its reach was non-monotonic in k. These tests pin correctness
/// against brute force and the monotonicity that callers implicitly rely
/// on (#974's candidate pool).
void main() {
  // Same haversine the index uses (latlong2's default is Vincenty, which
  // differs by ~1 m — enough to break exact rank comparisons).
  double haversine(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(a.latitude * math.pi / 180) *
            math.cos(b.latitude * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  // Deterministic pseudo-random stop field: ~2,000 stops in a ~11×11 km
  // box with clusters (mimics a dense downtown + sparse periphery).
  final stops = <String, GtfsStop>{};
  var seed = 12345;
  double next() {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed / 0x7fffffff;
  }

  for (var i = 0; i < 1500; i++) {
    stops['u$i'] = GtfsStop(
      id: 'u$i',
      name: 'u$i',
      lat: next() * 0.1,
      lon: next() * 0.1,
    );
  }
  // Dense cluster: 500 stops inside ~600 m around (0.05, 0.05).
  for (var i = 0; i < 500; i++) {
    stops['d$i'] = GtfsStop(
      id: 'd$i',
      name: 'd$i',
      lat: 0.05 + (next() - 0.5) * 0.01,
      lon: 0.05 + (next() - 0.5) * 0.01,
    );
  }

  final index = GtfsSpatialIndex(stops);

  List<MapEntry<String, double>> bruteForce(
    LatLng p,
    int k,
    double maxMeters,
  ) {
    final all = stops.values
        .map((s) => MapEntry(s.id, haversine(p, LatLng(s.lat, s.lon))))
        .where((e) => e.value <= maxMeters)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return all.take(k).toList();
  }

  test('k-NN matches brute force on 100 query points (k=10 and k=60)', () {
    for (var q = 0; q < 100; q++) {
      final p = LatLng(next() * 0.1, next() * 0.1);
      for (final k in [10, 60]) {
        final got = index.findNearestStops(p, maxResults: k, maxDistance: 1500);
        final want = bruteForce(p, k, 1500);
        expect(got.length, want.length,
            reason: 'point $q k=$k: result count');
        for (var i = 0; i < got.length; i++) {
          // Distances must agree; ids can differ only on exact ties.
          expect(got[i].distance, closeTo(want[i].value, 0.5),
              reason: 'point $q k=$k rank $i');
        }
      }
    }
  });

  test('reach is monotonically non-decreasing in k (dense cluster)', () {
    final p = const LatLng(0.05, 0.05);
    double reach(int k) {
      final r = index.findNearestStops(p, maxResults: k, maxDistance: 1500);
      return r.isEmpty ? 0 : r.last.distance;
    }

    var prev = 0.0;
    for (final k in [20, 40, 60, 80, 120, 150]) {
      final r = reach(k);
      expect(r, greaterThanOrEqualTo(prev),
          reason: 'reach(k=$k)=$r must not shrink');
      prev = r;
    }
  });

  test('results come back sorted by distance', () {
    final r = index.findNearestStops(
      const LatLng(0.05, 0.05),
      maxResults: 100,
      maxDistance: 1500,
    );
    for (var i = 1; i < r.length; i++) {
      expect(r[i].distance, greaterThanOrEqualTo(r[i - 1].distance));
    }
  });
}
