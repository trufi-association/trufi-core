import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Closest point of a polyline to an anchor and how far it is.
typedef NearestOnPolyline = ({double distanceMeters, LatLng point});

/// Planar geometry for the nearby-lines search.
///
/// Everything here works on an equirectangular projection centred on the
/// anchor: at the 500 m the search cares about, the error against a
/// geodesic is millimetres, and the maths is a handful of multiplications
/// per point — the search walks hundreds of thousands of shape points per
/// query on a dense feed, so trigonometry per point is not an option.
abstract final class NearbyGeometry {
  /// Meters per degree of latitude (`2πR / 360`, R = 6 371 km — the radius
  /// the planner's spatial index uses, so both agree on distances).
  static const double metersPerDegree = 111195.0;

  /// Closest point of [polyline] to [anchor].
  ///
  /// [maxMeters] bounds the search: segments that cannot come closer are
  /// skipped without any maths, and when nothing is within it (or the
  /// polyline is empty) the result is `distanceMeters: double.infinity`
  /// with [anchor] as the point.
  static NearestOnPolyline nearestOnPolyline(
    LatLng anchor,
    List<LatLng> polyline, {
    double maxMeters = double.infinity,
  }) => nearestOnPath(
    anchor,
    polyline,
    _latitudeOf,
    _longitudeOf,
    maxMeters: maxMeters,
  );

  /// [nearestOnPolyline] over any point type.
  ///
  /// GTFS shapes are stored as `GtfsShapePoint`s; reading them through
  /// [latitudeOf] / [longitudeOf] avoids materialising a `LatLng` per point
  /// per query (a `GtfsShape.polyline` call allocates the whole list).
  static NearestOnPolyline nearestOnPath<T>(
    LatLng anchor,
    List<T> path,
    double Function(T point) latitudeOf,
    double Function(T point) longitudeOf, {
    double maxMeters = double.infinity,
  }) {
    final none = (distanceMeters: double.infinity, point: anchor);
    if (path.isEmpty) return none;

    final lat0 = anchor.latitude;
    final lon0 = anchor.longitude;
    final kx = metersPerDegree * math.cos(lat0 * math.pi / 180);
    const ky = metersPerDegree;

    // The anchor is the origin: every point projects to meters east/north.
    var px = (longitudeOf(path[0]) - lon0) * kx;
    var py = (latitudeOf(path[0]) - lat0) * ky;

    var best = maxMeters;
    var bestSq = maxMeters * maxMeters;
    double? bestX;
    double? bestY;

    if (path.length == 1) {
      final d2 = px * px + py * py;
      if (d2 > bestSq) return none;
      return (
        distanceMeters: math.sqrt(d2),
        point: LatLng(latitudeOf(path[0]), longitudeOf(path[0])),
      );
    }

    for (var i = 1; i < path.length; i++) {
      final qx = (longitudeOf(path[i]) - lon0) * kx;
      final qy = (latitudeOf(path[i]) - lat0) * ky;

      // Axis reject: a segment whose both ends lie beyond the best distance
      // on the same side cannot contain a closer point.
      final skip =
          (px > best && qx > best) ||
          (px < -best && qx < -best) ||
          (py > best && qy > best) ||
          (py < -best && qy < -best);
      if (!skip) {
        final dx = qx - px;
        final dy = qy - py;
        final len2 = dx * dx + dy * dy;
        var t = 0.0;
        if (len2 > 0) {
          t = (-(px * dx + py * dy) / len2).clamp(0.0, 1.0);
        }
        final cx = px + t * dx;
        final cy = py + t * dy;
        final d2 = cx * cx + cy * cy;
        if (d2 < bestSq) {
          bestSq = d2;
          best = math.sqrt(d2);
          bestX = cx;
          bestY = cy;
        }
      }
      px = qx;
      py = qy;
    }

    if (bestX == null || bestY == null) return none;
    return (
      distanceMeters: best,
      point: LatLng(lat0 + bestY / ky, lon0 + bestX / kx),
    );
  }

  /// Closed ring (first point repeated last) approximating the circle of
  /// [radiusMeters] around [center] with [segments] straight edges.
  static List<LatLng> circlePolygon(
    LatLng center,
    double radiusMeters, {
    int segments = 72,
  }) {
    final lat0 = center.latitude;
    final lon0 = center.longitude;
    final dLat = radiusMeters / metersPerDegree;
    final dLon =
        radiusMeters / (metersPerDegree * math.cos(lat0 * math.pi / 180));
    final ring = <LatLng>[
      for (var i = 0; i < segments; i++)
        LatLng(
          lat0 + dLat * math.cos(2 * math.pi * i / segments),
          lon0 + dLon * math.sin(2 * math.pi * i / segments),
        ),
    ];
    ring.add(ring.first);
    return ring;
  }

  static double _latitudeOf(LatLng point) => point.latitude;

  static double _longitudeOf(LatLng point) => point.longitude;
}
