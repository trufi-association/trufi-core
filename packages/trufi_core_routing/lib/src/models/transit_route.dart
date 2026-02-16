import 'package:latlong2/latlong.dart';

import 'stop.dart';
import 'transport_mode.dart';

/// Represents a transit route pattern from OTP.
///
/// This contains the basic route information returned by OTP's
/// patterns query, including the route details, geometry and stops.
class TransitRoute {
  final String id;
  final String name;
  final String code;
  final TransitRouteInfo? route;
  final List<LatLng>? geometry;
  final List<Stop>? stops;

  const TransitRoute({
    required this.id,
    required this.name,
    required this.code,
    this.route,
    this.geometry,
    this.stops,
  });

  TransitRoute copyWith({
    String? id,
    String? name,
    String? code,
    TransitRouteInfo? route,
    List<LatLng>? geometry,
    List<Stop>? stops,
  }) {
    return TransitRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      route: route ?? this.route,
      geometry: geometry ?? this.geometry,
      stops: stops ?? this.stops,
    );
  }

  factory TransitRoute.fromJson(Map<String, dynamic> json) => TransitRoute(
        id: json['id'].toString(),
        name: json['name'].toString(),
        code: json['code'].toString(),
        route: json['route'] != null
            ? TransitRouteInfo.fromJson(json['route'] as Map<String, dynamic>)
            : null,
        geometry: json['geometry'] != null
            ? List<LatLng>.from((json['geometry'] as List<dynamic>).map(
                (x) => LatLng(x['lat'] as double, x['lon'] as double),
              ))
            : null,
        stops: json['stops'] != null
            ? List<Stop>.from((json['stops'] as List<dynamic>).map(
                (x) => Stop.fromJson(x as Map<String, dynamic>),
              ))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'route': route?.toJson(),
        'geometry': geometry != null
            ? List<dynamic>.from(geometry!.map((x) => {
                  'lat': x.latitude,
                  'lon': x.longitude,
                }))
            : null,
        'stops': stops != null
            ? List<dynamic>.from(stops!.map((x) => x.toJson()))
            : null,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransitRoute &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          code == other.code;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ code.hashCode;
}

/// Route information from OTP (shortName, longName, color, mode).
class TransitRouteInfo {
  final String? shortName;
  final String? longName;
  final TransportMode? mode;
  final String? color;
  final String? textColor;

  const TransitRouteInfo({
    this.shortName,
    this.longName,
    this.mode,
    this.color,
    this.textColor,
  });

  factory TransitRouteInfo.fromJson(Map<String, dynamic> json) =>
      TransitRouteInfo(
        shortName: json['shortName'] as String?,
        longName: json['longName'] as String?,
        mode: TransportModeExtension.fromString(json['mode']?.toString()),
        color: json['color'] as String?,
        textColor: json['textColor'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'shortName': shortName,
        'longName': longName,
        'mode': mode?.name,
        'color': color,
        'textColor': textColor,
      };

  /// Returns the last part of longName after "→ "
  String get longNameLast {
    return longName?.split('→ ').last ?? '';
  }

  /// Returns the first part of longName after ": " and before "→ "
  String get longNameStart {
    return longName?.split(': ').last.split('→ ').first ?? '';
  }

  /// Returns the part of longName after ": "
  String get longNameSub {
    return longName?.split(': ').last ?? '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransitRouteInfo &&
          runtimeType == other.runtimeType &&
          shortName == other.shortName &&
          longName == other.longName &&
          mode == other.mode &&
          color == other.color &&
          textColor == other.textColor;

  @override
  int get hashCode =>
      shortName.hashCode ^
      longName.hashCode ^
      mode.hashCode ^
      color.hashCode ^
      textColor.hashCode;
}
