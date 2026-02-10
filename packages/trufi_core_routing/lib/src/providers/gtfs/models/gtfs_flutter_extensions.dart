import 'package:flutter/material.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// Flutter-specific extensions for GTFS models from trufi_core_planner.
/// Adds Color, IconData, and other UI-related functionality.

/// Extension for GtfsRoute to add Flutter UI properties.
extension GtfsRouteFlutter on GtfsRoute {
  /// Get route color as Flutter Color.
  Color? get flutterColor {
    if (colorHex == null || colorHex!.isEmpty) return null;
    return Color(int.parse('FF${colorHex!}', radix: 16));
  }

  /// Get text color as Flutter Color.
  Color? get flutterTextColor {
    if (textColorHex == null || textColorHex!.isEmpty) return null;
    return Color(int.parse('FF${textColorHex!}', radix: 16));
  }

  /// Get icon for this route type.
  IconData get icon {
    switch (type) {
      case GtfsRouteType.tram:
        return Icons.tram;
      case GtfsRouteType.subway:
        return Icons.subway;
      case GtfsRouteType.rail:
        return Icons.train;
      case GtfsRouteType.bus:
        return Icons.directions_bus;
      case GtfsRouteType.ferry:
        return Icons.directions_boat;
      case GtfsRouteType.cableTram:
        return Icons.tram;
      case GtfsRouteType.aerialLift:
        return Icons.airline_seat_recline_extra;
      case GtfsRouteType.funicular:
        return Icons.train;
      case GtfsRouteType.trolleybus:
        return Icons.directions_bus;
      case GtfsRouteType.monorail:
        return Icons.train;
    }
  }
}

/// Extension for GtfsRouteType to get icon.
extension GtfsRouteTypeFlutter on GtfsRouteType {
  /// Icon for this route type.
  IconData get iconData {
    switch (this) {
      case GtfsRouteType.tram:
        return Icons.tram;
      case GtfsRouteType.subway:
        return Icons.subway;
      case GtfsRouteType.rail:
        return Icons.train;
      case GtfsRouteType.bus:
        return Icons.directions_bus;
      case GtfsRouteType.ferry:
        return Icons.directions_boat;
      case GtfsRouteType.cableTram:
        return Icons.tram;
      case GtfsRouteType.aerialLift:
        return Icons.airline_seat_recline_extra;
      case GtfsRouteType.funicular:
        return Icons.train;
      case GtfsRouteType.trolleybus:
        return Icons.directions_bus;
      case GtfsRouteType.monorail:
        return Icons.train;
    }
  }
}
