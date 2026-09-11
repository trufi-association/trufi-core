import 'dart:math';
import 'dart:typed_data';

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

  /// Board/alight positions in `pattern.stopIds`, recorded at build time.
  /// `-1` when unknown (e.g. segments deserialized from JSON). They must be
  /// carried instead of re-derived from the stop IDs: on patterns that visit
  /// a stop twice (circular lines) `indexOfStop` returns the FIRST occurrence,
  /// which is not necessarily the one this segment rides through (#986).
  final int fromIdx;
  final int toIdx;

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
    this.fromIdx = -1,
    this.toIdx = -1,
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

  /// Straight-line meters walked between transit segments (alight stop of
  /// one leg → boarding stop of the next), summed over all transfers. `0`
  /// when every transfer happens at a shared stop.
  final double transferWalkDistance;

  const RoutingPath({
    required this.originWalkDistance,
    required this.originStop,
    required this.segments,
    required this.destinationStop,
    required this.destinationWalkDistance,
    required this.score,
    this.transferWalkDistance = 0,
  });

  /// Total walk distance in meters, transfer walks included.
  double get totalWalkDistance =>
      originWalkDistance + destinationWalkDistance + transferWalkDistance;

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
      transferWalkDistance: (json['transferWalk'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'originWalk': originWalkDistance,
    'originStop': originStop.toJson(),
    'segments': segments.map((s) => s.toJson()).toList(),
    'destinationStop': destinationStop.toJson(),
    'destinationWalk': destinationWalkDistance,
    if (transferWalkDistance > 0) 'transferWalk': transferWalkDistance,
    'totalWalk': totalWalkDistance,
    'transfers': transfers,
    'totalStops': totalStops,
    'score': score,
  };
}

/// Service for GTFS-based routing.
class GtfsRoutingService {
  /// Default for [maxTransferCandidates].
  ///
  /// It was 1 500 when every candidate built two segments. Since a
  /// candidate is now a score comparison (one path per pattern pair is
  /// kept), it costs ~6× less — and walkable transfers roughly double the
  /// connections per pattern, so at 1 500 the budget ran out on the first
  /// origin stops: on the dense Cochabamba feed the best itinerary of 24 of
  /// 340 random queries got worse than with shared stops only (up to +23 %
  /// score). At 20 000 none did, at ~9 ms average per query on desktop
  /// (~5 ms at 1 500; the maximum is set by the direct phase either way).
  static const int defaultMaxTransferCandidates = 20000;

  /// Default for [maxMultiTransferScans].
  ///
  /// The multi-transfer search (see [findRoutes]) scans the connections of
  /// every pattern it has labelled, once per round. Measured over 400
  /// random pairs on the dense Cochabamba feed (2.6 M connections, 800 m
  /// walk): 77 k scans on average and 2.9 M in the worst pair for two
  /// rounds; Sana'a stays under 10 k. The default sits well above the
  /// measured maximum so it only guards against a pathological feed.
  static const int defaultMaxMultiTransferScans = 6000000;

  final GtfsData data;
  final GtfsSpatialIndex spatialIndex;
  final GtfsRouteIndex routeIndex;

  /// Upper bound on the (transfer connection, destination stop) candidates
  /// one query evaluates in the one-transfer phase; bounds tail latency on
  /// dense feeds. Candidates are enumerated origin stop by origin stop,
  /// nearest first, so when the budget runs out farther origin stops are
  /// never considered.
  final int maxTransferCandidates;

  /// Upper bound on the connection scans one query spends in the
  /// multi-transfer search (`maxTransfers >= 2`, all rounds together).
  /// When it runs out the search stops expanding and answers with the
  /// chains found so far, so a truncated query can miss itineraries but
  /// never returns a malformed one. See [defaultMaxMultiTransferScans].
  final int maxMultiTransferScans;

  GtfsRoutingService({
    required this.data,
    required this.spatialIndex,
    required this.routeIndex,
    this.maxTransferCandidates = defaultMaxTransferCandidates,
    this.maxMultiTransferScans = defaultMaxMultiTransferScans,
  });

  int _multiTransferSearches = 0;

  /// How many queries so far went into the multi-transfer search (phase 3
  /// of [findRoutes]). Diagnostics: the phase only runs when the direct and
  /// one-transfer phases found nothing, and tests pin that rule here.
  int get multiTransferSearches => _multiTransferSearches;

  /// Integer line id per pattern (see [GtfsRouteIndex.lineKeyForRoute]),
  /// built on the first multi-transfer search: the chain rule compares
  /// lines on every scanned connection, so it compares ints, not strings.
  late final Int32List _patternLine = _buildPatternLines();

