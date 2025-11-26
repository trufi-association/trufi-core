import 'package:trufi_core/models/plan_entity.dart';

import 'alert.dart';
import 'coordinates.dart';
import 'geometry.dart';
import 'trip.dart';

class PatternOtpEntity {
  final String? id;
  final RouteEntity? route;
  final int? directionId;
  final String? name;
  final String? code;
  final String? headsign;
  final List<TripEntity>? trips;
  final List<TripEntity>? tripsForDate;
  final List<StopEntity>? stops;
  final List<CoordinatesEntity>? geometry;
  final GeometryEntity? patternGeometry;
  final String? semanticHash;
  final List<AlertEntity>? alerts;

  const PatternOtpEntity({
    this.id,
    this.route,
    this.directionId,
    this.name,
    this.code,
    this.headsign,
    this.trips,
    this.tripsForDate,
    this.stops,
    this.geometry,
    this.patternGeometry,
    this.semanticHash,
    this.alerts,
  });

  static const String _id = 'id';
  static const String _route = 'route';
  static const String _directionId = 'directionId';
  static const String _name = 'name';
  static const String _code = 'code';
  static const String _headsign = 'headsign';
  static const String _trips = 'trips';
  static const String _tripsForDate = 'tripsForDate';
  static const String _stops = 'stops';
  static const String _geometry = 'geometry';
  static const String _patternGeometry = 'patternGeometry';
  static const String _semanticHash = 'semanticHash';
  static const String _alerts = 'alerts';

  factory PatternOtpEntity.fromJson(Map<String, dynamic> json) => PatternOtpEntity(
    id: json[_id],
    route:
        json[_route] != null
            ? RouteEntity.fromJson(json[_route] as Map<String, dynamic>)
            : null,
    directionId: json[_directionId],
    name: json[_name],
    code: json[_code],
    headsign: json[_headsign],
    trips:
        json[_trips] != null
            ? List<TripEntity>.from(
              (json[_trips] as List<dynamic>).map(
                (x) => TripEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    tripsForDate:
        json[_tripsForDate] != null
            ? List<TripEntity>.from(
              (json[_tripsForDate] as List<dynamic>).map(
                (x) => TripEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    stops:
        json[_stops] != null
            ? List<StopEntity>.from(
              (json[_stops] as List<dynamic>).map(
                (x) => StopEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    geometry:
        json[_geometry] != null
            ? List<CoordinatesEntity>.from(
              (json[_geometry] as List<dynamic>).map(
                (x) => CoordinatesEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    patternGeometry:
        json[_patternGeometry] != null
            ? GeometryEntity.fromJson(json[_patternGeometry] as Map<String, dynamic>)
            : null,
    semanticHash: json[_semanticHash],
    alerts:
        json[_alerts] != null
            ? List<AlertEntity>.from(
              (json[_alerts] as List<dynamic>).map(
                (x) => AlertEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
  );

  Map<String, dynamic> toJson() => {
    _id: id,
    _route: route?.toJson(),
    _directionId: directionId,
    _name: name,
    _code: code,
    _headsign: headsign,
    _trips:
        trips != null
            ? List<dynamic>.from(trips!.map((x) => x.toJson()))
            : null,
    _tripsForDate:
        tripsForDate != null
            ? List<dynamic>.from(tripsForDate!.map((x) => x.toJson()))
            : null,
    _stops:
        stops != null ? List<dynamic>.from(stops!.map((x) => x.toJson())) : null,
    _geometry:
        geometry != null
            ? List<dynamic>.from(geometry!.map((x) => x.toJson()))
            : null,
    _patternGeometry: patternGeometry?.toJson(),
    _semanticHash: semanticHash,
    _alerts:
        alerts != null
            ? List<dynamic>.from(alerts!.map((x) => x.toJson()))
            : null,
  };
}
