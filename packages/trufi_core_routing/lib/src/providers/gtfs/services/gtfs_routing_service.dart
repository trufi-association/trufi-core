import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../gtfs_data_source.dart';
import '../index/gtfs_route_index.dart';
import '../index/gtfs_spatial_index.dart';
import '../models/gtfs_models.dart';

/// A segment of a journey (one transit leg).
class RoutingSegment {
  final GtfsRoute route;
  final RoutePattern pattern;
  final int fromStopIndex;
  final int toStopIndex;
  final GtfsStop fromStop;
  final GtfsStop toStop;

  const RoutingSegment({
    required this.route,
    required this.pattern,
    required this.fromStopIndex,
    required this.toStopIndex,
    required this.fromStop,
    required this.toStop,
  });

  /// Number of stops in this segment.
  int get stopCount => (toStopIndex - fromStopIndex).abs() + 1;

  /// Stop IDs along this segment.
  List<String> get stopIds {
    final stops = pattern.stopIds;
    if (fromStopIndex <= toStopIndex) {
      return stops.sublist(fromStopIndex, toStopIndex + 1);
    } else {
      return stops.sublist(toStopIndex, fromStopIndex + 1).reversed.toList();
    }
  }

  /// Duration of this segment based on GTFS schedule times.
  /// Returns null if times are not available or if traveling in reverse direction.
  Duration? get scheduledDuration {
    // GTFS times only apply when traveling in the forward direction
    if (fromStopIndex >= toStopIndex) {
      return null; // Reverse direction - times don't apply
    }

    final stops = pattern.stops;
    if (fromStopIndex < 0 || toStopIndex >= stops.length) {
      return null;
    }

    final fromTime = stops[fromStopIndex].departureTime;
    final toTime = stops[toStopIndex].arrivalTime;

    if (fromTime == null || toTime == null) return null;

    // Calculate difference
    var diff = toTime - fromTime;

    // Handle overnight trips where toTime < fromTime
    if (diff.isNegative) {
      diff = const Duration(hours: 24) + diff;
    }

    // Sanity check: if duration seems unreasonable (> 3 hours for a segment),
    // return null to use estimation instead
    if (diff.inHours > 3) {
      return null;
    }

    return diff;
  }

  /// Departure time at the from stop (only valid for forward direction).
  Duration? get departureTime {
    if (fromStopIndex < 0 || fromStopIndex >= pattern.stops.length) return null;
    return pattern.stops[fromStopIndex].departureTime;
  }

  /// Arrival time at the to stop (only valid for forward direction).
  Duration? get arrivalTime {
    if (toStopIndex < 0 || toStopIndex >= pattern.stops.length) return null;
    return pattern.stops[toStopIndex].arrivalTime;
  }
}

/// A complete routing result.
class RoutingPath {
  final double originWalkDistance;
  final GtfsStop originStop;
  final List<RoutingSegment> segments;
  final GtfsStop destinationStop;
  final double destinationWalkDistance;

  const RoutingPath({
    required this.originWalkDistance,
    required this.originStop,
    required this.segments,
    required this.destinationStop,
    required this.destinationWalkDistance,
  });

  /// Total walking distance.
  double get totalWalkDistance => originWalkDistance + destinationWalkDistance;

  /// Number of transfers.
  int get transfers => segments.isEmpty ? 0 : segments.length - 1;

  /// Total number of transit stops.
  int get totalStops => segments.fold(0, (sum, s) => sum + s.stopCount);

  /// Score for ranking (lower is better).
  double get score {
    return transfers * 1000 + totalWalkDistance * 2 + totalStops * 10;
  }
}

/// Service for finding routes using GTFS data.
class GtfsRoutingService {
  final GtfsDataSource _dataSource;

  GtfsRoutingService(this._dataSource);