  Int32List _buildPatternLines() {
    final n = routeIndex.patternCount;
    final ids = <String, int>{};
    final lines = Int32List(n);
    for (var i = 0; i < n; i++) {
      final key = routeIndex.lineKeyForRoute(routeIndex.patternById(i).routeId);
      lines[i] = ids.putIfAbsent(key, () => ids.length);
    }
    return lines;
  }

  /// Find routes between two locations.
  ///
  /// Three phases, each one only when the previous ones came back empty at
  /// the end (a direct line suppresses transfers, see below):
  ///   1. direct routes (no transfer);
  ///   2. routes with exactly one transfer, when [maxTransfers] >= 1;
  ///   3. routes with 2..[maxTransfers] transfers — the fewest that reach
  ///      the destination — through a round-based search over the pattern
  ///      graph, **only when phases 1 and 2 produced no itinerary at all**.
  ///      A city that keeps the default (1) never runs it; a city that opts
  ///      in gets exactly today's answer wherever today's answer exists.
  ///
  /// Results are returned in buckets:
  ///   1. up to [maxDirects] zero-transfer paths (best by score)
  ///   2. up to [maxTransferPaths] transfer paths (best by score) — the
  ///      one-transfer ones, or the multi-transfer ones when phase 3 ran.
  /// Direct routes always come first in the returned list.
  ///
  /// [maxTransfers] must be >= 0; `0` returns direct routes only. Values
  /// above 3 rarely add anything (on Sana'a, the most fragmented feed
  /// measured, two transfers take a random pair from 54 % to 77.5 %
  /// plannable and three to 90 %) and the search stops on its own once no
  /// new pattern is reached.
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
    int maxStopCandidates = 150,
  }) {
    if (maxTransfers < 0) {
      throw ArgumentError.value(maxTransfers, 'maxTransfers', 'must be >= 0');
    }

    // Consider every stop within walking distance (bounded by
    // [maxStopCandidates]), not just the nearest handful: in dense
    // networks the boarding stop of a direct line is often slightly
    // farther than the closest stops, and capping too low makes the
    // planner blind to it — surfacing transfer-heavy routes instead
    // (issue #926).
    final originStops = spatialIndex.findNearestStops(
      origin,
      maxResults: maxStopCandidates,
      maxDistance: maxWalkDistance,
    );

    final destinationStops = spatialIndex.findNearestStops(
      destination,
      maxResults: maxStopCandidates,
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

    final uniquePaths = _dedupeByLine(paths);

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
      if (directs.length >= maxDirects &&
          transfers.length >= maxTransferPaths) {
        break;
      }
    }
    final ordered = directs.isNotEmpty ? directs : transfers;

    // Phase 3: two or more transfers, only when nothing else exists. The
    // same "fewer transfers win outright" rule that hides transfers behind
    // a direct line hides these behind any one-transfer itinerary, so a
    // query that plans today returns exactly what it returned before.
    if (ordered.isEmpty && maxTransfers >= 2) {
      final multi = _findMultiTransferRoutes(
        originStops,
        destinationStops,
        maxTransfers: maxTransfers,
      );
      multi.sort((a, b) => a.score.compareTo(b.score));
      return _dedupeByLine(
        multi,
      ).take(min(maxTransferPaths, maxResults)).map(_resolvePathStops).toList();
    }

    return ordered.take(maxResults).map(_resolvePathStops).toList();
  }

  /// Keeps only the best path per line combination of a score-sorted list.
  /// E.g., all "Bus 15 → Z14" variants collapse into the best one,
  /// leaving room for genuinely different route options. The key is the
  /// index's line key, not the bare `route_short_name`: where many
  /// distinct lines share one short name (Sana'a's "7"), keying by name
  /// would collapse every "7 → 7" itinerary — different lines, different
  /// terminals — into a single row.
  List<RoutingPath> _dedupeByLine(List<RoutingPath> sortedPaths) {
    final seen = <String>{};
    final uniquePaths = <RoutingPath>[];
    for (final path in sortedPaths) {
      final key = path.segments
          .map((s) => routeIndex.lineKeyForRoute(s.route.id))
          .join('|');
      if (seen.add(key)) {
        uniquePaths.add(path);
      }
    }
    return uniquePaths;
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
      final originPatterns = routeIndex.getPatternsAtStop(originNearby.stop.id);
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
  ///
  /// A connection may alight and board at two different stops (walkable
  /// transfer, see [GtfsRouteIndex.transferRadiusMeters]): the second leg
  /// then starts at the real boarding stop and the walk between the two is
  /// scored like any other walked meter and reported as
  /// [RoutingPath.transferWalkDistance].
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
    final straightLine = _haversine(
      originStops.first.stop.position,
      destinationStops.first.stop.position,
    );
    // "Transfer point shouldn't be further from dest than origin is" — rules
    // out detours ratio > 2× without a computed score. Hard floor of 3 km
    // keeps short trips from being over-pruned (close pairs may still need
    // a transfer at a hub that's a few km away).
    final transferMaxDistFromDestM = max(3000.0, straightLine);

    // Hard cap on total candidate enumeration, bounding tail latency in
    // dense feeds where the connection table yields thousands of valid
    // (alight, board, destination) candidates per query. The budget is
    // spent origin stop by origin stop, nearest first: once it runs out the
    // remaining origin stops are never looked at, so a cap that is too low
    // silently drops good itineraries (see [maxTransferCandidates]).
    final maxCandidatesEnumerated = maxTransferCandidates;
    var enumerated = 0;

    // Only the best candidate per (origin pattern, other pattern) pair can
    // survive the line-key dedupe in [findRoutes], so score first and keep
    // one path per pair: the final result is identical, and far fewer
    // segment objects are built and sorted. With walkable transfers a
    // pattern pair typically yields tens of (alight, board, dest) variants.
    final patternCount = routeIndex.patternCount;
    final bestByPair = <int, RoutingPath>{};

    origins:
    for (final originNearby in originStops) {
      final originPatterns = routeIndex.getPatternsAtStop(originNearby.stop.id);
      for (final originPattern in originPatterns) {
        final originIdx = originPattern.indexOfStop(originNearby.stop.id);
        if (originIdx < 0) continue;

        final originRoute = data.routes[originPattern.routeId];
        if (originRoute == null) continue;

        final conns = routeIndex.getConnectionsFor(originPattern.id);
        // Transfer stop must be AFTER the origin within the origin pattern;
        // connections are sorted by alight position, so jump straight past
        // the ones at or before it.
        for (var k = conns.firstIndexAfter(originIdx); k < conns.length; k++) {
          // Skip patterns that don't serve any destination stop.
          final otherPatternId = conns.otherPatternIdAt(k);
          final destStopsOnOther = relevantDestStops[otherPatternId];
          if (destStopsOnOther == null) continue;

          final alightIdx = conns.myStopIdxAt(k);
          final alightStop = data.stops[originPattern.stopIds[alightIdx]];
          if (alightStop == null) continue;

          // Discard transfers that happen far from the destination region.
          // The check is on the transfer point itself, not the pattern's
          // overall bbox: a long route may sweep through the dest area at
          // some point, but its bbox alone isn't enough to know which stop
          // does. This pointwise version preserves valid transfers and
          // skips the "ride past the destination then come back" candidates.
          if (destBbox != null &&
              !_pointNearBbox(
                alightStop.lat,
                alightStop.lon,
                destBbox,
                transferMaxDistFromDestM,
              )) {
            continue;
          }

          final otherPattern = routeIndex.patternById(otherPatternId);
          final boardIdx = conns.otherStopIdxAt(k);
          final transferWalk = conns.walkMetersAt(k);
          final pairKey = originPattern.id * patternCount + otherPatternId;
          final transit1 = originPattern.distanceBetween(originIdx, alightIdx);

          for (final destNearby in destStopsOnOther) {
            final destIdx = otherPattern.indexOfStop(destNearby.stop.id);
            if (destIdx <= boardIdx) continue;

            enumerated++;
            final score = _calculateScore(
              walkDistance:
                  originNearby.distance + destNearby.distance + transferWalk,
              transfers: 1,
              transitDistance:
                  transit1 + otherPattern.distanceBetween(boardIdx, destIdx),
            );
            final incumbent = bestByPair[pairKey];
            if (incumbent != null && incumbent.score <= score) {
              if (enumerated >= maxCandidatesEnumerated) break origins;
              continue;
            }

            final boardStop = data.stops[otherPattern.stopIds[boardIdx]];
            final destRoute = data.routes[otherPattern.routeId];
            if (boardStop == null || destRoute == null) continue;

            final seg1 = _buildSegmentForPattern(
              pattern: originPattern,
              fromIdx: originIdx,
              toIdx: alightIdx,
              route: originRoute,
              fromStop: originNearby.stop,
              toStop: alightStop,
            );
            final seg2 = _buildSegmentForPattern(
              pattern: otherPattern,
              fromIdx: boardIdx,
              toIdx: destIdx,
              route: destRoute,
              fromStop: boardStop,
              toStop: destNearby.stop,
            );

            bestByPair[pairKey] = RoutingPath(
              originWalkDistance: originNearby.distance,
              originStop: originNearby.stop,
              segments: [seg1, seg2],
              destinationStop: destNearby.stop,
              destinationWalkDistance: destNearby.distance,
              score: score,
              transferWalkDistance: transferWalk,
            );
            if (enumerated >= maxCandidatesEnumerated) break origins;
          }
        }
      }
    }

    paths.addAll(bestByPair.values);
  }

  /// Find routes with 2..[maxTransfers] transfers — as few as reach the
  /// destination — by a round-based search over the pattern graph (the
  /// idea of RAPTOR, Delling–Pajor–Werneck 2015, without the time axis).
  ///
  /// Nodes are patterns, edges the precomputed connections of the index
  /// (alight at `myStopIdx`, board the other pattern at `otherStopIdx`,
  /// `walkMeters` in between). A *label* is "aboard pattern P from stop
  /// position `entry`, having spent `cost` (walk × reluctance + transit) to
  /// get there with `round` transfers". Round 0 labels board at the origin
  /// stops; round k labels come from scanning the connections **after the
  /// entry** of every label created in round k − 1. From round 2 on, a
  /// labelled pattern that serves a destination stop after its entry is an
  /// itinerary; the first round that yields any ends the search, so every
  /// answer has the minimum number of transfers.
  ///
  /// Each pattern keeps a Pareto front of labels: boarding earlier reaches
  /// more stops, boarding later may be cheaper. Label A (entry a, cost cA)
  /// dominates B (entry b ≥ a, cost cB) when riding A down to b is no
  /// dearer than B — `cA + dist(a, b) <= cB` — in which case B leads to
  /// nothing A cannot reach for less with no more transfers and is not
  /// expanded. This is what keeps the search bounded on a dense feed
  /// (Cochabamba, 657 patterns, 2.6 M connections: well under a hundred
  /// thousand scans for a typical pair, ~3 M in the worst one) while every
  /// chain prefix it expands is the cheapest way to be aboard that pattern
  /// at that position. Extending today's pair loop to triples instead
  /// would scan up to ~200 M connections per query there.
  ///
  /// The hop **into** a pattern that serves a destination stop is not a
  /// label but an itinerary candidate, evaluated on the spot for every
  /// destination stop after the boarding position and kept best-per-chain
  /// (pattern ids) — the multi-transfer counterpart of the one-transfer
  /// phase's best-per-pattern-pair. So two chains that end on the same
  /// last bus through different intermediate lines are both offered, in
  /// score order; only chains that share every pattern collapse. Then
  /// [findRoutes] dedupes by line.
  ///
  /// A chain never boards a line it has already ridden (the index already
  /// forbids that between consecutive legs; here it holds across the whole
  /// chain — "7 → 14 → back onto the same 7" is a detour, not an option).
  /// In the last round only patterns serving a destination stop are worth
  /// a look: nothing else could still become an itinerary.
  ///
  /// The scan budget [maxMultiTransferScans] bounds a pathological query;
  /// when it runs out the search answers with the candidates of the round
  /// in progress. Returns one path per distinct pattern chain.
  List<RoutingPath> _findMultiTransferRoutes(
    List<NearbyStop> originStops,
    List<NearbyStop> destinationStops, {
    required int maxTransfers,
  }) {
    _multiTransferSearches++;

    // Destination stops per pattern, arranged so that "the best stop to
    // alight after position b" is one binary search (see
    // [_DestinationsOnPattern]).
    final destStopsByPattern = <int, List<NearbyStop>>{};
    for (final destNearby in destinationStops) {
      for (final p in routeIndex.getPatternsAtStop(destNearby.stop.id)) {
        destStopsByPattern.putIfAbsent(p.id, () => []).add(destNearby);
      }
    }
    if (destStopsByPattern.isEmpty) return [];
    // Indexed by pattern id: the hot loop reads it once per connection.
    final destinations = List<_DestinationsOnPattern?>.filled(
      routeIndex.patternCount,
      null,
    );
    for (final e in destStopsByPattern.entries) {
      destinations[e.key] = _DestinationsOnPattern(
        routeIndex.patternById(e.key),
        e.value,
        _walkReluctance,
      );
    }

    final patternLine = _patternLine;
    final patternCount = routeIndex.patternCount;
    final fronts = List<_Front?>.filled(patternCount, null);

    // Round 0: aboard every pattern that serves an origin stop.
    var marked = <_TransferLabel>[];
    for (var i = 0; i < originStops.length; i++) {
      final originNearby = originStops[i];
      for (final pattern in routeIndex.getPatternsAtStop(
        originNearby.stop.id,
      )) {
        final entry = pattern.indexOfStop(originNearby.stop.id);
        if (entry < 0) continue;
        final cost = originNearby.distance * _walkReluctance;
        final offset = cost - pattern.distanceBetween(0, entry);
        final front = fronts[pattern.id] ??= _Front();
        if (front.dominates(entry, offset)) continue;
        final label = _TransferLabel(
          pattern: pattern.id,
          entry: entry,
          cost: cost,
          round: 0,
          originStop: i,
          chainKey: pattern.id,
        );
        front.insert(label, entry, offset);
        marked.add(label);
      }
    }

    var scans = 0;
    for (var round = 1; round <= maxTransfers && marked.isNotEmpty; round++) {
      final lastRound = round == maxTransfers;
      // Phases 1 and 2 already answered for 0 and 1 transfers: a hop into
      // a destination pattern counts as an itinerary from round 2 on.
      final checkDestination = round >= 2;
      final next = <_TransferLabel>[];
      final candidates = <int, _ChainCandidate>{};

      // Within a front, a later boarding always has the lower offset cost
      // (else it would be dominated), so the cheapest way to be aboard at
      // alight position `a` is the label with the largest entry below `a`.
      // Each new label therefore only scans the connections between its
      // entry and the next label's: every connection of a pattern is
      // examined once per round, not once per label — around a dense
      // origin a pattern easily carries 20+ non-dominated boardings.
      // Ranges are fixed before the round inserts anything.
      final ranges = <_ExpansionRange>[];
      final snapshots = <int, _FrontSnapshot>{};
      for (final label in marked) {
        // Dominated by a label of its own round: same transfers, dearer.
        // (An earlier-round label dominated by a later one still expands —
        // fewer transfers win outright, whatever the cost.)
        if (label.dominatedInRound == label.round) continue;
        final front = snapshots.putIfAbsent(
          label.pattern,
          () => fronts[label.pattern]!.snapshot(),
        );
        final position = front.labels.indexOf(label);
        if (position < 0) continue;
        ranges.add(
          _ExpansionRange(
            label: label,
            front: front,
            position: position,
            lastAlight: position + 1 < front.labels.length
                ? front.entries[position + 1]
                : 1 << 30,
          ),
        );
      }

      rounds:
      for (final range in ranges) {
        final label = range.label;
        final labelPattern = routeIndex.patternById(label.pattern);
        final conns = routeIndex.getConnectionsFor(label.pattern);
        for (
          var k = conns.firstIndexAfter(label.entry);
          k < conns.length;
          k++
        ) {
          final alightIdx = conns.myStopIdxAt(k);
          if (alightIdx > range.lastAlight) break;
          if (scans++ >= maxMultiTransferScans) break rounds;
          final otherId = conns.otherPatternIdAt(k);
          final destination = checkDestination ? destinations[otherId] : null;
          if (lastRound && destination == null) continue;
          final other = routeIndex.patternById(otherId);
          final boardIdx = conns.otherStopIdxAt(k);
          final walk = conns.walkMetersAt(k);
          var source = label;
          var cost =
              label.cost +
              labelPattern.distanceBetween(label.entry, alightIdx) +
              walk * _walkReluctance;
          var offset = cost - other.distanceBetween(0, boardIdx);
          // Most hops die here (a cheaper boarding of the same pattern is
          // already known), so nothing else is computed before this test.
          final front = fronts[otherId];
          if (destination == null &&
              front != null &&
              front.dominates(boardIdx, offset)) {
            continue;
          }
          // The chain rule can veto the cheapest label; an earlier boarding
          // with a different history may still take this connection.
          final lineId = patternLine[otherId];
          if (_chainRidesLine(label, patternLine, lineId)) {
            final fallback = range.fallbackFor(patternLine, lineId);
            if (fallback == null) continue;
            source = fallback;
            cost =
                source.cost +
                routeIndex
                    .patternById(source.pattern)
                    .distanceBetween(source.entry, alightIdx) +
                walk * _walkReluctance;
            offset = cost - other.distanceBetween(0, boardIdx);
          }
          _TransferLabel? hop;

          if (destination != null) {
            // Cheap score first; the path is only built for the winner of
            // each chain once the round is over.
            final best = destination.bestAfter(boardIdx);
            if (best >= 0) {
              final score =
                  cost +
                  other.distanceBetween(boardIdx, destination.stopIdx[best]) +
                  destination.walkCost[best];
              final chainKey = source.chainKey * patternCount + otherId;
              final incumbent = candidates[chainKey];
              if (incumbent == null || score < incumbent.score) {
                hop = _TransferLabel(
                  pattern: otherId,
                  entry: boardIdx,
                  cost: cost,
                  round: round,
                  prev: source,
                  prevAlight: alightIdx,
                  walk: walk,
                  chainKey: chainKey,
                );
                candidates[chainKey] = _ChainCandidate(
                  hop: hop,
                  destIdx: destination.stopIdx[best],
                  destNearby: destination.nearby[best],
                  score: score,
                );
              }
            }
          }
          if (lastRound) continue;
          final target = front ?? (fronts[otherId] = _Front());
          if (target.dominates(boardIdx, offset)) continue;
          hop ??= _TransferLabel(
            pattern: otherId,
            entry: boardIdx,
            cost: cost,
            round: round,
            prev: source,
            prevAlight: alightIdx,
            walk: walk,
            chainKey: source.chainKey * patternCount + otherId,
          );
          target.insert(hop, boardIdx, offset);
          next.add(hop);
        }
      }
      if (candidates.isNotEmpty) {
        return [
          for (final c in candidates.values)
            ?_buildChainPath(c.hop, c.destIdx, c.destNearby, originStops),
        ];
      }
      marked = next;
    }
    return [];
  }

  /// True when the chain ending in [label] already rides [lineId].
  static bool _chainRidesLine(
    _TransferLabel label,
    Int32List patternLine,
    int lineId,
  ) {
    for (_TransferLabel? l = label; l != null; l = l.prev) {
      if (patternLine[l.pattern] == lineId) return true;
    }
    return false;
  }

  /// Materializes the chain ending in [label], alighting at [destIdx] of its
  /// pattern to walk to [destNearby]. Null when a stop or route referenced
  /// by a pattern is missing from the feed (never on a consistent feed).
  RoutingPath? _buildChainPath(
    _TransferLabel label,
    int destIdx,
    NearbyStop destNearby,
    List<NearbyStop> originStops,
  ) {
    final segments = <RoutingSegment>[];
    var transferWalk = 0.0;
    var transit = 0.0;
    var toIdx = destIdx;
    var toStop = destNearby.stop;
    _TransferLabel l = label;
    while (true) {
      final pattern = routeIndex.patternById(l.pattern);
      final route = data.routes[pattern.routeId];
      final prev = l.prev;
      final fromStop = prev == null
          ? originStops[l.originStop].stop
          : data.stops[pattern.stopIds[l.entry]];
      if (route == null || fromStop == null) return null;
      final segment = _buildSegmentForPattern(
        pattern: pattern,
        fromIdx: l.entry,
        toIdx: toIdx,
        route: route,
        fromStop: fromStop,
        toStop: toStop,
      );
      segments.insert(0, segment);
      transit += segment.transitDistance;
      if (prev == null) {
        final originNearby = originStops[l.originStop];
        return RoutingPath(
          originWalkDistance: originNearby.distance,
          originStop: originNearby.stop,
          segments: segments,
          destinationStop: destNearby.stop,
          destinationWalkDistance: destNearby.distance,
          score: _calculateScore(
            walkDistance:
                originNearby.distance + destNearby.distance + transferWalk,
            transfers: segments.length - 1,
            transitDistance: transit,
          ),
          transferWalkDistance: transferWalk,
        );
      }
      transferWalk += l.walk;
      toIdx = l.prevAlight;
      final alightStop =
          data.stops[routeIndex.patternById(prev.pattern).stopIds[toIdx]];
      if (alightStop == null) return null;
      toStop = alightStop;
      l = prev;
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
      fromIdx: fromIdx,
      toIdx: toIdx,
    );
  }

  /// Resolve full GtfsStop objects and shape polylines for all segments.
  /// Called only on final top-N results for performance.
  RoutingPath _resolvePathStops(RoutingPath path) {
    return RoutingPath(
      originWalkDistance: path.originWalkDistance,
      originStop: path.originStop,
      segments: path.segments.map((seg) {
        // Prefer the indices recorded at build time: re-deriving them from
        // stop IDs picks the FIRST occurrence on the pattern, which breaks
        // segments that board/alight at a repeated stop's later visit (#986 —
        // the transfer leg lost its geometry and rendered as a straight line).
        final fromIdx = seg.fromIdx >= 0
            ? seg.fromIdx
            : seg.pattern.indexOfStop(seg.fromStop.id);
        final toIdx = seg.toIdx >= 0
            ? seg.toIdx
            : seg.pattern.indexOfStop(seg.toStop.id);
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
            fromIdx: fromIdx,
            toIdx: toIdx,
          );
        }
        return seg;
      }).toList(),
      destinationStop: path.destinationStop,
      destinationWalkDistance: path.destinationWalkDistance,
      score: path.score,
      transferWalkDistance: path.transferWalkDistance,
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

  /// How much worse a walked meter is than a ridden one. Without this,
  /// "ride line 1 partway and walk the rest" ties with a direct line that
  /// goes door to door (same total meters), and insertion order decides
  /// the winner — the #859 fixture caught exactly that. 2.0 matches the
  /// industry default (OpenTripPlanner's `walkReluctance`).
  static const double _walkReluctance = 2.0;

  /// Calculate routing score (lower is better).
  ///
  /// Distance-based: `walkDistance * reluctance + transitDistance`
  /// (meters). Time is intentionally ignored — schedule-driven transfer
  /// waits would skew rankings and make "fastest by 1 minute" beat
  /// genuinely shorter trips. The strict-direct-vs-transfer split (see
  /// [findRoutes]) keeps transfers out of results when any direct exists,
  /// so the per-transfer friction term that the old formula carried is no
  /// longer needed here.
  double _calculateScore({
    required double walkDistance,
    required int transfers,
    required double transitDistance,
  }) {
    return walkDistance * _walkReluctance + transitDistance;
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
    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * asin(sqrt(h));
  }
}

