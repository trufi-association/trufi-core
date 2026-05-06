import 'dart:math';

import '../models/gtfs_stop.dart';
import '../models/gtfs_stop_time.dart';
import '../parser/gtfs_parser.dart';

/// A pattern representing a sequence of stops for a route.
class RoutePattern {
  final String routeId;
  final List<String> stopIds;
  final String? headsign;
  final String? shapeId;

  /// Index assigned at build time. Used for in-memory connection lookups.
  /// `-1` for patterns deserialized from JSON (no connections available).
  final int id;

  /// Cumulative haversine distance in meters from `stopIds[0]` to `stopIds[i]`.
  /// Empty for patterns deserialized from JSON.
  final List<double> cumDist;

  /// Axis-aligned bounding box of all stops in this pattern, in degrees.
  /// `(minLat, minLon, maxLat, maxLon)`. Allows O(1) "is this pattern
  /// near point P" pruning before heavier per-stop work.
  /// Empty/zero for patterns deserialized from JSON.
  final double minLat;
  final double minLon;
  final double maxLat;
  final double maxLon;

  /// O(1) stop position lookup (built lazily).
  late final Map<String, int> _stopPositions = _buildStopPositions();

  RoutePattern({
    required this.routeId,
    required this.stopIds,
    this.headsign,
    this.shapeId,
    this.id = -1,
    this.cumDist = const [],
    this.minLat = 0,
    this.minLon = 0,
    this.maxLat = 0,
    this.maxLon = 0,
  });

  bool get hasBbox => minLat != 0 || minLon != 0 || maxLat != 0 || maxLon != 0;

  /// True if (lat, lon) is within the pattern's bbox padded by [marginM] meters.
  /// Cheap proxy for "the pattern passes near this point".
  bool nearPoint(double lat, double lon, double marginM) {
    if (!hasBbox) return true; // no bbox → can't prune, assume relevant
    // ~111,111 m per degree of latitude; longitude is shorter near equator,
    // but for Cochabamba (~17°S) the difference is < 5%. Fine for pruning.
    final dLat = marginM / 111111;
    final dLon = marginM / (111111 * cos(((minLat + maxLat) / 2) * pi / 180));
    return lat >= minLat - dLat &&
        lat <= maxLat + dLat &&
        lon >= minLon - dLon &&
        lon <= maxLon + dLon;
  }

  Map<String, int> _buildStopPositions() {
    final map = <String, int>{};
    for (int i = 0; i < stopIds.length; i++) {
      map.putIfAbsent(stopIds[i], () => i);
    }
    return map;
  }

  /// O(1) index lookup for a stop ID. Returns -1 if not found.
  int indexOfStop(String stopId) => _stopPositions[stopId] ?? -1;

  /// Distance in meters between two stop indices on this pattern.
  /// Returns 0 if cumDist isn't available (e.g., deserialized pattern).
  double distanceBetween(int fromIdx, int toIdx) {
    if (cumDist.isEmpty || fromIdx < 0 || toIdx >= cumDist.length) return 0;
    return cumDist[toIdx] - cumDist[fromIdx];
  }

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

/// A precomputed transfer point between two patterns at a shared stop.
class PatternConnection {
  /// Index of the other pattern in `GtfsRouteIndex._patterns`.
  final int otherPatternId;

  /// Stop position in the source pattern at which the transfer happens.
  final int myStopIdx;

  /// Stop position in the destination pattern at which the transfer happens.
  final int otherStopIdx;

  const PatternConnection(this.otherPatternId, this.myStopIdx, this.otherStopIdx);
}

/// Index for fast route lookups.
class GtfsRouteIndex {
  final GtfsData _data;

  late final List<RoutePattern> _patterns;
  late final Map<String, Set<int>> _stopToPatternIds;
  late final Map<String, Set<String>> _stopToRoutes;
  late final Map<String, List<RoutePattern>> _routePatterns;
  late final List<List<PatternConnection>> _connections;

  GtfsRouteIndex(this._data) {
    _buildIndices();
  }

