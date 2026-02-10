import '../models/gtfs_stop_time.dart';
import '../models/gtfs_trip.dart';
import '../parser/gtfs_parser.dart';

/// A pattern representing a sequence of stops for a route.
class RoutePattern {
  final String routeId;
  final List<String> stopIds;
  final String? headsign;
  final String? shapeId;

  /// O(1) stop position lookup (built lazily).
  late final Map<String, int> _stopPositions = _buildStopPositions();

  RoutePattern({
    required this.routeId,
    required this.stopIds,
    this.headsign,
    this.shapeId,
  });

  Map<String, int> _buildStopPositions() {
    final map = <String, int>{};
    for (int i = 0; i < stopIds.length; i++) {
      map.putIfAbsent(stopIds[i], () => i);
    }
    return map;
  }

  /// O(1) index lookup for a stop ID. Returns -1 if not found.
  int indexOfStop(String stopId) => _stopPositions[stopId] ?? -1;

  factory RoutePattern.fromJson(Map<String, dynamic> json) {
    return RoutePattern(
      routeId: json['routeId'] as String,
      stopIds: (json['stopIds'] as List).cast<String>(),
      headsign: json['headsign'] as String?,
      shapeId: json['shapeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'routeId': routeId,
        'stopIds': stopIds,
        'headsign': headsign,
        'shapeId': shapeId,
      };
}

/// Index for fast route lookups.
class GtfsRouteIndex {
  final GtfsData _data;
  late final Map<String, Set<String>> _stopToRoutes;
  late final Map<String, List<RoutePattern>> _routePatterns;

  GtfsRouteIndex(this._data) {
    _buildIndices();
  }

  void _buildIndices() {
    _stopToRoutes = {};
    _routePatterns = {};

    // Group stop times by trip
    final tripStopTimes = <String, List<GtfsStopTime>>{};
    for (final st in _data.stopTimes) {
      tripStopTimes.putIfAbsent(st.tripId, () => []).add(st);
    }

    // Build patterns from trips
    for (final entry in tripStopTimes.entries) {
      final stopTimes = entry.value
        ..sort((a, b) => a.stopSequence.compareTo(b.stopSequence));
      final trip = _data.trips[entry.key];
      if (trip == null) continue;

      // Deduplicate consecutive stops (GTFS data may repeat the same stop)
      final rawIds = stopTimes.map((st) => st.stopId).toList();
      final stopIds = <String>[];
      for (final id in rawIds) {
        if (stopIds.isEmpty || stopIds.last != id) {
          stopIds.add(id);
        }
      }

      // Add to stop-to-routes index
      for (final stopId in stopIds) {
        _stopToRoutes.putIfAbsent(stopId, () => {}).add(trip.routeId);
      }

      // Add pattern (only if we don't have it yet)
      final patterns = _routePatterns.putIfAbsent(trip.routeId, () => []);
      if (patterns.isEmpty ||
          !patterns.any((p) => _sameStopSequence(p.stopIds, stopIds))) {
        patterns.add(RoutePattern(
          routeId: trip.routeId,
          stopIds: stopIds,
          headsign: trip.headsign,
          shapeId: trip.shapeId,
        ));
      }
    }

  }

  bool _sameStopSequence(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Get all routes that serve a stop.
  Set<String> getRoutesAtStop(String stopId) {
    return _stopToRoutes[stopId] ?? {};
  }

  /// Get all patterns for a route.
  List<RoutePattern> getPatternsForRoute(String routeId) {
    return _routePatterns[routeId] ?? [];
  }

  /// Get all patterns across all routes.
  Iterable<RoutePattern> get patterns {
    return _routePatterns.values.expand((patterns) => patterns);
  }

  /// Get a pattern by route ID (returns first pattern for that route).
  RoutePattern? getPattern(String routeId) {
    final patterns = _routePatterns[routeId];
    return patterns != null && patterns.isNotEmpty ? patterns.first : null;
  }

  /// Find routes that connect two stops.
  List<String> findConnectingRoutes(String fromStopId, String toStopId) {
    final routesAtFrom = getRoutesAtStop(fromStopId);
    final routesAtTo = getRoutesAtStop(toStopId);
    return routesAtFrom.intersection(routesAtTo).toList();
  }
}