/// One state of the multi-transfer search: aboard [pattern] from stop
/// position [entry], having spent [cost] (walked meters × reluctance plus
/// ridden meters) to get there with [round] transfers. Round 0 labels
/// remember which origin stop they boarded at; later ones point at the
/// label they were reached from, the position they alighted it at and the
/// walk in between, so a chain is rebuilt by following [prev].
class _TransferLabel {
  final int pattern;
  final int entry;
  final double cost;
  final int round;
  final _TransferLabel? prev;
  final int prevAlight;
  final double walk;
  final int originStop;

  /// Round of the label that made this one redundant on its pattern, or
  /// `-1`. Only a label of the *same* round stops this one from being
  /// expanded: a dearer label with fewer transfers still expands, because
  /// fewer transfers win outright.
  int dominatedInRound = -1;

  /// The chain's pattern ids packed base `patternCount` (first ridden most
  /// significant): identifies a chain for best-per-chain bookkeeping
  /// without building a string per scanned connection. Exact for chains of
  /// up to six patterns on feeds of up to 4 096 patterns; beyond that a
  /// wrapped key could merge two chains into one candidate (the cheaper
  /// one survives), never corrupt a path.
  final int chainKey;

  _TransferLabel({
    required this.pattern,
    required this.entry,
    required this.cost,
    required this.round,
    this.prev,
    this.prevAlight = -1,
    this.walk = 0,
    this.originStop = -1,
    required this.chainKey,
  });
}

