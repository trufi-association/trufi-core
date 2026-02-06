import 'package:flutter/material.dart';

/// GTFS Route entity.
/// Represents a transit route from routes.txt
class GtfsRoute {
  final String id;
  final String? agencyId;
  final String shortName;
  final String longName;
  final String? description;
  final GtfsRouteType type;
  final String? url;
  final Color? color;
  final Color? textColor;
  final int? sortOrder;

  const GtfsRoute({
    required this.id,
    this.agencyId,
    required this.shortName,
    required this.longName,
    this.description,
    required this.type,
    this.url,
    this.color,
    this.textColor,
    this.sortOrder,
  });

  /// Display name (prefers short name, falls back to long name)
  String get displayName => shortName.isNotEmpty ? shortName : longName;

  factory GtfsRoute.fromCsv(Map<String, String> row) {
    return GtfsRoute(
      id: row['route_id'] ?? '',
      agencyId: row['agency_id'],
      shortName: row['route_short_name'] ?? '',
      longName: row['route_long_name'] ?? '',
      description: row['route_desc'],
      type: GtfsRouteType.fromValue(
        int.tryParse(row['route_type'] ?? '') ?? 3,
      ),
      url: row['route_url'],
      color: _parseColor(row['route_color']),
      textColor: _parseColor(row['route_text_color']),
      sortOrder: int.tryParse(row['route_sort_order'] ?? ''),
    );
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return null;
  }
}

/// GTFS route types.
enum GtfsRouteType {
  tram(0),
  subway(1),
  rail(2),
  bus(3),
  ferry(4),
  cableTram(5),
  aerialLift(6),
  funicular(7),
  trolleybus(11),
  monorail(12);

  final int value;
  const GtfsRouteType(this.value);

  static GtfsRouteType fromValue(int value) {
    return GtfsRouteType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsRouteType.bus,
    );
  }

  /// Icon for this route type.
  IconData get icon {
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

  /// Human-readable name for this route type.
  String get displayName {
    switch (this) {
      case GtfsRouteType.tram:
        return 'Tram';
      case GtfsRouteType.subway:
        return 'Subway';
      case GtfsRouteType.rail:
        return 'Rail';
      case GtfsRouteType.bus:
        return 'Bus';
      case GtfsRouteType.ferry:
        return 'Ferry';
      case GtfsRouteType.cableTram:
        return 'Cable Tram';
      case GtfsRouteType.aerialLift:
        return 'Aerial Lift';
      case GtfsRouteType.funicular:
        return 'Funicular';
      case GtfsRouteType.trolleybus:
        return 'Trolleybus';
      case GtfsRouteType.monorail:
        return 'Monorail';
    }
  }
}
