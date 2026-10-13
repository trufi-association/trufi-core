import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// Haversine with the planner's earth radius (6 371 km), the reference the
/// equirectangular projection is checked against.
double haversine(LatLng a, LatLng b) {
  const r = 6371000.0;
  final dLat = (b.latitude - a.latitude) * math.pi / 180;
  final dLon = (b.longitude - a.longitude) * math.pi / 180;
  final h =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(a.latitude * math.pi / 180) *
          math.cos(b.latitude * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return r * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
}

void main() {
  const anchor = LatLng(0, 0);

  group('nearestOnPolyline', () {
    test('finds the perpendicular foot on a segment that passes by', () {
      // 0.0009° of latitude ≈ 100.1 m north of the anchor.
      final nearest = NearbyGeometry.nearestOnPolyline(anchor, const [
        LatLng(0.0009, -0.01),
        LatLng(0.0009, 0.01),
      ]);
      expect(nearest.distanceMeters, closeTo(100.1, 0.5));
      expect(nearest.point.latitude, closeTo(0.0009, 1e-9));
      expect(nearest.point.longitude, closeTo(0, 1e-9));
    });

    test('clamps to the endpoint when the anchor is beyond it', () {
      const end = LatLng(0.001, 0.001);
      final nearest = NearbyGeometry.nearestOnPolyline(anchor, const [
        end,
        LatLng(0.002, 0.002),
      ]);
      expect(nearest.distanceMeters, closeTo(haversine(anchor, end), 0.05));
      expect(nearest.point.latitude, closeTo(end.latitude, 1e-9));
      expect(nearest.point.longitude, closeTo(end.longitude, 1e-9));
    });

    test('empty polyline is infinitely far and single point is a point', () {
      final none = NearbyGeometry.nearestOnPolyline(anchor, const []);
      expect(none.distanceMeters, double.infinity);
      expect(none.point, anchor);

      const only = LatLng(0.0009, 0);
      final single = NearbyGeometry.nearestOnPolyline(anchor, const [only]);
      expect(single.distanceMeters, closeTo(100.1, 0.5));
      expect(single.point, only);
    });

    test('maxMeters bounds the search', () {
      const polyline = [LatLng(0.0009, -0.01), LatLng(0.0009, 0.01)];
      final beyond = NearbyGeometry.nearestOnPolyline(
        anchor,
        polyline,
        maxMeters: 50,
      );
      expect(beyond.distanceMeters, double.infinity);
      expect(beyond.point, anchor);

      final within = NearbyGeometry.nearestOnPolyline(
        anchor,
        polyline,
        maxMeters: 150,
      );
      expect(within.distanceMeters, closeTo(100.1, 0.5));
    });

    test('axis reject never drops the segment that comes closest', () {
      // A far vertical segment 1.1 km east, then a horizontal one 10 m north
      // whose endpoints straddle the anchor east and west.
      final nearest = NearbyGeometry.nearestOnPolyline(anchor, const [
        LatLng(-0.01, 0.01),
        LatLng(0.01, 0.01),
        LatLng(0.00009, 0.01),
        LatLng(0.00009, -0.01),
      ]);
      expect(nearest.distanceMeters, closeTo(10.0, 0.1));
      expect(nearest.point.longitude, closeTo(0, 1e-9));

      // A segment running straight through the anchor: both ends are far,
      // on opposite sides — it must be evaluated, not rejected.
      final through = NearbyGeometry.nearestOnPolyline(anchor, const [
        LatLng(0, -0.01),
        LatLng(0, 0.01),
      ], maxMeters: 500);
      expect(through.distanceMeters, closeTo(0, 1e-6));
    });

    test('nearestOnPath reads any point type through accessors', () {
      final path = [(lat: 0.0009, lon: -0.01), (lat: 0.0009, lon: 0.01)];
      final nearest = NearbyGeometry.nearestOnPath(
        anchor,
        path,
        (p) => p.lat,
        (p) => p.lon,
      );
      expect(nearest.distanceMeters, closeTo(100.1, 0.5));
    });
  });

  group('circlePolygon', () {
    test('is a closed ring of points on the circle', () {
      const center = LatLng(-17.39, -66.15);
      final ring = NearbyGeometry.circlePolygon(center, 300);
      expect(ring, hasLength(73));
      expect(ring.first, ring.last);
      for (final point in ring) {
        expect(haversine(center, point), closeTo(300, 0.5));
      }
    });

    test('honours the segment count', () {
      final ring = NearbyGeometry.circlePolygon(anchor, 100, segments: 8);
      expect(ring, hasLength(9));
      expect(ring.first, ring.last);
    });
  });
}