/// The connections one label scans in a round: alight positions after its
/// entry up to (and including) the entry of the next label on the same
/// pattern's front, as the front stood when the round began.
class _ExpansionRange {
  final _TransferLabel label;
  final _FrontSnapshot front;
  final int position;
  final int lastAlight;

  const _ExpansionRange({
    required this.label,
    required this.front,
    required this.position,
    required this.lastAlight,
  });

  /// When this range's own label is vetoed by the chain rule for a
  /// connection into a pattern of [lineId]: the nearest earlier boarding on
  /// the front whose chain did not ride that line, or null when every
  /// eligible label is vetoed.
  _TransferLabel? fallbackFor(Int32List patternLine, int lineId) {
    for (var j = position - 1; j >= 0; j--) {
      final earlier = front.labels[j];
      if (!GtfsRoutingService._chainRidesLine(earlier, patternLine, lineId)) {
        return earlier;
      }
    }
    return null;
  }
}

/// The Pareto front of one pattern (see [_findMultiTransferRoutes]) as
/// parallel typed arrays: entries ascending, offsets — cost minus the
/// cumulative distance at the entry — strictly descending. Dominance is a
/// binary search on the entries plus one offset comparison; it runs once
/// per scanned connection, hundreds of thousands of times per query on a
/// dense feed, so no object is touched until a label actually survives.
class _Front {
  Int32List _entries = Int32List(8);
  Float64List _offsets = Float64List(8);
  List<_TransferLabel?> _labels = List<_TransferLabel?>.filled(8, null);
  int _length = 0;

