import 'dart:ui' show Color;

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsRouteType;

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
/// UI falls back to the theme instead of painting a wrong color.
Color? parseGtfsColorHex(String? hex) {
  if (hex == null) return null;
  final clean = hex.trim().replaceFirst('#', '');
  if (clean.length != 6) return null;
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}

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

  /// Sorted by [NearbyLine.distanceMeters] ascending.
  final List<NearbyLine> lines;

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
