import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/gtfs_stop.dart';

/// Result of a nearest stop query.
class NearbyStop {
  final GtfsStop stop;
  final double distance;

  const NearbyStop({required this.stop, required this.distance});
}

/// Spatial index for fast nearest-stop queries using a KD-Tree.
class GtfsSpatialIndex {
  final Map<String, GtfsStop> _stops;
  late final _KdTree _tree;

  GtfsSpatialIndex(this._stops) {
    _tree = _KdTree(_stops.values.toList());
  }

  /// Restores an index from the pre-order traversal of a tree built by
  /// [GtfsSpatialIndex.new] over the same stops (see [preorder]). The tree
  /// shape is a function of the stop count alone (median split), so the
  /// result is the very same tree — same answers, same result order —
  /// without sorting anything. Used by the planner index snapshot.
  GtfsSpatialIndex.restore(this._stops, List<GtfsStop> preorder) {
    _tree = _KdTree.fromPreorder(preorder);
  }

  /// The tree's stops in pre-order (node, left subtree, right subtree);
  /// feeds [GtfsSpatialIndex.restore].
  List<GtfsStop> get preorder => _tree.preorder();

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

  /// Find ALL stops within [radiusMeters] of [location], nearest first.
  ///
  /// Unlike [findNearestStops] there is no result cap: this is an exact
  /// range query, so callers that must not miss a neighbour (the transfer
  /// index links every stop pair within walking range) can rely on it.
  List<NearbyStop> findStopsInRadius(LatLng location, double radiusMeters) {
    final results = <NearbyStop>[];
    _tree.visitWithin(
      location.latitude,
      location.longitude,
      radiusMeters,
      (stop, distance) =>
          results.add(NearbyStop(stop: stop, distance: distance)),
    );
    results.sort((a, b) => a.distance.compareTo(b.distance));
    return results;
  }

  /// Calls [visit] for every stop within [radiusMeters] of ([lat], [lon]),
  /// in tree order (not sorted), without allocating a result list. Meant
  /// for bulk work such as building the transfer index, which runs one
  /// range query per pattern stop — ~100k on a dense feed.
  void forEachStopWithin(
    double lat,
    double lon,
    double radiusMeters,
    void Function(GtfsStop stop, double distance) visit,
  ) {
    _tree.visitWithin(lat, lon, radiusMeters, visit);
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

  /// Rebuilds the tree from its pre-order listing. [_buildTree] puts the
  /// median (`length ~/ 2`) at the node with the `mid` smaller stops on the
  /// left, so the left subtree of a node covering `count` stops always has
  /// `count ~/ 2` of them.
  _KdTree.fromPreorder(List<GtfsStop> preorder) {
    if (preorder.isNotEmpty) {
      _root = _fromPreorder(preorder, 0, preorder.length);
    }
  }

  _KdNode? _fromPreorder(List<GtfsStop> stops, int start, int count) {
    if (count == 0) return null;
    final leftCount = count ~/ 2;
    return _KdNode(
      stop: stops[start],
      left: _fromPreorder(stops, start + 1, leftCount),
      right: _fromPreorder(stops, start + 1 + leftCount, count - leftCount - 1),
    );
  }

  List<GtfsStop> preorder() {
    final out = <GtfsStop>[];
    void visit(_KdNode? node) {
      if (node == null) return;
      out.add(node.stop);
      visit(node.left);
      visit(node.right);
    }

    visit(_root);
    return out;
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
      // Invariant: once full, `results` is sorted by distance so
      // `results.last` is the true worst — both the eviction and the
      // pruning bound below depend on it. The previous code accumulated
      // unsorted and evicted `.last` blindly, so the pool could keep an
      // arbitrary subset instead of the k nearest (#977).
      if (results.length < maxResults) {
        results.add(_NearestResult(stop: node.stop, distance: dist));
        if (results.length == maxResults) {
          results.sort((a, b) => a.distance.compareTo(b.distance));
        }
      } else if (dist < results.last.distance) {
        results.removeLast();
        var lo = 0;
        var hi = results.length;
        while (lo < hi) {
          final mid = (lo + hi) >> 1;
          if (results[mid].distance <= dist) {
            lo = mid + 1;
          } else {
            hi = mid;
          }
        }
        results.insert(lo, _NearestResult(stop: node.stop, distance: dist));
      }
    }

    final axis = depth % 2;
    final nodeVal = axis == 0 ? node.stop.lat : node.stop.lon;
    final targetVal = axis == 0 ? lat : lon;

    final first = targetVal < nodeVal ? node.left : node.right;
    final second = targetVal < nodeVal ? node.right : node.left;

    _searchNearest(
      first,
      lat,
      lon,
      depth + 1,
      results,
      maxResults,
      maxDistance,
    );

    // Check if we need to search the other branch
    final axisDist = (targetVal - nodeVal).abs();
    final worstDist = results.length < maxResults
        ? maxDistance
        : results.last.distance;

    // Convert axis distance to meters (rough approximation)
    final axisDistMeters = axis == 0
        ? axisDist *
              111000 // lat degrees to meters
        : axisDist * 111000 * math.cos(lat * math.pi / 180); // lon degrees

    if (axisDistMeters < worstDist) {
      _searchNearest(
        second,
        lat,
        lon,
        depth + 1,
        results,
        maxResults,
        maxDistance,
      );
    }
  }

  /// Exact range query: visits every stop within [radius] meters.
  void visitWithin(
    double lat,
    double lon,
    double radius,
    void Function(GtfsStop stop, double distance) visit,
  ) {
    _searchWithin(_root, lat, lon, 0, radius, visit);
  }

  void _searchWithin(
    _KdNode? node,
    double lat,
    double lon,
    int depth,
    double radius,
    void Function(GtfsStop stop, double distance) visit,
  ) {
    if (node == null) return;

    // Cheap rectangular pre-check before the trigonometry: a stop more than
    // `radius` away along latitude alone cannot be inside the circle. Same
    // 1% padding as the pruning below.
    if ((node.stop.lat - lat).abs() * 111000 <= radius * 1.01) {
      final dist = _haversineDistance(lat, lon, node.stop.lat, node.stop.lon);
      if (dist <= radius) {
        visit(node.stop, dist);
      }
    }

    final axis = depth % 2;
    final nodeVal = axis == 0 ? node.stop.lat : node.stop.lon;
    final targetVal = axis == 0 ? lat : lon;

    final first = targetVal < nodeVal ? node.left : node.right;
    final second = targetVal < nodeVal ? node.right : node.left;

    _searchWithin(first, lat, lon, depth + 1, radius, visit);

    // The far side can only hold hits if the splitting plane itself is
    // within the radius. Same degree→meter approximation as
    // `_searchNearest`, padded by 1% so the rough conversion never prunes
    // a stop that the exact haversine would have accepted.
    final axisDist = (targetVal - nodeVal).abs();
    final axisDistMeters = axis == 0
        ? axisDist * 111000
        : axisDist * 111000 * math.cos(lat * math.pi / 180);
    if (axisDistMeters <= radius * 1.01) {
      _searchWithin(second, lat, lon, depth + 1, radius, visit);
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

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
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

  _KdNode({required this.stop, this.left, this.right});
}

class _NearestResult {
  final GtfsStop stop;
  final double distance;

  _NearestResult({required this.stop, required this.distance});
}