  /// Position of the first entry strictly after [entry] (`_length` if none).
  int _firstAfter(int entry) {
    var lo = 0;
    var hi = _length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_entries[mid] <= entry) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  /// True when boarding at [entry] with [offset] adds nothing: the last
  /// label boarding at or before it — the cheapest one eligible there —
  /// reaches every later position for no more.
  bool dominates(int entry, double offset) {
    final before = _firstAfter(entry) - 1;
    return before >= 0 && _offsets[before] <= offset;
  }

  /// Inserts a label known not to be dominated (see [dominates]). The
  /// labels it dominates form a contiguous run right after its position
  /// (their offsets are at least its own); they leave the front flagged
  /// with its round.
  void insert(_TransferLabel label, int entry, double offset) {
    final position = _firstAfter(entry - 1);
    var end = position;
    while (end < _length && _offsets[end] >= offset) {
      _labels[end]!.dominatedInRound = label.round;
      end++;
    }
    final tail = _length - end;
    final newLength = position + 1 + tail;
    if (newLength > _entries.length) _grow(newLength);
    if (tail > 0) {
      _entries.setRange(position + 1, position + 1 + tail, _entries, end);
      _offsets.setRange(position + 1, position + 1 + tail, _offsets, end);
      _labels.setRange(position + 1, position + 1 + tail, _labels, end);
    }
    _entries[position] = entry;
    _offsets[position] = offset;
    _labels[position] = label;
    _length = newLength;
  }

