import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/gtfs_stop.dart';

/// Result of a nearest stop query.
class NearbyStop {
  final GtfsStop stop;
  final double distance;

  const NearbyStop({
    required this.stop,
    required this.distance,
  });
}

/// Spatial index for fast nearest-stop queries using a KD-Tree.
class GtfsSpatialIndex {
  final Map<String, GtfsStop> _stops;
  late final _KdTree _tree;

  GtfsSpatialIndex(this._stops) {
    _tree = _KdTree(_stops.values.toList());
  }

  /// Find the nearest stops to a location.
  List<NearbyStop> findNearestStops(
    LatLng location, {
    int maxResults = 10,
    double maxDistance = 1000, // meters
  }) {
    final results = _tree.findNearest(
      location.latitude,
      location.longitude,
      maxResults: maxResults,
      maxDistance: maxDistance,
    );

    return results
        .map((r) => NearbyStop(stop: r.stop, distance: r.distance))
        .toList();
  }

  /// Find all stops within a radius.
  List<NearbyStop> findStopsInRadius(LatLng location, double radiusMeters) {
    return findNearestStops(
      location,
      maxResults: 100,
      maxDistance: radiusMeters,
    );
  }
}

/// Simple KD-Tree for 2D nearest neighbor search.
class _KdTree {
  _KdNode? _root;

  _KdTree(List<GtfsStop> stops) {
    if (stops.isNotEmpty) {
      _root = _buildTree(stops, 0);
    }
  }

  _KdNode? _buildTree(List<GtfsStop> stops, int depth) {
    if (stops.isEmpty) return null;

    final axis = depth % 2;
    stops.sort((a, b) {
      final aVal = axis == 0 ? a.lat : a.lon;
      final bVal = axis == 0 ? b.lat : b.lon;
      return aVal.compareTo(bVal);
    });

    final mid = stops.length ~/ 2;

    return _KdNode(
      stop: stops[mid],
      left: _buildTree(stops.sublist(0, mid), depth + 1),
      right: _buildTree(stops.sublist(mid + 1), depth + 1),
    );
  }

  List<_NearestResult> findNearest(
    double lat,
    double lon, {
    required int maxResults,
    required double maxDistance,
  }) {
    final results = <_NearestResult>[];
    _searchNearest(_root, lat, lon, 0, results, maxResults, maxDistance);
    results.sort((a, b) => a.distance.compareTo(b.distance));
    return results;
  }

  void _searchNearest(
    _KdNode? node,
    double lat,
    double lon,
    int depth,
    List<_NearestResult> results,
    int maxResults,
    double maxDistance,
  ) {
    if (node == null) return;

    final dist = _haversineDistance(lat, lon, node.stop.lat, node.stop.lon);

    if (dist <= maxDistance) {
      if (results.length < maxResults) {
        results.add(_NearestResult(stop: node.stop, distance: dist));
      } else if (dist < results.last.distance) {
        results.removeLast();
        results.add(_NearestResult(stop: node.stop, distance: dist));
        results.sort((a, b) => a.distance.compareTo(b.distance));
      }
    }

    final axis = depth % 2;
    final nodeVal = axis == 0 ? node.stop.lat : node.stop.lon;
    final targetVal = axis == 0 ? lat : lon;

    final first = targetVal < nodeVal ? node.left : node.right;
    final second = targetVal < nodeVal ? node.right : node.left;

    _searchNearest(first, lat, lon, depth + 1, results, maxResults, maxDistance);

    // Check if we need to search the other branch
    final axisDist = (targetVal - nodeVal).abs();
    final worstDist = results.length < maxResults
        ? maxDistance
        : results.last.distance;

    // Convert axis distance to meters (rough approximation)
    final axisDistMeters = axis == 0
        ? axisDist * 111000 // lat degrees to meters
        : axisDist * 111000 * math.cos(lat * math.pi / 180); // lon degrees

    if (axisDistMeters < worstDist) {
      _searchNearest(second, lat, lon, depth + 1, results, maxResults, maxDistance);
    }
  }

  /// Calculate Haversine distance in meters.
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // meters

    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }
}

class _KdNode {
  final GtfsStop stop;
  final _KdNode? left;
  final _KdNode? right;

  _KdNode({
    required this.stop,
    this.left,
    this.right,
  });
}

class _NearestResult {
  final GtfsStop stop;
  final double distance;

  _NearestResult({required this.stop, required this.distance});
}
