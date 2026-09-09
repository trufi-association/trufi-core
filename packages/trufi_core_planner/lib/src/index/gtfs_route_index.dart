import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import '../models/gtfs_stop.dart';
import '../models/gtfs_stop_time.dart';
import '../parser/gtfs_parser.dart';
import 'gtfs_spatial_index.dart';

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

/// A precomputed transfer point between two patterns.
///
/// The rider alights the source pattern at `myStopIdx` and boards the other
/// pattern at `otherStopIdx`. The two stops are the same GTFS stop when
/// [walkMeters] is 0, or two distinct stops within the index's transfer
/// radius otherwise (e.g. the two kerbs of an avenue, which OSM-derived
/// feeds encode as different `stop_id`s).
class PatternConnection {
  /// Index of the other pattern in `GtfsRouteIndex._patterns`.
  final int otherPatternId;

  /// Stop position in the source pattern at which the rider alights.
  final int myStopIdx;

  /// Stop position in the destination pattern at which the rider boards.
  final int otherStopIdx;

  /// Straight-line distance between the alight and board stops, in meters.
  final double walkMeters;

  const PatternConnection(
    this.otherPatternId,
    this.myStopIdx,
    this.otherStopIdx, [
    this.walkMeters = 0,
  ]);
}

/// Read-only view over one pattern's precomputed connections.
///
/// The index keeps every connection of every pattern in four flat typed
/// arrays (three `Int32List` + one `Float32List`, 16 bytes per connection)
/// instead of one object each: with walkable transfers Cochabamba holds
/// ~300k connections, which is ~5 MB columnar versus ~17 MB boxed. This
/// view exposes them as a `List<PatternConnection>` for convenience and as
/// `...At(i)` accessors for allocation-free hot loops.
///
/// Connections are sorted by [PatternConnection.myStopIdx] ascending and,
/// within one alight stop, by [PatternConnection.walkMeters] ascending —
/// so a scan can skip everything at or before a boarding position with
/// [firstIndexAfter], and meets the shortest walks first.
class PatternConnections extends ListBase<PatternConnection> {
  final Int32List _other;
  final Int32List _myIdx;
  final Int32List _otherIdx;
  final Float32List _walk;
  final int _start;
  final int _end;

  const PatternConnections._(
    this._other,
    this._myIdx,
    this._otherIdx,
    this._walk,
    this._start,
    this._end,
  );

  /// A view with no connections (unknown / deserialized patterns).
  static final PatternConnections empty = PatternConnections._(
    Int32List(0),
    Int32List(0),
    Int32List(0),
    Float32List(0),
    0,
    0,
  );

  @override
  int get length => _end - _start;

  @override
  PatternConnection operator [](int index) {
    RangeError.checkValidIndex(index, this);
    final k = _start + index;
    return PatternConnection(_other[k], _myIdx[k], _otherIdx[k], _walk[k]);
  }

  int otherPatternIdAt(int index) => _other[_start + index];
  int myStopIdxAt(int index) => _myIdx[_start + index];
  int otherStopIdxAt(int index) => _otherIdx[_start + index];
  double walkMetersAt(int index) => _walk[_start + index];

  /// Index of the first connection whose alight position is strictly after
  /// [stopIdx] (binary search on the sorted `myStopIdx` column). Returns
  /// [length] when there is none.
  int firstIndexAfter(int stopIdx) {
    var lo = 0;
    var hi = length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_myIdx[_start + mid] <= stopIdx) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  @override
  set length(int newLength) =>
      throw UnsupportedError('PatternConnections is read-only');

  @override
  void operator []=(int index, PatternConnection value) =>
      throw UnsupportedError('PatternConnections is read-only');
}

/// Index for fast route lookups.
class GtfsRouteIndex {
  /// Default radius within which two distinct stops count as one transfer
  /// point. Matches MOTIS' `link_stop_distance` (100 m straight-line);
  /// OpenTripPlanner pre-computes street transfers up to 30 min / 2 km, so
  /// neither engine requires two lines to share a `stop_id` to connect.
  static const double defaultTransferRadiusMeters = 100;

  /// Default for [sameNameRouteLimit]: a `route_short_name` carried by up to
  /// this many `route_id`s is treated as one line (outbound/inbound or
  /// per-agency split, e.g. Cochabamba's "209" as route_id 67 and 68).
  static const int defaultSameNameRouteLimit = 3;

  final GtfsData _data;

  /// Stops within this straight-line distance of an alight stop are
  /// boarding candidates for a transfer. `0` restores the historical
  /// behaviour of only connecting patterns that share a `stop_id`.
  final double transferRadiusMeters;

