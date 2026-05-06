import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../models/gtfs_route.dart';
import '../models/gtfs_stop.dart';
import '../parser/gtfs_parser.dart';
import '../index/gtfs_spatial_index.dart';
import '../index/gtfs_route_index.dart';

/// A segment of a routing path (one transit leg).
class RoutingSegment {
  final GtfsRoute route;
  final GtfsStop fromStop;
  final GtfsStop toStop;
  final int stopCount;
  final List<GtfsStop> stops;
  final RoutePattern pattern;
  final Duration? scheduledDuration;

  /// Shape polyline points for this segment (road geometry).
  /// Empty during routing; resolved for final results only.
  final List<LatLng> shapePoints;

  /// Approximate in-vehicle distance along the pattern's stops, in meters.
  /// Computed in O(1) via the pattern's precomputed `cumDist`.
  final double transitDistance;

  const RoutingSegment({
    required this.route,
    required this.fromStop,
    required this.toStop,
    required this.stopCount,
    required this.stops,
    required this.pattern,
    this.scheduledDuration,
    this.shapePoints = const [],
    this.transitDistance = 0,
  });

  /// Stop IDs for this segment (derived from stops).
  List<String> get stopIds => stops.map((s) => s.id).toList();

  factory RoutingSegment.fromJson(Map<String, dynamic> json) {
    final durationSeconds = json['scheduledDuration'] as int?;
    final shapeRaw = json['shape'] as List?;
    final route = GtfsRoute.fromJson(json['route'] as Map<String, dynamic>);
    final stops = (json['stops'] as List)
        .map((s) => GtfsStop.fromJson(s as Map<String, dynamic>))
        .toList();
    return RoutingSegment(
      route: route,
      fromStop: GtfsStop.fromJson(json['from'] as Map<String, dynamic>),
      toStop: GtfsStop.fromJson(json['to'] as Map<String, dynamic>),
      stopCount: json['stopCount'] as int,
      stops: stops,
      pattern: RoutePattern(
        routeId: route.id,
        stopIds: stops.map((s) => s.id).toList(),
        headsign: json['headsign'] as String?,
      ),
      scheduledDuration: durationSeconds != null
          ? Duration(seconds: durationSeconds)
          : null,
      shapePoints:
          shapeRaw
              ?.map((p) => LatLng((p as List)[0] as double, p[1] as double))
              .toList() ??
          const [],
      transitDistance: (json['transitDistance'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Headsign for display (from pattern).
  String? get headsign => pattern.headsign;

  Map<String, dynamic> toJson() => {
    'route': route.toJson(),
    'from': fromStop.toJson(),
    'to': toStop.toJson(),
    'stopCount': stopCount,
    'stops': stops.map((s) => s.toJson()).toList(),
    if (pattern.headsign != null) 'headsign': pattern.headsign,
    'scheduledDuration': scheduledDuration?.inSeconds,
    if (shapePoints.isNotEmpty)
      'shape': shapePoints.map((p) => [p.latitude, p.longitude]).toList(),
    if (transitDistance > 0) 'transitDistance': transitDistance,
  };
}

/// A complete routing path result.
class RoutingPath {
  final double originWalkDistance;
  final GtfsStop originStop;
  final List<RoutingSegment> segments;
  final GtfsStop destinationStop;
  final double destinationWalkDistance;
  final double score;

  const RoutingPath({
    required this.originWalkDistance,
    required this.originStop,
    required this.segments,
    required this.destinationStop,
    required this.destinationWalkDistance,
    required this.score,
  });

  /// Total walk distance in meters.
  double get totalWalkDistance => originWalkDistance + destinationWalkDistance;

  /// Number of transfers.
  int get transfers => segments.isEmpty ? 0 : segments.length - 1;

  /// Total number of stops.
  int get totalStops => segments.fold(0, (sum, seg) => sum + seg.stopCount);

  /// Total in-vehicle distance across all transit segments, in meters.
  double get totalTransitDistance =>
      segments.fold(0, (sum, seg) => sum + seg.transitDistance);

  factory RoutingPath.fromJson(Map<String, dynamic> json) {
    return RoutingPath(
      originWalkDistance: (json['originWalk'] as num).toDouble(),
      originStop: GtfsStop.fromJson(json['originStop'] as Map<String, dynamic>),
      segments: (json['segments'] as List)
          .map((s) => RoutingSegment.fromJson(s as Map<String, dynamic>))
          .toList(),
      destinationStop: GtfsStop.fromJson(
        json['destinationStop'] as Map<String, dynamic>,
      ),
      destinationWalkDistance: (json['destinationWalk'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'originWalk': originWalkDistance,
    'originStop': originStop.toJson(),
    'segments': segments.map((s) => s.toJson()).toList(),
    'destinationStop': destinationStop.toJson(),
    'destinationWalk': destinationWalkDistance,
    'totalWalk': totalWalkDistance,
    'transfers': transfers,
    'totalStops': totalStops,
    'score': score,
  };
}

/// Service for GTFS-based routing.
class GtfsRoutingService {
  final GtfsData data;
  final GtfsSpatialIndex spatialIndex;
  final GtfsRouteIndex routeIndex;

  GtfsRoutingService({
    required this.data,
    required this.spatialIndex,
    required this.routeIndex,
  });

  /// Find routes between two locations.
  /// Supports direct routes and routes with 1 transfer.
  ///
  /// Results are returned in two buckets back-to-back:
  ///   1. up to [maxDirects] zero-transfer paths (best by score)
  ///   2. up to [maxTransferPaths] one-transfer paths (best by score)
  /// Direct routes always come first in the returned list.
  ///
  /// [maxResults] is kept as a backwards-compatible upper bound — the final
  /// list is truncated to it. Pass it >= maxDirects + maxTransferPaths to
  /// keep the bucket caps decisive.
  List<RoutingPath> findRoutes({
    required LatLng origin,
    required LatLng destination,
    double maxWalkDistance = 500,
    int maxResults = 10,
    int maxTransfers = 1,
    int maxDirects = 5,
    int maxTransferPaths = 5,
  }) {
    final originStops = spatialIndex.findNearestStops(
      origin,
      maxResults: 10,
      maxDistance: maxWalkDistance,
    );

    final destinationStops = spatialIndex.findNearestStops(
      destination,
      maxResults: 10,
      maxDistance: maxWalkDistance,
    );

    if (originStops.isEmpty || destinationStops.isEmpty) {
      return [];
    }

    final paths = <RoutingPath>[];

    // Phase 1: Find direct routes (no transfers)
    _findDirectRoutes(originStops, destinationStops, paths);

    // Phase 2: Find routes with 1 transfer
    if (maxTransfers >= 1) {
      _findOneTransferRoutes(originStops, destinationStops, paths);
    }

    // Sort all paths by score (lower is better)
    paths.sort((a, b) => a.score.compareTo(b.score));

    // Deduplicate: keep only the best path per route combination.
    // E.g., all "Bus 15 → Z14" variants collapse into the best one,
    // leaving room for genuinely different route options.
    final seen = <String>{};
    final uniquePaths = <RoutingPath>[];
    for (final path in paths) {
      final key = path.segments.map((s) => s.route.shortName).join('|');
      if (seen.add(key)) {
        uniquePaths.add(path);
      }
    }

    // Split into direct vs transfer buckets. In Cochabamba each ride is a
    // separate fare, so a transfer doubles the cost — only worth offering
    // when there's no direct option. Suppress transfers entirely if at
    // least one direct exists.
    final directs = <RoutingPath>[];
    final transfers = <RoutingPath>[];
    for (final p in uniquePaths) {
      if (p.segments.length <= 1) {
        if (directs.length < maxDirects) directs.add(p);
      } else {
        if (transfers.length < maxTransferPaths) transfers.add(p);
      }
      if (directs.length >= maxDirects && transfers.length >= maxTransferPaths) {
        break;
      }
    }
    final ordered = directs.isNotEmpty ? directs : transfers;
    return ordered.take(maxResults).map(_resolvePathStops).toList();
  }

  /// Find direct routes (0 transfers) between origin and destination stops.
  ///
  /// Pattern-first iteration: for each origin stop, scan the patterns
  /// passing through it and check if any destination stop appears later
  /// in the same pattern (which encodes the correct travel direction).
  void _findDirectRoutes(
    List<NearbyStop> originStops,
    List<NearbyStop> destinationStops,
    List<RoutingPath> paths,
  ) {
    for (final originNearby in originStops) {
      final originPatterns =
          routeIndex.getPatternsAtStop(originNearby.stop.id);
      for (final pattern in originPatterns) {
        final originIdx = pattern.indexOfStop(originNearby.stop.id);
        if (originIdx < 0) continue;

        for (final destNearby in destinationStops) {
          final destIdx = pattern.indexOfStop(destNearby.stop.id);
          if (destIdx <= originIdx) continue;

          final route = data.routes[pattern.routeId];
          if (route == null) continue;

          final segment = _buildSegmentForPattern(
            pattern: pattern,
            fromIdx: originIdx,
            toIdx: destIdx,
            route: route,
            fromStop: originNearby.stop,
            toStop: destNearby.stop,
          );

          paths.add(
            RoutingPath(
              originWalkDistance: originNearby.distance,
              originStop: originNearby.stop,
              segments: [segment],
              destinationStop: destNearby.stop,
              destinationWalkDistance: destNearby.distance,
              score: _calculateScore(
                walkDistance: originNearby.distance + destNearby.distance,
                transfers: 0,
                transitDistance: segment.transitDistance,
              ),
            ),
          );
        }
      }
    }
  }

  /// Find routes with 1 transfer using precomputed pattern connections.
  ///
  /// For each origin pattern that contains an origin stop, walk the
  /// precomputed connections (other-pattern transfer points) and check
  /// if any destination stop is reachable on the other pattern after the
  /// transfer point. No per-query candidate map: transfer geometry is
  /// fixed at index build time.
  void _findOneTransferRoutes(
    List<NearbyStop> originStops,
    List<NearbyStop> destinationStops,
    List<RoutingPath> paths,
  ) {
    // Precompute which destination-side patterns are relevant for this query
    // and which dest stops each carries. Acts as the pruning filter that the
    // raw connection list lacks: most patterns crossing the origin don't
    // serve any destination stop, so we skip them fast.
    final relevantDestStops = <int, List<NearbyStop>>{};
    for (final destNearby in destinationStops) {
      for (final p in routeIndex.getPatternsAtStop(destNearby.stop.id)) {
        relevantDestStops.putIfAbsent(p.id, () => []).add(destNearby);
      }
    }
    if (relevantDestStops.isEmpty) return;

    // Bounding box around the destination's nearby stops. We use this to
    // discard transfer points that are obviously far from the destination
    // region. The threshold scales with the trip's straight-line distance
    // so we don't over-prune cross-city queries: a long trip may have
    // legitimate transfer points kilometres from the dest, while a short
    // trip should keep transfers tight.
    final destBbox = _bboxOfStops(destinationStops);
    final straightLine =
        _haversine(originStops.first.stop.position, destinationStops.first.stop.position);
    // "Transfer point shouldn't be further from dest than origin is" — rules
    // out detours ratio > 2× without a computed score. Hard floor of 3 km
    // keeps short trips from being over-pruned (close pairs may still need
    // a transfer at a hub that's a few km away).
    final transferMaxDistFromDestM = max(3000.0, straightLine);

    // Hard cap on total candidate enumeration. In dense feeds with
    // transit-saturated city centers, the precomputed connection list can
    // still produce thousands of valid transfer candidates per query.
    // Beyond a reasonable count, additional candidates rarely change the
    // top-K result — score-sort + bucket cap discard them anyway. Cutting
    // the inner loop bounds tail latency without affecting the user-visible
    // top results.
    const maxCandidatesEnumerated = 1500;
    var enumerated = 0;

    for (final originNearby in originStops) {
      final originPatterns =
          routeIndex.getPatternsAtStop(originNearby.stop.id);
      for (final originPattern in originPatterns) {
        final originIdx = originPattern.indexOfStop(originNearby.stop.id);
        if (originIdx < 0) continue;

        for (final conn in routeIndex.getConnectionsFor(originPattern.id)) {
          // Transfer stop must be AFTER the origin within the origin pattern.
          if (conn.myStopIdx <= originIdx) continue;

          // Skip patterns that don't serve any destination stop.
          final destStopsOnOther = relevantDestStops[conn.otherPatternId];
          if (destStopsOnOther == null) continue;

          // Discard transfers that happen far from the destination region.
          // The check is on the transfer point itself, not the pattern's
          // overall bbox: a long route may sweep through the dest area at
          // some point, but its bbox alone isn't enough to know which stop
          // does. This pointwise version preserves valid transfers and
          // skips the "ride past the destination then come back" candidates.
          if (destBbox != null) {
            final transferStop =
                data.stops[originPattern.stopIds[conn.myStopIdx]];
            if (transferStop != null &&
                !_pointNearBbox(
                  transferStop.lat,
                  transferStop.lon,
                  destBbox,
                  transferMaxDistFromDestM,
                )) {
              continue;
            }
          }

          final otherPattern = routeIndex.patternById(conn.otherPatternId);

          for (final destNearby in destStopsOnOther) {
            final destIdx = otherPattern.indexOfStop(destNearby.stop.id);
            if (destIdx <= conn.otherStopIdx) continue;

            final transferStopId = originPattern.stopIds[conn.myStopIdx];
            final transferStop = data.stops[transferStopId];
            if (transferStop == null) continue;

            final originRoute = data.routes[originPattern.routeId];
            final destRoute = data.routes[otherPattern.routeId];
            if (originRoute == null || destRoute == null) continue;

            final seg1 = _buildSegmentForPattern(
              pattern: originPattern,
              fromIdx: originIdx,
              toIdx: conn.myStopIdx,
              route: originRoute,
              fromStop: originNearby.stop,
              toStop: transferStop,
            );
            final seg2 = _buildSegmentForPattern(
              pattern: otherPattern,
              fromIdx: conn.otherStopIdx,
              toIdx: destIdx,
              route: destRoute,
              fromStop: transferStop,
              toStop: destNearby.stop,
            );

            paths.add(
              RoutingPath(
                originWalkDistance: originNearby.distance,
                originStop: originNearby.stop,
                segments: [seg1, seg2],
                destinationStop: destNearby.stop,
                destinationWalkDistance: destNearby.distance,
                score: _calculateScore(
                  walkDistance: originNearby.distance + destNearby.distance,
                  transfers: 1,
                  transitDistance: seg1.transitDistance + seg2.transitDistance,
                ),
              ),
            );
            enumerated++;
            if (enumerated >= maxCandidatesEnumerated) return;
          }
        }
      }
    }
  }

  /// Build a transit segment from a known pattern and stop indices.
  /// `transitDistance` is read in O(1) from the pattern's precomputed `cumDist`.
  RoutingSegment _buildSegmentForPattern({
    required RoutePattern pattern,
    required int fromIdx,
    required int toIdx,
    required GtfsRoute route,
    required GtfsStop fromStop,
    required GtfsStop toStop,
  }) {
    final stopCount = toIdx - fromIdx + 1;
    final transit = pattern.distanceBetween(fromIdx, toIdx);
    // Estimate in-vehicle time from transit distance at ~18 km/h average
    // urban transit speed. Independent of stop spacing — works for both
    // sparse feeds (stops every ~500m) and dense feeds (stops every ~30m).
    // The downstream UI converts this to "X min" display.
    final estDuration = Duration(seconds: (transit / 5).round());
    return RoutingSegment(
      route: route,
      fromStop: fromStop,
      toStop: toStop,
      stopCount: stopCount,
      stops: const [],
      pattern: pattern,
      transitDistance: transit,
      scheduledDuration: estDuration,
    );
  }

  /// Resolve full GtfsStop objects and shape polylines for all segments.
  /// Called only on final top-N results for performance.
  RoutingPath _resolvePathStops(RoutingPath path) {
    return RoutingPath(
      originWalkDistance: path.originWalkDistance,
      originStop: path.originStop,
      segments: path.segments.map((seg) {
        final fromIdx = seg.pattern.indexOfStop(seg.fromStop.id);
        final toIdx = seg.pattern.indexOfStop(seg.toStop.id);
        if (fromIdx >= 0 && toIdx > fromIdx) {
          final ids = seg.pattern.stopIds.sublist(fromIdx, toIdx + 1);
          final stops = ids
              .map((id) => data.stops[id])
              .whereType<GtfsStop>()
              .toList();

          final shapePoints = _extractShapeForSegment(
            seg.pattern.shapeId,
            seg.fromStop,
            seg.toStop,
            stops,
          );

          return RoutingSegment(
            route: seg.route,
            fromStop: seg.fromStop,
            toStop: seg.toStop,
            stopCount: seg.stopCount,
            stops: stops,
            pattern: seg.pattern,
            scheduledDuration: seg.scheduledDuration,
            shapePoints: shapePoints,
            transitDistance: seg.transitDistance,
          );
        }
        return seg;
      }).toList(),
      destinationStop: path.destinationStop,
      destinationWalkDistance: path.destinationWalkDistance,
      score: path.score,
    );
  }

  /// Extract the shape polyline segment between two stops using
  /// point-to-segment projection (OTP-style linear referencing).
  /// Projects each stop onto the nearest line segment of the polyline
  /// and extracts the sub-shape with interpolated start/end points.
  List<LatLng> _extractShapeForSegment(
    String? shapeId,
    GtfsStop fromStop,
    GtfsStop toStop,
    List<GtfsStop> stops,
  ) {
    if (shapeId == null) {
      return stops.map((s) => s.position).toList();
    }

    final shape = data.shapes[shapeId];
    if (shape == null || shape.points.length < 2) {
      return stops.map((s) => s.position).toList();
    }

    final poly = shape.polyline;
    final n = poly.length;

    // Step 1: Compute cumulative distances along the polyline.
    final cumDist = List<double>.filled(n, 0.0);
    for (int i = 1; i < n; i++) {
      final dLat = poly[i].latitude - poly[i - 1].latitude;
      final dLon = poly[i].longitude - poly[i - 1].longitude;
      cumDist[i] = cumDist[i - 1] + sqrt(dLat * dLat + dLon * dLon);
    }

    // Step 2: Project each stop onto the nearest segment, searching
    // forward only from the previous stop's segment.
    int searchSeg = 0;
    double fromDist = 0.0;
    double toDist = 0.0;

    for (int s = 0; s < stops.length; s++) {
      final p = stops[s].position;
      double bestSqDist = double.infinity;
      double bestLineDist = 0.0;
      int bestSeg = searchSeg;

      for (int i = searchSeg; i < n - 1; i++) {
        final a = poly[i];
        final b = poly[i + 1];

        // Project p onto segment AB → parameter t ∈ [0,1]
        final abLat = b.latitude - a.latitude;
        final abLon = b.longitude - a.longitude;
        final apLat = p.latitude - a.latitude;
        final apLon = p.longitude - a.longitude;
        final lenSq = abLat * abLat + abLon * abLon;
        final t = lenSq < 1e-20
            ? 0.0
            : ((apLat * abLat + apLon * abLon) / lenSq).clamp(0.0, 1.0);

        // Squared distance from p to projected point
        final projLat = a.latitude + t * abLat;
        final projLon = a.longitude + t * abLon;
        final dLat = p.latitude - projLat;
        final dLon = p.longitude - projLon;
        final d = dLat * dLat + dLon * dLon;

        if (d < bestSqDist) {
          bestSqDist = d;
          bestSeg = i;
          bestLineDist = cumDist[i] + t * (cumDist[i + 1] - cumDist[i]);
        }
      }

      if (s == 0) fromDist = bestLineDist;
      toDist = bestLineDist;
      searchSeg = bestSeg;
    }

    if (fromDist > toDist) {
      return stops.map((s) => s.position).toList();
    }

    // Step 3: Extract sub-shape between fromDist and toDist
    // with interpolated start/end points.
    final result = <LatLng>[];
    bool started = false;

    for (int i = 0; i < n - 1; i++) {
      final d0 = cumDist[i];
      final d1 = cumDist[i + 1];

      if (!started) {
        if (d1 >= fromDist) {
          // Start point falls on this segment
          final segLen = d1 - d0;
          final t = segLen > 0 ? (fromDist - d0) / segLen : 0.0;
          result.add(_lerp(poly[i], poly[i + 1], t));
          started = true;

          // Check if end point is also on this same segment
          if (d1 >= toDist) {
            final tEnd = segLen > 0 ? (toDist - d0) / segLen : 0.0;
            final endPt = _lerp(poly[i], poly[i + 1], tEnd);
            if (_sqDist(result.last, endPt) > 1e-14) {
              result.add(endPt);
            }
            break;
          }
          result.add(poly[i + 1]);
        }
      } else {
        if (d1 >= toDist) {
          // End point falls on this segment
          final segLen = d1 - d0;
          final t = segLen > 0 ? (toDist - d0) / segLen : 0.0;
          result.add(_lerp(poly[i], poly[i + 1], t));
          break;
        }
        result.add(poly[i + 1]);
      }
    }

    return result.isEmpty ? stops.map((s) => s.position).toList() : result;
  }

  /// Linear interpolation between two LatLng points.
  static LatLng _lerp(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + t * (b.latitude - a.latitude),
      a.longitude + t * (b.longitude - a.longitude),
    );
  }

  /// Squared distance (fast, no sqrt needed for comparison).
  static double _sqDist(LatLng a, LatLng b) {
    final dLat = a.latitude - b.latitude;
    final dLon = a.longitude - b.longitude;
    return dLat * dLat + dLon * dLon;
  }

  /// Calculate routing score (lower is better).
  ///
  /// Pure total-distance: `walkDistance + transitDistance` (meters). Time
  /// is intentionally ignored — schedule-driven transfer waits would skew
  /// rankings and make "fastest by 1 minute" beat genuinely shorter trips.
  /// The strict-direct-vs-transfer split (see [findRoutes]) keeps transfers
  /// out of results when any direct exists, so the per-transfer friction
  /// term that the old formula carried is no longer needed here.
  double _calculateScore({
    required double walkDistance,
    required int transfers,
    required double transitDistance,
  }) {
    return walkDistance + transitDistance;
  }

  /// Tight bounding box around a list of nearby stops, in degrees.
  /// Returns null if the list is empty.
  static ({double minLat, double minLon, double maxLat, double maxLon})?
      _bboxOfStops(List<NearbyStop> stops) {
    if (stops.isEmpty) return null;
    var minLat = double.infinity,
        minLon = double.infinity,
        maxLat = double.negativeInfinity,
        maxLon = double.negativeInfinity;
    for (final s in stops) {
      if (s.stop.lat < minLat) minLat = s.stop.lat;
      if (s.stop.lat > maxLat) maxLat = s.stop.lat;
      if (s.stop.lon < minLon) minLon = s.stop.lon;
      if (s.stop.lon > maxLon) maxLon = s.stop.lon;
    }
    return (minLat: minLat, minLon: minLon, maxLat: maxLat, maxLon: maxLon);
  }

  /// True if (lat, lon) lies inside [bbox] padded by [marginM] meters.
  static bool _pointNearBbox(
    double lat,
    double lon,
    ({double minLat, double minLon, double maxLat, double maxLon}) bbox,
    double marginM,
  ) {
    final dLat = marginM / 111111;
    final centerLat = (bbox.minLat + bbox.maxLat) / 2;
    final dLon = marginM / (111111 * cos(centerLat * pi / 180));
    return lat >= bbox.minLat - dLat &&
        lat <= bbox.maxLat + dLat &&
        lon >= bbox.minLon - dLon &&
        lon <= bbox.maxLon + dLon;
  }

  /// Great-circle distance between two LatLng points, in meters.
  static double _haversine(LatLng a, LatLng b) {
    const r = 6371000.0;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * asin(sqrt(h));
  }
}
