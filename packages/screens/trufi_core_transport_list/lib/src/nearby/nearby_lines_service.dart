import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

import 'nearby_geometry.dart';
import 'nearby_line.dart';
import 'nearby_radius.dart';

/// Pure-Dart spatial query over an already-loaded GTFS feed (#1006).
///
/// Runs on the calling isolate on purpose: the feed lives on the root
/// isolate after the planner's own preload, and shipping `GtfsData` to a
/// worker would copy the whole feed per query. The bbox prefilter plus the
/// axis reject in [NearbyGeometry] keep a query at tens of milliseconds on
/// the densest real feed (Cochabamba: 23.7k stops, 657 patterns).
class NearbyLinesService {
  NearbyLinesService({
    required this.data,
    required this.spatialIndex,
    required this.routeIndex,
    this.stopPreferenceMeters = defaultStopPreferenceMeters,
  });

  /// A pattern's shape runs through its own stops, so the geometry is
  /// almost always at least as close as the nearest stop. The literal rule
  /// "shape closer than stop ⇒ passes by" would therefore turn every row
  /// into "passes by" and hide boarding points. A row keeps its stop unless
  /// the line runs more than this many meters closer than that stop.
  static const double defaultStopPreferenceMeters = 50;

  final GtfsData data;
  final GtfsSpatialIndex spatialIndex;
  final GtfsRouteIndex routeIndex;
  final double stopPreferenceMeters;

  Map<String, String>? _agencyNames;
  Map<String, String>? _tripIds;

  /// Every logical line within [maxRadiusMeters] of [anchor], nearest first.
  NearbyLinesResult find(
    LatLng anchor, {
    double maxRadiusMeters = NearbyRadius.maxMeters,
  }) {
    final stopCandidates = _findStopCandidates(anchor, maxRadiusMeters);
    final shapeCandidates = _findShapeCandidates(anchor, maxRadiusMeters);

    final lines = <NearbyLine>[];
    final keys = {...stopCandidates.keys, ...shapeCandidates.keys};
    for (final key in keys) {
      final stop = stopCandidates[key];
      final shape = shapeCandidates[key];
      final line = _buildLine(key, stop, shape);
      if (line != null && line.distanceMeters <= maxRadiusMeters) {
        lines.add(line);
      }
    }
    lines.sort(NearbyLine.compare);

    return NearbyLinesResult(
      anchor: anchor,
      maxRadiusMeters: maxRadiusMeters,
      lines: lines,
    );
  }

  /// Shape (or stop sequence) and stops of the pattern behind [line]; null
  /// when the pattern is unknown or has no points at all.
  NearbyLineGeometry? geometryOf(NearbyLine line) {
    final pattern = _patternById(line.patternId);
    if (pattern == null) return null;
    final stops = <NearbyLineStop>[
      for (final id in pattern.stopIds)
        if (data.stops[id] case final stop?)
          NearbyLineStop(id: stop.id, name: stop.name, position: stop.position),
    ];
    final shape = pattern.shapeId == null ? null : data.shapes[pattern.shapeId];
    final polyline = shape != null && shape.points.isNotEmpty
        ? shape.polyline
        : [for (final stop in stops) stop.position];
    if (polyline.isEmpty) return null;
    return NearbyLineGeometry(polyline: polyline, stops: stops);
  }

  /// First trip of [pattern]'s route on its shape (with its headsign when
  /// several trips share the shape), for providers keyed by trip id.
  String? tripIdFor(RoutePattern pattern) {
    final index = _tripIds ??= _buildTripIndex();
    final shape = pattern.shapeId ?? '';
    return index['${pattern.routeId}|$shape|${pattern.headsign ?? ''}'] ??
        index['${pattern.routeId}|$shape'];
  }

  Map<String, _StopCandidate> _findStopCandidates(
    LatLng anchor,
    double maxRadiusMeters,
  ) {
    final candidates = <String, _StopCandidate>{};
    // Nearest first, so the first stop seen per line is its nearest stop.
    for (final near in spatialIndex.findStopsInRadius(
      anchor,
      maxRadiusMeters,
    )) {
      for (final pattern in routeIndex.getPatternsAtStop(near.stop.id)) {
        candidates.putIfAbsent(
          routeIndex.lineKeyForRoute(pattern.routeId),
          () => _StopCandidate(pattern, near.stop, near.distance),
        );
      }
    }
    return candidates;
  }

