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

  const RoutingSegment({
    required this.route,
    required this.fromStop,
    required this.toStop,
    required this.stopCount,
    required this.stops,
    required this.pattern,
    this.scheduledDuration,
    this.shapePoints = const [],
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
      scheduledDuration:
          durationSeconds != null ? Duration(seconds: durationSeconds) : null,
      shapePoints: shapeRaw
              ?.map((p) =>
                  LatLng((p as List)[0] as double, p[1] as double))
              .toList() ??
          const [],
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
  double get totalWalkDistance =>
      originWalkDistance + destinationWalkDistance;

  /// Number of transfers.
  int get transfers => segments.length - 1;

  /// Total number of stops.
  int get totalStops =>
      segments.fold(0, (sum, seg) => sum + seg.stopCount);

  factory RoutingPath.fromJson(Map<String, dynamic> json) {
    return RoutingPath(
      originWalkDistance: (json['originWalk'] as num).toDouble(),
      originStop: GtfsStop.fromJson(json['originStop'] as Map<String, dynamic>),
      segments: (json['segments'] as List)
          .map((s) => RoutingSegment.fromJson(s as Map<String, dynamic>))
          .toList(),
      destinationStop:
          GtfsStop.fromJson(json['destinationStop'] as Map<String, dynamic>),
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
  List<RoutingPath> findRoutes({
    required LatLng origin,
    required LatLng destination,
    double maxWalkDistance = 500,
    int maxResults = 5,
    int maxTransfers = 1,
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
    final segmentCache = <String, RoutingSegment?>{};

    // Phase 1: Find direct routes (no transfers)
    _findDirectRoutes(originStops, destinationStops, paths, segmentCache);

    // Phase 2: Find routes with 1 transfer
    if (maxTransfers >= 1) {
      _findOneTransferRoutes(
          originStops, destinationStops, paths, segmentCache);
    }

    // Deduplicate paths that use the same route(s) in the same direction
    final seen = <String>{};
    final uniquePaths = <RoutingPath>[];
    for (final path in paths) {
      final key = path.segments
          .map((s) => '${s.route.id}:${s.fromStop.id}->${s.toStop.id}')
          .join('|');
      if (seen.add(key)) {
        uniquePaths.add(path);
      }
    }

    // Sort by score, take top results, then resolve full stops
    uniquePaths.sort((a, b) => a.score.compareTo(b.score));
    return uniquePaths
        .take(maxResults)
        .map(_resolvePathStops)
        .toList();
  }

  /// Find direct routes (0 transfers) between origin and destination stops.
  void _findDirectRoutes(
    List<NearbyStop> originStops,
    List<NearbyStop> destinationStops,
    List<RoutingPath> paths,
    Map<String, RoutingSegment?> segmentCache,
  ) {
    for (final originNearby in originStops) {
      for (final destNearby in destinationStops) {
        final originStop = originNearby.stop;
        final destStop = destNearby.stop;

        final connectingRoutes =
            routeIndex.findConnectingRoutes(originStop.id, destStop.id);

        for (final routeId in connectingRoutes) {
          final route = data.routes[routeId];
          if (route == null) continue;

          final segment = _buildSegmentCached(
            segmentCache, route, originStop, destStop);
          if (segment == null) continue;

          paths.add(RoutingPath(
            originWalkDistance: originNearby.distance,
            originStop: originStop,
            segments: [segment],
            destinationStop: destStop,
            destinationWalkDistance: destNearby.distance,
            score: _calculateScore(
              walkDistance: originNearby.distance + destNearby.distance,
              transfers: 0,
              totalStops: segment.stopCount,
            ),
          ));
        }
      }
    }
  }

  /// Find routes with 1 transfer between origin and destination stops.
  ///
  /// Optimized strategy:
  /// 1. Precompute which stops can reach destination via which routes
  /// 2. Scan origin patterns and check intermediate stops against that map
  void _findOneTransferRoutes(
    List<NearbyStop> originStops,
    List<NearbyStop> destinationStops,
    List<RoutingPath> paths,
    Map<String, RoutingSegment?> segmentCache,
  ) {
    // Step 1: Build transfer candidate map.
    // For each destination stop, find routes that serve it.
    // For each such route's pattern, all stops BEFORE the dest stop
    // are potential transfer points.
    // transferCandidates: transferStopId -> {destRouteId -> [destNearby]}
    final transferCandidates =
        <String, Map<String, List<NearbyStop>>>{};

    for (final destNearby in destinationStops) {
      final routesAtDest = routeIndex.getRoutesAtStop(destNearby.stop.id);
      for (final destRouteId in routesAtDest) {
        final patterns = routeIndex.getPatternsForRoute(destRouteId);
        for (final pattern in patterns) {
          final destIdx = pattern.indexOfStop(destNearby.stop.id);
          if (destIdx < 0) continue;

          // All stops before destIdx are potential transfer points
          for (int i = 0; i < destIdx; i++) {
            final stopId = pattern.stopIds[i];
            transferCandidates
                .putIfAbsent(stopId, () => {})
                .putIfAbsent(destRouteId, () => [])
                .add(destNearby);
          }
        }
      }
    }

    if (transferCandidates.isEmpty) return;

    // Step 2: Scan origin patterns, check intermediate stops
    // against the precomputed transfer map.
    for (final originNearby in originStops) {
      final originStopRoutes =
          routeIndex.getRoutesAtStop(originNearby.stop.id);

      for (final originRouteId in originStopRoutes) {
        final originRoute = data.routes[originRouteId];
        if (originRoute == null) continue;

        final patterns = routeIndex.getPatternsForRoute(originRouteId);

        for (final pattern in patterns) {
          final originIdx = pattern.indexOfStop(originNearby.stop.id);
          if (originIdx < 0) continue;

          // Check stops after origin as potential transfer points
          for (int i = originIdx + 1; i < pattern.stopIds.length; i++) {
            final transferStopId = pattern.stopIds[i];
            final destRouteMap = transferCandidates[transferStopId];
            if (destRouteMap == null) continue; // Not a transfer point

            final transferStop = data.stops[transferStopId];
            if (transferStop == null) continue;

            for (final entry in destRouteMap.entries) {
              final destRouteId = entry.key;
              if (destRouteId == originRouteId) continue;

              final destRoute = data.routes[destRouteId];
              if (destRoute == null) continue;

              // Build first segment: origin -> transfer
              final seg1 = _buildSegmentCached(
                  segmentCache, originRoute, originNearby.stop, transferStop);
              if (seg1 == null) continue;

              for (final destNearby in entry.value) {
                // Build second segment: transfer -> destination
                final seg2 = _buildSegmentCached(
                    segmentCache, destRoute, transferStop, destNearby.stop);
                if (seg2 == null) continue;

                final totalStops = seg1.stopCount + seg2.stopCount;
                paths.add(RoutingPath(
                  originWalkDistance: originNearby.distance,
                  originStop: originNearby.stop,
                  segments: [seg1, seg2],
                  destinationStop: destNearby.stop,
                  destinationWalkDistance: destNearby.distance,
                  score: _calculateScore(
                    walkDistance:
                        originNearby.distance + destNearby.distance,
                    transfers: 1,
                    totalStops: totalStops,
                  ),
                ));
              }
            }
          }
        }
      }
    }
  }

  /// Build segment with cache. Uses O(1) indexOfStop lookups.
  RoutingSegment? _buildSegmentCached(
    Map<String, RoutingSegment?> cache,
    GtfsRoute route,
    GtfsStop fromStop,
    GtfsStop toStop,
  ) {
    final key = '${route.id}:${fromStop.id}:${toStop.id}';
    if (cache.containsKey(key)) return cache[key];

    final patterns = routeIndex.getPatternsForRoute(route.id);
    for (final pattern in patterns) {
      final fromIndex = pattern.indexOfStop(fromStop.id);
      if (fromIndex < 0) continue;
      final toIndex = pattern.indexOfStop(toStop.id);
      if (toIndex <= fromIndex) continue;

      final stopCount = toIndex - fromIndex + 1;
      final result = RoutingSegment(
        route: route,
        fromStop: fromStop,
        toStop: toStop,
        stopCount: stopCount,
        stops: const [],
        pattern: pattern,
      );
      cache[key] = result;
      return result;
    }
    cache[key] = null;
    return null;
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
          final stops =
              ids.map((id) => data.stops[id]).whereType<GtfsStop>().toList();

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
  /// Formula: transfers * 1000 + walkDistance * 2 + totalStops * 10
  double _calculateScore({
    required double walkDistance,
    required int transfers,
    required int totalStops,
  }) {
    return transfers * 1000 + walkDistance * 2 + totalStops * 10;
  }
}