  /// Find routes from origin to destination.
  List<RoutingPath> findRoutes({
    required LatLng origin,
    required LatLng destination,
    double maxWalkDistance = 500,
    int maxTransfers = 1,
    int maxResults = 5,
  }) {
    if (!_dataSource.isLoaded) {
      debugPrint('GtfsRoutingService: Data not loaded');
      return [];
    }

    final sw = Stopwatch()..start();
    debugPrint('GtfsRoutingService: Finding routes...');

    // Find nearby stops
    final originStops = _dataSource.findNearestStops(
      origin,
      maxResults: 15,
      maxDistance: maxWalkDistance,
    );

    final destStops = _dataSource.findNearestStops(
      destination,
      maxResults: 15,
      maxDistance: maxWalkDistance,
    );

    if (originStops.isEmpty || destStops.isEmpty) {
      debugPrint('GtfsRoutingService: No nearby stops found');
      return [];
    }

    debugPrint('GtfsRoutingService: ${originStops.length} origin stops, ${destStops.length} dest stops');

    final routeIndex = _dataSource.routeIndex!;
    final paths = <RoutingPath>[];
    final seenRoutes = <String>{};

    // Build destination stop lookup
    final destStopIds = destStops.map((s) => s.stop.id).toSet();
    final destStopDistances = {
      for (final s in destStops) s.stop.id: s.distance
    };

    // Build destination route lookup
    final destRouteIds = <String>{};
    for (final destStop in destStops) {
      destRouteIds.addAll(routeIndex.getRoutesAtStop(destStop.stop.id));
    }

    // === PHASE 1: Direct routes ===
    for (final originStop in originStops) {
      final routesAtOrigin = routeIndex.getRoutesAtStop(originStop.stop.id);

      for (final routeId in routesAtOrigin) {
        if (seenRoutes.contains(routeId)) continue;

        final pattern = routeIndex.getPattern(routeId);
        if (pattern == null) continue;

        final path = _findDirectPath(
          originStop: originStop,
          pattern: pattern,
          destStopIds: destStopIds,
          destStopDistances: destStopDistances,
        );

        if (path != null) {
          seenRoutes.add(routeId);
          paths.add(path);
        }
      }
    }

    debugPrint('GtfsRoutingService: Found ${paths.length} direct routes');

    // === PHASE 2: Single transfer routes ===
    if (maxTransfers > 0) {
      int transferPaths = 0;

      for (final originStop in originStops) {
        final routesAtOrigin = routeIndex.getRoutesAtStop(originStop.stop.id);

        for (final routeId in routesAtOrigin) {
          final connections = routeIndex.getConnections(routeId);

          for (final conn in connections) {
            // Only consider if connection leads to a destination route
            if (!destRouteIds.contains(conn.toRouteId)) continue;

            final routeKey = '$routeId-${conn.toRouteId}';
            if (seenRoutes.contains(routeKey)) continue;

            final path = _findTransferPath(
              originStop: originStop,
              firstRouteId: routeId,
              connection: conn,
              destStopIds: destStopIds,
              destStopDistances: destStopDistances,
            );

            if (path != null) {
              seenRoutes.add(routeKey);
              paths.add(path);
              transferPaths++;
            }
          }
        }
      }

      debugPrint('GtfsRoutingService: Found $transferPaths transfer routes');
    }

    // Sort by score
    paths.sort((a, b) => a.score.compareTo(b.score));

    // Limit results per starting route
    final uniquePaths = <RoutingPath>[];
    final firstRouteCount = <String, int>{};

    for (final path in paths) {
      if (uniquePaths.length >= maxResults) break;

      final firstRouteName = path.segments.first.route.displayName;
      final count = firstRouteCount[firstRouteName] ?? 0;

      if (count < 3) {
        uniquePaths.add(path);
        firstRouteCount[firstRouteName] = count + 1;
      }
    }

    sw.stop();
    debugPrint('GtfsRoutingService: Found ${uniquePaths.length} routes in ${sw.elapsedMilliseconds}ms');

    return uniquePaths;
  }