  Map<String, _ShapeCandidate> _findShapeCandidates(
    LatLng anchor,
    double maxRadiusMeters,
  ) {
    final candidates = <String, _ShapeCandidate>{};
    for (final pattern in routeIndex.patterns) {
      // O(1) bbox prefilter: exact maths only for patterns whose stops come
      // within the radius (bbox-less patterns cannot be pruned and pass).
      if (!pattern.nearPoint(
        anchor.latitude,
        anchor.longitude,
        maxRadiusMeters,
      )) {
        continue;
      }
      final nearest = _nearestOnPattern(anchor, pattern, maxRadiusMeters);
      if (nearest.distanceMeters > maxRadiusMeters) continue;
      final key = routeIndex.lineKeyForRoute(pattern.routeId);
      final current = candidates[key];
      final better =
          current == null ||
          nearest.distanceMeters < current.distance ||
          (nearest.distanceMeters == current.distance &&
              pattern.id < current.pattern.id);
      if (better) {
        candidates[key] = _ShapeCandidate(
          pattern,
          nearest.distanceMeters,
          nearest.point,
        );
      }
    }
    return candidates;
  }

  NearestOnPolyline _nearestOnPattern(
    LatLng anchor,
    RoutePattern pattern,
    double maxRadiusMeters,
  ) {
    final shape = pattern.shapeId == null ? null : data.shapes[pattern.shapeId];
    if (shape != null && shape.points.isNotEmpty) {
      return NearbyGeometry.nearestOnPath(
        anchor,
        shape.points,
        _shapePointLatitude,
        _shapePointLongitude,
        maxMeters: maxRadiusMeters,
      );
    }
    final stops = <GtfsStop>[for (final id in pattern.stopIds) ?data.stops[id]];
    return NearbyGeometry.nearestOnPath(
      anchor,
      stops,
      _stopLatitude,
      _stopLongitude,
      maxMeters: maxRadiusMeters,
    );
  }

  NearbyLine? _buildLine(
    String lineKey,
    _StopCandidate? stop,
    _ShapeCandidate? shape,
  ) {
    final passes =
        stop == null ||
        (shape != null &&
            stop.distance - shape.distance > stopPreferenceMeters);
    final RoutePattern pattern;
    final double distance;
    final LatLng nearestPoint;
    if (passes) {
      // `passes` implies a shape candidate: a line with no stop candidate
      // only enters the merge through its shape.
      final winner = shape!;
      pattern = winner.pattern;
      distance = winner.distance;
      nearestPoint = winner.point;
    } else {
      pattern = stop.pattern;
      distance = stop.distance;
      nearestPoint = stop.stop.position;
    }

    final route = data.routes[pattern.routeId];
    if (route == null) return null;
    final agencyId = route.agencyId;
    return NearbyLine(
      lineKey: lineKey,
      routeId: route.id,
      patternId: pattern.id,
      shapeId: pattern.shapeId,
      tripId: tripIdFor(pattern),
      shortName: route.shortName,
      longName: route.longName,
      headsign: pattern.headsign,
      color: parseGtfsColorHex(route.colorHex),
      textColor: parseGtfsColorHex(route.textColorHex),
      routeType: route.type,
      distanceMeters: distance,
      kind: passes ? NearbyMatchKind.passes : NearbyMatchKind.stop,
      stopId: passes ? null : stop.stop.id,
      stopName: passes ? null : stop.stop.name,
      nearestPoint: nearestPoint,
      agencyName: agencyId == null ? null : _agencyNameById[agencyId],
    );
  }

  Map<String, String> get _agencyNameById => _agencyNames ??= {
    for (final agency in data.agencies) agency.id: agency.name,
  };

  Map<String, String> _buildTripIndex() {
    final index = <String, String>{};
    for (final trip in data.trips.values) {
      final shape = trip.shapeId ?? '';
      index.putIfAbsent('${trip.routeId}|$shape', () => trip.id);
      index.putIfAbsent(
        '${trip.routeId}|$shape|${trip.headsign ?? ''}',
        () => trip.id,
      );
    }
    return index;
  }

  RoutePattern? _patternById(int id) => id >= 0 && id < routeIndex.patternCount
      ? routeIndex.patternById(id)
      : null;

  static double _shapePointLatitude(GtfsShapePoint point) => point.lat;

  static double _shapePointLongitude(GtfsShapePoint point) => point.lon;

  static double _stopLatitude(GtfsStop stop) => stop.lat;

  static double _stopLongitude(GtfsStop stop) => stop.lon;
}

class _StopCandidate {
  const _StopCandidate(this.pattern, this.stop, this.distance);

  final RoutePattern pattern;
  final GtfsStop stop;
  final double distance;
}

class _ShapeCandidate {
  const _ShapeCandidate(this.pattern, this.distance, this.point);

  final RoutePattern pattern;
  final double distance;
  final LatLng point;
}
