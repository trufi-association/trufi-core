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

  String get longNameStart => _longNameWithoutPrefix.split(" → ").first;

  String get longNameLast => _longNameWithoutPrefix.split(" → ").last;

  String get longNameFull => longName ?? '';

  bool get hasOriginDestination => _longNameWithoutPrefix.contains(" → ");
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