  void _buildIndices() {
    _patterns = [];
    _stopToPatternIds = {};
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

      // Add pattern (only if we don't have it yet for this route)
      final routePatterns = _routePatterns.putIfAbsent(trip.routeId, () => []);
      if (routePatterns.isEmpty ||
          !routePatterns.any((p) => _sameStopSequence(p.stopIds, stopIds))) {
        // Precompute cumulative haversine distance along the stop sequence.
        // Cheap: ~stopCount haversines per pattern, computed once.
        // Also record an axis-aligned bounding box covering all stops —
        // O(1) "is this pattern near point P" prune for query-time work.
        final cumDist = List<double>.filled(stopIds.length, 0);
        var minLat = double.infinity,
            minLon = double.infinity,
            maxLat = double.negativeInfinity,
            maxLon = double.negativeInfinity;
        for (var i = 0; i < stopIds.length; i++) {
          final s = _data.stops[stopIds[i]];
          if (s != null) {
            if (s.lat < minLat) minLat = s.lat;
            if (s.lat > maxLat) maxLat = s.lat;
            if (s.lon < minLon) minLon = s.lon;
            if (s.lon > maxLon) maxLon = s.lon;
          }
          if (i > 0) {
            final a = _data.stops[stopIds[i - 1]];
            final b = _data.stops[stopIds[i]];
            final d = (a != null && b != null) ? _haversineStops(a, b) : 0.0;
            cumDist[i] = cumDist[i - 1] + d;
          }
        }
        if (minLat == double.infinity) {
          minLat = minLon = maxLat = maxLon = 0;
        }

        final patternId = _patterns.length;
        final pattern = RoutePattern(
          id: patternId,
          routeId: trip.routeId,
          stopIds: stopIds,
          headsign: trip.headsign,
          shapeId: trip.shapeId,
          cumDist: cumDist,
          minLat: minLat,
          minLon: minLon,
          maxLat: maxLat,
          maxLon: maxLon,
        );
        _patterns.add(pattern);
        routePatterns.add(pattern);

        for (final stopId in stopIds) {
          _stopToPatternIds.putIfAbsent(stopId, () => {}).add(patternId);
        }
      }
    }

    // Precompute pattern-to-pattern connections at every shared stop.
    // For each pattern P, for each stop S in P, find every OTHER pattern Q
    // that also contains S. Each (P, S, Q) becomes a connection record
    // describing where the transfer would happen.
    //
    // Cost: O(sum over patterns of (stopCount * avgPatternsPerStop)).
    // For Cochabamba: ~150 patterns, ~30 stops avg, ~5 patterns/stop avg
    // → ~22.5k iterations at boot. Trivial.
    _connections = List.generate(_patterns.length, (_) => []);
    for (var i = 0; i < _patterns.length; i++) {
      final p1 = _patterns[i];
      final r1 = _data.routes[p1.routeId];
      final shortName1 = r1?.shortName.trim() ?? '';
      for (var idx1 = 0; idx1 < p1.stopIds.length; idx1++) {
        final stopId = p1.stopIds[idx1];
        final patternIds = _stopToPatternIds[stopId];
        if (patternIds == null) continue;
        for (final j in patternIds) {
          if (j == i) continue;
          final p2 = _patterns[j];
          // Skip transfers within the same logical line. Two cases:
          //   (a) Same route_id (e.g., outbound + inbound encoded as
          //       multiple patterns of one route).
          //   (b) Same route_short_name across distinct route_ids
          //       (e.g., Cochabamba "Línea 209" split into route_id 67 and 68
          //       by direction/agency).
          // Both produce nonsensical "ride X then transfer to X" itineraries.
          if (p2.routeId == p1.routeId) continue;
          if (shortName1.isNotEmpty) {
            final r2 = _data.routes[p2.routeId];
            if (r2 != null && r2.shortName.trim() == shortName1) continue;
          }
          final idx2 = p2.indexOfStop(stopId);
          if (idx2 < 0) continue; // shouldn't happen given how the map is built
          _connections[i].add(PatternConnection(j, idx1, idx2));
        }
      }
      // Sort by myStopIdx ascending so query-time iteration can skip past
      // connections at or before the origin's index without scanning them.
      _connections[i].sort((a, b) => a.myStopIdx.compareTo(b.myStopIdx));
    }
  }

  bool _sameStopSequence(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Pattern by its in-memory id.
  RoutePattern patternById(int id) => _patterns[id];

  /// Total number of patterns indexed.
  int get patternCount => _patterns.length;

  /// Get all routes that serve a stop.
  Set<String> getRoutesAtStop(String stopId) {
    return _stopToRoutes[stopId] ?? const {};
  }

  /// Get all patterns that pass through a stop.
  List<RoutePattern> getPatternsAtStop(String stopId) {
    final ids = _stopToPatternIds[stopId];
    if (ids == null || ids.isEmpty) return const [];
    return [for (final id in ids) _patterns[id]];
  }

  /// Get all patterns for a route.
  List<RoutePattern> getPatternsForRoute(String routeId) {
    return _routePatterns[routeId] ?? const [];
  }

  /// Get all patterns across all routes.
  Iterable<RoutePattern> get patterns => _patterns;

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

  /// Precomputed transfer points from a given pattern.
  /// Empty list for unknown / deserialized patterns.
  List<PatternConnection> getConnectionsFor(int patternId) {
    if (patternId < 0 || patternId >= _connections.length) return const [];
    return _connections[patternId];
  }

  static double _haversineStops(GtfsStop a, GtfsStop b) {
    const r = 6371000.0;
    final lat1 = a.lat * pi / 180;
    final lat2 = b.lat * pi / 180;
    final dLat = (b.lat - a.lat) * pi / 180;
    final dLon = (b.lon - a.lon) * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * asin(sqrt(h));
  }
}
