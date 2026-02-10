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
  final String? colorHex;  // Hex color without '#'
  final String? textColorHex;
  final int? sortOrder;

  const GtfsRoute({
    required this.id,
    this.agencyId,
    required this.shortName,
    required this.longName,
    this.description,
    required this.type,
    this.url,
    this.colorHex,
    this.textColorHex,
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
      colorHex: _parseColorHex(row['route_color']),
      textColorHex: _parseColorHex(row['route_text_color']),
      sortOrder: int.tryParse(row['route_sort_order'] ?? ''),
    );
  }

  static String? _parseColorHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    return hex.replaceFirst('#', '');
  }

  factory GtfsRoute.fromJson(Map<String, dynamic> json) {
    return GtfsRoute(
      id: json['id'] as String,
      agencyId: json['agencyId'] as String?,
      shortName: json['shortName'] as String? ?? '',
      longName: json['longName'] as String? ?? '',
      description: json['description'] as String?,
      type: GtfsRouteType.fromValue(
        int.tryParse(json['type']?.toString() ?? '') ?? 3,
      ),
      url: json['url'] as String?,
      colorHex: json['color'] as String?,
      textColorHex: json['textColor'] as String?,
      sortOrder: json['sortOrder'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'agencyId': agencyId,
        'shortName': shortName,
        'longName': longName,
        'description': description,
        'type': type.value.toString(),
        'url': url,
        'color': colorHex,
        'textColor': textColorHex,
        'sortOrder': sortOrder,
      };
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