  /// Two routes with the same trimmed `route_short_name` are considered the
  /// same line — and never connected by a transfer — only when that name is
  /// carried by at most this many `route_id`s. Feeds built per OSM relation
  /// (Sana'a: 157 routes named "7") share one informal ref across dozens of
  /// genuinely different lines, and treating them as one line silently
  /// discards every valid transfer between them.
  final int sameNameRouteLimit;

  late final List<RoutePattern> _patterns;
  late final Map<String, Set<int>> _stopToPatternIds;
  late final Map<String, Set<String>> _stopToRoutes;
  late final Map<String, List<RoutePattern>> _routePatterns;
  late final Map<String, String> _lineKeyByRoute;

  // Columnar connection storage (CSR): pattern p owns entries
  // [_connStart[p], _connStart[p + 1]).
  late final Int32List _connStart;
  late final Int32List _connOther;
  late final Int32List _connMyIdx;
  late final Int32List _connOtherIdx;
  late final Float32List _connWalk;

  /// Builds the index. [spatialIndex] is used to find walkable transfer
  /// stops; when omitted (and [transferRadiusMeters] > 0) one is built from
  /// the feed's stops.
  GtfsRouteIndex(
    this._data, {
    GtfsSpatialIndex? spatialIndex,
    this.transferRadiusMeters = defaultTransferRadiusMeters,
    this.sameNameRouteLimit = defaultSameNameRouteLimit,
  }) {
    _buildIndices();
    _buildLineKeys();
    _buildConnections(
      transferRadiusMeters > 0
          ? (spatialIndex ?? GtfsSpatialIndex(_data.stops))
          : null,
    );
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
  }

  /// Assigns every route a "line key": routes with the same key are one
  /// logical line. The key is the trimmed `route_short_name` when that name
  /// is shared by at most [sameNameRouteLimit] routes (a direction/agency
  /// split of one line), and the `route_id` itself otherwise — including
  /// when the short name is empty.
  void _buildLineKeys() {
    final routesPerName = <String, int>{};
    for (final r in _data.routes.values) {
      final name = r.shortName.trim();
      if (name.isEmpty) continue;
      routesPerName[name] = (routesPerName[name] ?? 0) + 1;
    }
    _lineKeyByRoute = {};
    for (final r in _data.routes.values) {
      final name = r.shortName.trim();
      final shared = routesPerName[name] ?? 0;
      _lineKeyByRoute[r.id] = name.isNotEmpty && shared <= sameNameRouteLimit
          ? 'n:$name'
          : 'r:${r.id}';
    }
  }