  void _grow(int atLeast) {
    var capacity = _entries.length * 2;
    while (capacity < atLeast) {
      capacity *= 2;
    }
    _entries = Int32List(capacity)..setRange(0, _length, _entries);
    _offsets = Float64List(capacity)..setRange(0, _length, _offsets);
    _labels = List<_TransferLabel?>.filled(capacity, null)
      ..setRange(0, _length, _labels);
  }

  /// The front as it stands, for the expansion ranges of a round.
  _FrontSnapshot snapshot() => _FrontSnapshot(_entries.sublist(0, _length), [
    for (var i = 0; i < _length; i++) _labels[i]!,
  ]);
}

/// A [_Front] frozen at the start of a round.
class _FrontSnapshot {
  final Int32List entries;
  final List<_TransferLabel> labels;

  const _FrontSnapshot(this.entries, this.labels);
}

/// The destination stops one pattern serves, arranged for the question the
/// search asks on every connection into it: "boarding at position b, which
/// stop after b gives the cheapest itinerary?" The answer minimizes
/// `cumDist[stop] + walk × reluctance` over stops after b — independent of
/// b except for the filter — so a suffix minimum over the stops sorted by
/// position answers it with one binary search.
class _DestinationsOnPattern {
  /// Stop positions on the pattern, ascending.
  final Int32List stopIdx;

