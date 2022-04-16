import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';

class PatternOtp extends Equatable {
  final String id;
  final String name;
  final String code;
  final RouteEntity? route;
  final List<LatLng>? geometry;
  final List<Stop>? stops;

  const PatternOtp({
    required this.id,
    required this.name,
    required this.code,
    this.route,
    this.geometry,
    this.stops,
  });

  PatternOtp copyWith({
    String? id,
    String? name,
    String? code,
    RouteEntity? route,
    List<LatLng>? geometry,
    List<Stop>? stops,
  }) {
    return PatternOtp(
      id: id ?? this.id,
      route: route ?? this.route,
      name: name ?? this.name,
      code: code ?? this.code,
      geometry: geometry ?? this.geometry,
      stops: stops ?? this.stops,
    );
  }

  factory PatternOtp.fromJson(Map<String, dynamic> json) => PatternOtp(
        id: json['id'].toString(),
        route: json['route'] != null
            ? RouteEntity.fromJson(json['route'] as Map<String, dynamic>)
            : null,
        name: json['name'].toString(),
        code: json['code'].toString(),
        geometry: json['geometry'] != null
            ? List<LatLng>.from((json["geometry"] as List<dynamic>).map(
                (x) => LatLng(x['lat'] as double, x['lon'] as double),
              ))
            : null,
        stops: json['stops'] != null
            ? List<Stop>.from((json["stops"] as List<dynamic>).map(
                (x) => Stop.fromJson(x as Map<String, dynamic>),
              ))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'route': route?.toJson(),
        'name': name,
        'code': code,
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
  List<Object?> get props => [
        id,
        name,
        code,
        route,
        geometry,
        stops,
      ];
}

class RouteEntity extends Equatable {
  final String? shortName;
  final String? longName;
  final TransportMode? mode;
  final String? color;

  const RouteEntity({
    this.shortName,
    this.longName,
    this.mode,
    this.color,
  });

  factory RouteEntity.fromJson(Map<String, dynamic> json) => RouteEntity(
        shortName: json['shortName'] as String?,
        longName: json['longName'] as String?,
        mode: getTransportMode(
            mode: json['mode'].toString(),
            specificTransport: (json['longName'] ?? '') as String),
        color: json['color'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'shortName': shortName,
        'longName': longName,
        'mode': mode?.name,
        'color': color,
      };

  Color get primaryColor {
    return color != null
        ? Color(int.tryParse('0xFF$color')!)
        : mode?.color ?? Colors.black;
  }

  Color get backgroundColor {
    return color != null
        ? Color(int.tryParse('0xFF$color')!)
        : mode?.backgroundColor ?? Colors.black;
  }

  @override
  List<Object?> get props => [
        shortName,
        longName,
        mode,
        color,
      ];
}

class Stop extends Equatable {
  final String name;
  final double lat;
  final double lon;

  const Stop({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        name: json['name'] as String,
        lat: double.tryParse(json['lat'].toString()) ?? 0,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lon': lon,
      };

  @override
  List<Object?> get props => [
        name,
        lat,
        lon,
      ];
}