  /// Precomputes pattern-to-pattern transfer points.
  ///
  /// Two kinds of connection are stored for each pattern P:
  ///
  /// * **Shared stop** (walk 0): for each stop S of P, every other pattern Q
  ///   that also serves S — exactly the historical table, kept in full.
  /// * **Walkable** (walk > 0): Q serves a stop T within
  ///   [transferRadiusMeters] of S but not S itself. OSM-derived feeds give
  ///   the two kerbs of a street different stop ids, so two lines crossing
  ///   at the same corner in opposite directions could never be chained
  ///   (trufi-sanaa#2 — 1953 stop pairs within 15 m in that feed).
  ///
  /// Walkable connections are thinned to one per crossing: at a given S
  /// only Q's nearest stop is kept, and along P only the stops where the
  /// walk to Q is a local minimum (strictly shorter than at the previous
  /// stop, no longer than at the next). Where P and Q run side by side
  /// with stops every 30 m, every stop of P is within 100 m of several
  /// stops of Q; keeping all of them multiplied the dense Cochabamba feed
  /// (23.7k stops, 657 patterns) from 1.2 M to 16 M connections for no
  /// extra reachability — boarding Q at its first nearby stop already
  /// reaches everything downstream, and stops inside the shared stretch are
  /// served by P directly.
  ///
  /// Transfers within one logical line (same line key, see
  /// [lineKeyForRoute]) are skipped: "ride 209 then transfer to 209" is
  /// never a useful itinerary.
  void _buildConnections(GtfsSpatialIndex? spatialIndex) {
    final n = _patterns.length;
    final starts = Int32List(n + 1);
    // Per-pattern chunks, concatenated once the total is known — keeps the
    // build free of boxed doubles and lets the final arrays be exact-sized.
    final chunkOther = <Int32List>[];
    final chunkMyIdx = <Int32List>[];
    final chunkOtherIdx = <Int32List>[];
    final chunkWalk = <Float32List>[];

    // Integer line id per pattern: the inner loops below run once per
    // (stop, neighbouring pattern) pair — hundreds of thousands of times on
    // a dense feed — so compare ints, not line-key strings.
    final lineIds = <String, int>{};
    final patternLine = Int32List(n);
    for (var i = 0; i < n; i++) {
      final key = lineKeyForRoute(_patterns[i].routeId);
      patternLine[i] = lineIds.putIfAbsent(key, () => lineIds.length);
    }

    // "Nearest stop of every pattern within the radius" depends only on the
    // stop, not on the pattern being built — compute it once per distinct
    // stop. Patterns share most of their stops on a dense feed (Cochabamba:
    // 23.7k stops, ~95k pattern-stops), and consecutive stops 30 m apart
    // have neighbourhoods that overlap almost entirely.
    //
    // Scratch indexed by pattern id (reset through `touched` after each stop)
    // instead of a hash map: on the dense feed the visitor below runs a few
    // million times.
    final neighbourhoods = <String, _StopNeighbourhood>{};
    final bestWalk = Float64List(n)..fillRange(0, n, double.infinity);
    final bestIdx = Int32List(n);
    final touched = <int>[];
    // Pattern ids per stop as a plain list — iterating a Set<int> is slower
    // and this is the innermost loop of the build.
    final patternsAtStop = <String, List<int>>{
      for (final e in _stopToPatternIds.entries) e.key: e.value.toList(),
    };
    _StopNeighbourhood neighbourhoodOf(String stopId) {
      final cached = neighbourhoods[stopId];
      if (cached != null) return cached;
      touched.clear();
      final sharing = patternsAtStop[stopId];
      if (sharing != null) {
        for (final j in sharing) {
          final idx2 = _patterns[j].indexOfStop(stopId);
          if (idx2 < 0) continue;
          bestWalk[j] = 0;
          bestIdx[j] = idx2;
          touched.add(j);
        }
      }
      final stop = _data.stops[stopId];
      if (spatialIndex != null && stop != null) {
        spatialIndex.forEachStopWithin(
          stop.lat,
          stop.lon,
          transferRadiusMeters,
          (near, distance) {
            if (near.id == stopId) return; // shared stops handled above
            final atNeighbour = patternsAtStop[near.id];
            if (atNeighbour == null) return;
            for (final j in atNeighbour) {
              // Keep the nearest boarding stop per pattern (a shared stop,
              // walk 0, always wins).
              final current = bestWalk[j];
              if (current <= distance) continue;
              final idx2 = _patterns[j].indexOfStop(near.id);
              if (idx2 < 0) continue;
              if (current == double.infinity) touched.add(j);
              bestWalk[j] = distance;
              bestIdx[j] = idx2;
            }
          },
        );
      }
      final result = _StopNeighbourhood.collect(touched, bestIdx, bestWalk);
      for (final j in touched) {
        bestWalk[j] = double.infinity;
      }
      return neighbourhoods[stopId] = result;
    }

    var total = 0;
    // Scratch: indices into a neighbourhood, insertion-sorted by walk.
    var order = Int32List(64);

    for (var i = 0; i < n; i++) {
      final p1 = _patterns[i];
      final line1 = patternLine[i];
      final stopCount = p1.stopIds.length;
      final nearest = [
        for (final stopId in p1.stopIds) neighbourhoodOf(stopId),
      ];

      /// Whether entry [k] of the neighbourhood at [idx1] becomes a
      /// connection of P: another line, and — for a walkable one — a local
      /// minimum of the walk along P.
      bool keep(int idx1, int k) {
        final here = nearest[idx1];
        final j = here.patternIds[k];
        if (j == i || patternLine[j] == line1) return false;
        final walk = here.walks[k];
        if (walk == 0) return true;
        final wPrev = idx1 > 0
            ? (nearest[idx1 - 1].walkTo(j) ?? double.infinity)
            : double.infinity;
        final wNext = idx1 + 1 < stopCount
            ? (nearest[idx1 + 1].walkTo(j) ?? double.infinity)
            : double.infinity;
        return walk < wPrev && walk <= wNext;
      }

      // Count, then fill exact-sized chunks: no per-connection allocation.
      var count = 0;
      for (var idx1 = 0; idx1 < stopCount; idx1++) {
        final len = nearest[idx1].length;
        for (var k = 0; k < len; k++) {
          if (keep(idx1, k)) count++;
        }
      }
      final other = Int32List(count);
      final myIdx = Int32List(count);
      final otherIdx = Int32List(count);
      final walk = Float32List(count);
      var at = 0;
      for (var idx1 = 0; idx1 < stopCount; idx1++) {
        final here = nearest[idx1];
        if (order.length < here.length) order = Int32List(here.length * 2);
        // Shortest walks first within one alight stop; insertion sort is
        // stable, and the neighbourhood is in pattern-id order, so ties
        // fall back to pattern id and the table is deterministic.
        var m = 0;
        for (var k = 0; k < here.length; k++) {
          if (!keep(idx1, k)) continue;
          final w = here.walks[k];
          var pos = m;
          while (pos > 0 && here.walks[order[pos - 1]] > w) {
            order[pos] = order[pos - 1];
            pos--;
          }
          order[pos] = k;
          m++;
        }
        for (var q = 0; q < m; q++) {
          final k = order[q];
          other[at] = here.patternIds[k];
          myIdx[at] = idx1;
          otherIdx[at] = here.stopIdxs[k];
          walk[at] = here.walks[k];
          at++;
        }
      }
      chunkOther.add(other);
      chunkMyIdx.add(myIdx);
      chunkOtherIdx.add(otherIdx);
      chunkWalk.add(walk);
      total += count;
      starts[i + 1] = total;
    }

    _connStart = starts;
    _connOther = Int32List(total);
    _connMyIdx = Int32List(total);
    _connOtherIdx = Int32List(total);
    _connWalk = Float32List(total);
    for (var i = 0; i < n; i++) {
      final at = starts[i];
      _connOther.setAll(at, chunkOther[i]);
      _connMyIdx.setAll(at, chunkMyIdx[i]);
      _connOtherIdx.setAll(at, chunkOtherIdx[i]);
      _connWalk.setAll(at, chunkWalk[i]);
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

  /// Total number of precomputed connections across all patterns.
  int get connectionCount => _connStart.isEmpty ? 0 : _connStart.last;

  /// Identity of the logical line a route belongs to. Two routes with the
  /// same key are one line (never chained by a transfer, collapsed to one
  /// itinerary row); see [sameNameRouteLimit] for when a shared
  /// `route_short_name` counts. Unknown routes are their own line.
  String lineKeyForRoute(String routeId) =>
      _lineKeyByRoute[routeId] ?? 'r:$routeId';

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

  /// Precomputed transfer points from a given pattern, sorted by alight
  /// position then walk distance. Empty for unknown / deserialized patterns.
  PatternConnections getConnectionsFor(int patternId) {
    if (patternId < 0 || patternId >= _patterns.length) {
      return PatternConnections.empty;
    }
    return PatternConnections._(
      _connOther,
      _connMyIdx,
      _connOtherIdx,
      _connWalk,
      _connStart[patternId],
      _connStart[patternId + 1],
    );
  }

  static double _haversineStops(GtfsStop a, GtfsStop b) {
    const r = 6371000.0;
    final lat1 = a.lat * pi / 180;
    final lat2 = b.lat * pi / 180;
    final dLat = (b.lat - a.lat) * pi / 180;
    final dLon = (b.lon - a.lon) * pi / 180;
    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * asin(sqrt(h));
  }
}

/// Build-time record for one stop: the nearest stop of every pattern within
/// the transfer radius (walk 0 when the pattern serves the stop itself).
/// Columns sorted by pattern id so [walkTo] is a binary search.
class _StopNeighbourhood {
  final Int32List patternIds;
  final Int32List stopIdxs;
  final Float32List walks;

  _StopNeighbourhood._(this.patternIds, this.stopIdxs, this.walks);

  /// Snapshot of the scratch arrays for the pattern ids in [touched].
  factory _StopNeighbourhood.collect(
    List<int> touched,
    Int32List bestIdx,
    Float64List bestWalk,
  ) {
    final ids = touched.toList()..sort();
    final patternIds = Int32List(ids.length);
    final stopIdxs = Int32List(ids.length);
    final walks = Float32List(ids.length);
    for (var k = 0; k < ids.length; k++) {
      final j = ids[k];
      patternIds[k] = j;
      stopIdxs[k] = bestIdx[j];
      walks[k] = bestWalk[j];
    }
    return _StopNeighbourhood._(patternIds, stopIdxs, walks);
  }

  int get length => patternIds.length;

  /// Walk to [patternId]'s nearest stop, or null when out of range.
  double? walkTo(int patternId) {
    var lo = 0;
    var hi = patternIds.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      final v = patternIds[mid];
      if (v == patternId) return walks[mid];
      if (v < patternId) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return null;
  }
}
