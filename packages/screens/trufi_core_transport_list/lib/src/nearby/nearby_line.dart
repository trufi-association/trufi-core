import 'dart:ui' show Color;

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsRouteType;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart'
    show parseGtfsColor;

import 'nearby_radius.dart';

/// How a line was matched to the search anchor.
enum NearbyMatchKind {
  /// The walk ends at one of the line's stops ([NearbyLine.stopName]).
  stop,

  /// The route geometry runs clearly closer than any of its stops — the
  /// rider can flag the vehicle down there (informal stop-anywhere systems).
  passes,
}

/// Parses a GTFS `route_color` / `route_text_color` (`RRGGBB`, with or
/// without `#`) into an opaque [Color]; null when absent or malformed so the
/// UI falls back to the theme instead of painting a wrong color. The rule
/// itself is the ecosystem's [parseGtfsColor]; this name stays for the
/// service and its tests.
Color? parseGtfsColorHex(String? hex) => parseGtfsColor(hex);

/// One row of the nearby-lines result: a logical line and the closest place
/// where the rider can reach it.
class NearbyLine extends Equatable {
  const NearbyLine({
    required this.lineKey,
    required this.routeId,
    required this.patternId,
    this.shapeId,
    this.tripId,
    required this.shortName,
    required this.longName,
    this.headsign,
    this.color,
    this.textColor,
    required this.routeType,
    required this.distanceMeters,
    required this.kind,
    this.stopId,
    this.stopName,
    required this.nearestPoint,
    this.agencyName,
  });

  /// `GtfsRouteIndex.lineKeyForRoute(routeId)`: routes sharing a key are one
  /// logical line (outbound/inbound split), so the result has one row per key.
  final String lineKey;

  final String routeId;

  /// Pattern that produced [distanceMeters]; [headsign] and the geometry
  /// come from it.
  final int patternId;
  final String? shapeId;

  /// First trip of the pattern, for list providers that key route details by
  /// trip id (`GtfsTransportDataProvider`). Null when the feed has none.
  final String? tripId;

  final String shortName;
  final String longName;
  final String? headsign;
  final Color? color;
  final Color? textColor;
  final GtfsRouteType routeType;

  /// Walk to the stop ([NearbyMatchKind.stop]) or to the closest point of
  /// the route geometry ([NearbyMatchKind.passes]).
  final double distanceMeters;
  final NearbyMatchKind kind;

  /// Set only for [NearbyMatchKind.stop].
  final String? stopId;
  final String? stopName;

  /// The stop position or the closest point on the shape — where the map
  /// marker and its distance label go.
  final LatLng nearestPoint;

  final String? agencyName;

  String get displayName => shortName.isNotEmpty ? shortName : longName;

  /// The id `TrufiPlannerProvider` resolves in local mode
  /// (`routeId#patternId`); a trip id would not be found there.
  String get detailCode => '$routeId#$patternId';

  bool isWithin(NearbyRadius radius) => radius.contains(distanceMeters);

  /// The order of a result: nearest first, then numeric names in numeric
  /// order ("2" before "10") ahead of the rest alphabetically — the order
  /// of the routes list — then the route id, so the order is total.
  static int compare(NearbyLine a, NearbyLine b) {
    final byDistance = a.distanceMeters.compareTo(b.distanceMeters);
    if (byDistance != 0) return byDistance;
    final byName = _compareRouteNames(a.shortName, b.shortName);
    if (byName != 0) return byName;
    return a.routeId.compareTo(b.routeId);
  }

  static int _compareRouteNames(String a, String b) {
    final numA = int.tryParse(a);
    final numB = int.tryParse(b);
    if (numA != null && numB != null) return numA.compareTo(numB);
    if (numA != null) return -1;
    if (numB != null) return 1;
    return a.compareTo(b);
  }

  @override
  List<Object?> get props => [
    lineKey,
    routeId,
    patternId,
    shapeId,
    tripId,
    shortName,
    longName,
    headsign,
    color,
    textColor,
    routeType,
    distanceMeters,
    kind,
    stopId,
    stopName,
    nearestPoint,
    agencyName,
  ];
}

/// Every line within [maxRadiusMeters] of [anchor], nearest first.
class NearbyLinesResult extends Equatable {
  const NearbyLinesResult({
    required this.anchor,
    required this.maxRadiusMeters,
    required this.lines,
  });

  final LatLng anchor;
  final double maxRadiusMeters;

  /// Sorted by [NearbyLine.distanceMeters] ascending ([NearbyLine.compare]).
  final List<NearbyLine> lines;

  /// One row per line across [results], as a single query from [anchor]
  /// would list them: a line matched at several anchors keeps its nearest
  /// match ([NearbyLine.compare] decides ties), nearest first. This is the
  /// "lines along a street" result — [results] being the nearby lines of
  /// each of its corners (trufi-sanaa#20).
  factory NearbyLinesResult.union(
    Iterable<NearbyLinesResult> results, {
    required LatLng anchor,
    double maxRadiusMeters = NearbyRadius.maxMeters,
  }) {
    final nearest = <String, NearbyLine>{};
    for (final result in results) {
      for (final line in result.lines) {
        final current = nearest[line.lineKey];
        if (current == null || NearbyLine.compare(line, current) < 0) {
          nearest[line.lineKey] = line;
        }
      }
    }
    return NearbyLinesResult(
      anchor: anchor,
      maxRadiusMeters: maxRadiusMeters,
      lines: List.unmodifiable(
        nearest.values.toList()..sort(NearbyLine.compare),
      ),
    );
  }

  /// Sentinel radius of [empty]: no query was run.
  static const double noMaxRadius = 0;

  static final NearbyLinesResult empty = NearbyLinesResult(
    anchor: const LatLng(0, 0),
    maxRadiusMeters: noMaxRadius,
    lines: const [],
  );

  List<NearbyLine> within(NearbyRadius radius) =>
      lines.where((line) => line.isWithin(radius)).toList(growable: false);

  /// Cumulative counts for the radius chips: a line 80 m away is counted in
  /// every bracket, so `m500` is always the total.
  Map<NearbyRadius, int> get bracketCounts => {
    for (final radius in NearbyRadius.values)
      radius: lines.where((line) => line.isWithin(radius)).length,
  };

  @override
  List<Object?> get props => [anchor, maxRadiusMeters, lines];
}

/// A stop of a nearby line's pattern, for the detail screen and the map.
class NearbyLineStop extends Equatable {
  const NearbyLineStop({
    required this.id,
    required this.name,
    required this.position,
  });

  final String id;
  final String name;
  final LatLng position;

  @override
  List<Object?> get props => [id, name, position];
}

/// Full geometry of a nearby line: what the highlight draws and what the
/// detail screen renders.
class NearbyLineGeometry extends Equatable {
  const NearbyLineGeometry({required this.polyline, required this.stops});

  /// The GTFS shape, or the stop sequence when the feed ships no shapes.
  final List<LatLng> polyline;
  final List<NearbyLineStop> stops;

  @override
  List<Object?> get props => [polyline, stops];
}
