import 'package:flutter/material.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsRouteType;
import 'package:trufi_core_routing/trufi_core_routing.dart' show ServiceHours;

export 'package:trufi_core_routing/trufi_core_routing.dart' show ServiceHours;

/// The mode glyph of a GTFS `route_type`: one map for the routes list, the
/// route detail and the nearby-lines screen, so a line wears the same icon
/// wherever it is shown. Unknown or missing types get the generic transit
/// glyph.
IconData gtfsRouteTypeIcon(GtfsRouteType? type) {
  switch (type) {
    case GtfsRouteType.bus:
      return Icons.directions_bus;
    case GtfsRouteType.tram:
      return Icons.tram;
    case GtfsRouteType.subway:
      return Icons.subway;
    case GtfsRouteType.rail:
      return Icons.train;
    case GtfsRouteType.ferry:
      return Icons.directions_ferry;
    case GtfsRouteType.cableTram:
    case GtfsRouteType.aerialLift:
      return Icons.airline_seat_recline_extra;
    case GtfsRouteType.funicular:
      return Icons.terrain;
    default:
      return Icons.directions_transit;
  }
}

/// Represents a transport route for display in the list
class TransportRoute {
  final String id;
  final String code;
  final String name;
  final String? shortName;
  final String? longName;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? modeIcon;
  final String? agencyName;
  final String? headsign;
  final String? description;
  final int? directionId;
  final ServiceHours? serviceHours;

  const TransportRoute({
    required this.id,
    required this.code,
    required this.name,
    this.shortName,
    this.longName,
    this.backgroundColor,
    this.textColor,
    this.modeIcon,
    this.agencyName,
    this.headsign,
    this.description,
    this.directionId,
    this.serviceHours,
  });

  String get displayName => shortName ?? name;

  /// Gets the route name prefix (e.g., "MiniBus 1" from "MiniBus 1: Origen → Destino")
  String get longNamePrefix {
    if (longName == null) return '';
    final colonIndex = longName!.indexOf(': ');
    if (colonIndex != -1) {
      return longName!.substring(0, colonIndex);
    }
    return '';
  }

  /// Gets the route description without the route name prefix (e.g., "MiniBus 1:")
  String get _longNameWithoutPrefix {
    if (longName == null) return '';
    // Remove prefix like "MiniBus 1: " if present
    final colonIndex = longName!.indexOf(': ');
    if (colonIndex != -1) {
      return longName!.substring(colonIndex + 2);
    }
    return longName!;
  }

  /// The origin half of a `route_long_name` written as `from <arrow> to`.
  ///
  /// Feeds write the arrow in several ways: "→" (trufi-gtfs-builder), "⟵"
  /// (Sana'a, whose names are Arabic and read right to left), "←", "->",
  /// "<-" or "⟶". Several arrows of one direction mark vias: "A → B → C"
  /// goes from A to C, as the old `" → "` split read it; mixed directions
  /// ("A → B ← C") give no terminals. A spaced dash is a separator too
  /// ("Callao – La Victoria" in Lima, "Retiro - Constitución" in Buenos
  /// Aires), but only when the name has no arrow and the dash is the only
  /// one; so a name such as "Av. Blanco Galindo - Km 5" is also read as
  /// terminals: a risk accepted for now, no feed carries such a name.
  ///
  /// Order: arrows are not bidi-mirrored, so the rule depends on the script.
  /// In a left-to-right name a left-pointing arrow ("B ← A") reads from A
  /// to B and the halves swap. In a right-to-left name the written order is
  /// kept whatever the arrow: the first written half is the origin, which
  /// is how Sana'a's "⟵" names are mapped and how trufi-gtfs-builder reads
  /// them (the text after the arrow is the destination).
  String get longNameStart => _longNameHalves?.$1 ?? _longNameWithoutPrefix;

  String get longNameLast => _longNameHalves?.$2 ?? _longNameWithoutPrefix;

  String get longNameFull => longName ?? '';

  bool get hasOriginDestination => _longNameHalves != null;

  /// `(from, to)` when the name carries a separator with text on both
  /// sides; null otherwise (a bare name, an empty half, arrows of mixed
  /// directions, several dashes and no arrow).
  (String, String)? get _longNameHalves {
    final name = _longNameWithoutPrefix;
    final all = _longNameSeparator.allMatches(name).toList();
    if (all.isEmpty) return null;
    // A real arrow wins over a dash inside a half ("Zona Sud - Ticti →
    // Centro"); dashes alone are a separator only when there is one.
    final arrows = all.where((m) => !_dashes.contains(m.group(1))).toList();
    if (arrows.isEmpty && all.length != 1) return null;
    final matches = arrows.isEmpty ? all : arrows;
    // Several arrows of one direction are vias: the terminals are the text
    // before the first and after the last. Mixed directions say nothing.
    final pointsLeft = _leftArrows.contains(matches.first.group(1));
    for (final m in matches) {
      if (_leftArrows.contains(m.group(1)) != pointsLeft) return null;
    }
    final first = name.substring(0, matches.first.start).trim();
    final last = name.substring(matches.last.end).trim();
    if (first.isEmpty || last.isEmpty) return null;
    // A left arrow in LTR text is "to ← from"; RTL text keeps the written
    // order whatever the arrow (see longNameStart).
    final rtl = _rtlScript.hasMatch(name);
    return pointsLeft && !rtl ? (last, first) : (first, last);
  }

  static final RegExp _longNameSeparator = RegExp(
    r'\s+(→|⟶|⟵|←|->|<-|–|—|-)\s+',
  );
  static const Set<String> _leftArrows = {'⟵', '←', '<-'};
  static const Set<String> _dashes = {'–', '—', '-'};
  static final RegExp _rtlScript = RegExp(
    r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]',
  );
}

/// Represents a stop on a transport route
class TransportStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const TransportStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

/// Extended route details including geometry and stops
class TransportRouteDetails extends TransportRoute {
  final List<({double latitude, double longitude})>? geometry;
  final List<TransportStop>? stops;
  final String? modeName;

  const TransportRouteDetails({
    required super.id,
    required super.code,
    required super.name,
    super.shortName,
    super.longName,
    super.backgroundColor,
    super.textColor,
    super.modeIcon,
    super.agencyName,
    super.headsign,
    super.description,
    super.directionId,
    super.serviceHours,
    this.geometry,
    this.stops,
    this.modeName,
  });
}