  RoutingPath? _findDirectPath({
    required NearbyStop originStop,
    required RoutePattern pattern,
    required Set<String> destStopIds,
    required Map<String, double> destStopDistances,
  }) {
    final routeIndex = _dataSource.routeIndex!;
    final route = routeIndex.getRoute(pattern.routeId);
    if (route == null) return null;

    // Find origin index in pattern
    final originIndex = pattern.stopIds.indexOf(originStop.stop.id);
    if (originIndex == -1) return null;

    RoutingPath? bestPath;
    double bestScore = double.infinity;

    // Check stops after origin
    for (var i = originIndex + 1; i < pattern.stops.length; i++) {
      final stopId = pattern.stopIds[i];
      if (!destStopIds.contains(stopId)) continue;

      final destStop = _dataSource.getStop(stopId);
      if (destStop == null) continue;

      final path = RoutingPath(
        originWalkDistance: originStop.distance,
        originStop: originStop.stop,
        segments: [
          RoutingSegment(
            route: route,
            pattern: pattern,
            fromStopIndex: originIndex,
            toStopIndex: i,
            fromStop: originStop.stop,
            toStop: destStop,
          ),
        ],
        destinationStop: destStop,
        destinationWalkDistance: destStopDistances[stopId] ?? 0,
      );

      if (path.score < bestScore) {
        bestScore = path.score;
        bestPath = path;
      }
    }

    // Check stops before origin (reverse direction)
    for (var i = originIndex - 1; i >= 0; i--) {
      final stopId = pattern.stopIds[i];
      if (!destStopIds.contains(stopId)) continue;

      final destStop = _dataSource.getStop(stopId);
      if (destStop == null) continue;

      final path = RoutingPath(
        originWalkDistance: originStop.distance,
        originStop: originStop.stop,
        segments: [
          RoutingSegment(
            route: route,
            pattern: pattern,
            fromStopIndex: originIndex,
            toStopIndex: i,
            fromStop: originStop.stop,
            toStop: destStop,
          ),
        ],
        destinationStop: destStop,
        destinationWalkDistance: destStopDistances[stopId] ?? 0,
      );

      if (path.score < bestScore) {
        bestScore = path.score;
        bestPath = path;
      }
    }

    return bestPath;
  }

  RoutingPath? _findTransferPath({
    required NearbyStop originStop,
    required String firstRouteId,
    required RouteConnection connection,
    required Set<String> destStopIds,
    required Map<String, double> destStopDistances,
  }) {
    final routeIndex = _dataSource.routeIndex!;

    final firstRoute = routeIndex.getRoute(firstRouteId);
    final firstPattern = routeIndex.getPattern(firstRouteId);
    final secondRoute = routeIndex.getRoute(connection.toRouteId);
    final secondPattern = routeIndex.getPattern(connection.toRouteId);

    if (firstRoute == null ||
        firstPattern == null ||
        secondRoute == null ||
        secondPattern == null) {
      return null;
    }

    // Find origin index in first pattern
    final originIndex = firstPattern.stopIds.indexOf(originStop.stop.id);
    if (originIndex == -1) return null;

    // Get transfer stop
    final transferStopId = connection.stopId;
    final transferStop = _dataSource.getStop(transferStopId);
    if (transferStop == null) return null;

    RoutingPath? bestPath;
    double bestScore = double.infinity;

    // Check all destination stops on second route
    for (var i = 0; i < secondPattern.stops.length; i++) {
      if (i == connection.toStopIndex) continue; // Skip transfer stop

      final stopId = secondPattern.stopIds[i];
      if (!destStopIds.contains(stopId)) continue;

      final destStop = _dataSource.getStop(stopId);
      if (destStop == null) continue;

      final path = RoutingPath(
        originWalkDistance: originStop.distance,
        originStop: originStop.stop,
        segments: [
          RoutingSegment(
            route: firstRoute,
            pattern: firstPattern,
            fromStopIndex: originIndex,
            toStopIndex: connection.fromStopIndex,
            fromStop: originStop.stop,
            toStop: transferStop,
          ),
          RoutingSegment(
            route: secondRoute,
            pattern: secondPattern,
            fromStopIndex: connection.toStopIndex,
            toStopIndex: i,
            fromStop: transferStop,
            toStop: destStop,
          ),
        ],
        destinationStop: destStop,
        destinationWalkDistance: destStopDistances[stopId] ?? 0,
      );

      if (path.score < bestScore) {
        bestScore = path.score;
        bestPath = path;
      }
    }

    return bestPath;
  }
}