  /// The destination stop at each position.
  final List<NearbyStop> nearby;

  /// `nearby[i].distance × reluctance`.
  final Float64List walkCost;

  /// For each position i, the index j ≥ i minimizing
  /// `cumDist[stopIdx[j]] + walkCost[j]`.
  final Int32List _bestFrom;

  factory _DestinationsOnPattern(
    RoutePattern pattern,
    List<NearbyStop> stops,
    double walkReluctance,
  ) {
    final entries = <(int, NearbyStop)>[
      for (final s in stops)
        if (pattern.indexOfStop(s.stop.id) >= 0)
          (pattern.indexOfStop(s.stop.id), s),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    final n = entries.length;
    final stopIdx = Int32List(n);
    final nearby = <NearbyStop>[];
    final walkCost = Float64List(n);
    for (var i = 0; i < n; i++) {
      stopIdx[i] = entries[i].$1;
      nearby.add(entries[i].$2);
      walkCost[i] = entries[i].$2.distance * walkReluctance;
    }
    final bestFrom = Int32List(n);
    for (var i = n - 1; i >= 0; i--) {
      bestFrom[i] = i;
      if (i + 1 < n) {
        final j = bestFrom[i + 1];
        final here = pattern.distanceBetween(0, stopIdx[i]) + walkCost[i];
        final there = pattern.distanceBetween(0, stopIdx[j]) + walkCost[j];
        if (there < here) bestFrom[i] = j;
      }
    }
    return _DestinationsOnPattern._(stopIdx, nearby, walkCost, bestFrom);
  }

  const _DestinationsOnPattern._(
    this.stopIdx,
    this.nearby,
    this.walkCost,
    this._bestFrom,
  );

  /// Index (into [stopIdx] / [nearby]) of the cheapest destination stop
  /// strictly after [boardIdx], or `-1` when none is.
  int bestAfter(int boardIdx) {
    var lo = 0;
    var hi = stopIdx.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (stopIdx[mid] <= boardIdx) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo < stopIdx.length ? _bestFrom[lo] : -1;
  }
}

/// A destination reached in the round in progress: the hop into the last
/// pattern, where to alight it and the cheap score the round ranks by.
class _ChainCandidate {
  final _TransferLabel hop;
  final int destIdx;
  final NearbyStop destNearby;
  final double score;

  const _ChainCandidate({
    required this.hop,
    required this.destIdx,
    required this.destNearby,
    required this.score,
  });
}
