import 'package:equatable/equatable.dart';
import 'package:trufi_core/base/models/transit_route/transit_info.dart';
import 'package:trufi_core/base/models/transit_route/stops.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

import 'route_report_history.dart';

class TransitRoute extends Equatable {
  final String id;
  final String name;
  final String code;
  final TransitInfo? route;
  final List<TrufiLatLng>? geometry;
  final List<Stop>? stops;
  final RouteReportHistory? reportHistory;

  const TransitRoute({
    required this.id,
    required this.name,
    required this.code,
    this.route,
    this.geometry,
    this.stops,
    this.reportHistory,
  });

  TransitRoute copyWith({
    String? id,
    String? name,
    String? code,
    TransitInfo? route,
    List<TrufiLatLng>? geometry,
    List<Stop>? stops,
    RouteReportHistory? reportHistory,
  }) {
    return TransitRoute(
      id: id ?? this.id,
      route: route ?? this.route,
      name: name ?? this.name,
      code: code ?? this.code,
      geometry: geometry ?? this.geometry,
      stops: stops ?? this.stops,
      reportHistory: reportHistory ?? this.reportHistory,
    );
  }

  factory TransitRoute.fromJson(Map<String, dynamic> json) => TransitRoute(
        id: json['id'].toString(),
        route: json['route'] != null
            ? TransitInfo.fromJson(json['route'] as Map<String, dynamic>)
            : null,
        name: json['name'].toString(),
        code: json['code'].toString(),
        geometry: json['geometry'] != null
            ? List<TrufiLatLng>.from((json["geometry"] as List<dynamic>).map(
                (x) => TrufiLatLng(x['lat'] as double, x['lon'] as double),
              ))
            : null,
        stops: json['stops'] != null
            ? List<Stop>.from((json["stops"] as List<dynamic>).map(
                (x) => Stop.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        reportHistory: json['reportHistory'] != null
            ? RouteReportHistory.fromJson(
                json['reportHistory'] as Map<String, dynamic>)
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
        'reportHistory': reportHistory?.toJson(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        route,
        // geometry,
        // stops,
        reportHistory,
      ];
}
