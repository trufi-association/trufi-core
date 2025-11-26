import 'package:trufi_core/models/plan_entity.dart';

import 'alert.dart';
import 'enums/bikes_allowed.dart';
import 'enums/wheelchair_boarding.dart';
import 'geometry.dart';
import 'pattern.dart';
import 'stoptime.dart';

class TripEntity {
  final String? id;
  final String? gtfsId;
  final RouteEntity? route;
  final String? serviceId;
  final List<String>? activeDates;
  final String? tripShortName;
  final String? tripHeadsign;
  final String? routeShortName;
  final String? directionId;
  final String? blockId;
  final String? shapeId;
  final WheelchairBoarding? wheelchairAccessible;
  final BikesAllowed? bikesAllowed;
  final PatternOtpEntity? pattern;
  final List<StopEntity>? stops;
  final String? semanticHash;
  final List<Stoptime>? stoptimes;
  final Stoptime? departureStoptime;
  final Stoptime? arrivalStoptime;
  final List<Stoptime>? stoptimesForDate;
  final List<double>? geometry;
  final GeometryEntity? tripGeometry;
  final List<AlertEntity>? alerts;

  const TripEntity({
    this.id,
    this.gtfsId,
    this.route,
    this.serviceId,
    this.activeDates,
    this.tripShortName,
    this.tripHeadsign,
    this.routeShortName,
    this.directionId,
    this.blockId,
    this.shapeId,
    this.wheelchairAccessible,
    this.bikesAllowed,
    this.pattern,
    this.stops,
    this.semanticHash,
    this.stoptimes,
    this.departureStoptime,
    this.arrivalStoptime,
    this.stoptimesForDate,
    this.geometry,
    this.tripGeometry,
    this.alerts,
  });

  static const String _id = 'id';
  static const String _gtfsId = 'gtfsId';
  static const String _route = 'route';
  static const String _serviceId = 'serviceId';
  static const String _activeDates = 'activeDates';
  static const String _tripShortName = 'tripShortName';
  static const String _tripHeadsign = 'tripHeadsign';
  static const String _routeShortName = 'routeShortName';
  static const String _directionId = 'directionId';
  static const String _blockId = 'blockId';
  static const String _shapeId = 'shapeId';
  static const String _wheelchairAccessible = 'wheelchairAccessible';
  static const String _bikesAllowed = 'bikesAllowed';
  static const String _pattern = 'pattern';
  static const String _stops = 'stops';
  static const String _semanticHash = 'semanticHash';
  static const String _stoptimes = 'stoptimes';
  static const String _departureStoptime = 'departureStoptime';
  static const String _arrivalStoptime = 'arrivalStoptime';
  static const String _stoptimesForDate = 'stoptimesForDate';
  static const String _geometry = 'geometry';
  static const String _tripGeometry = 'tripGeometry';
  static const String _alerts = 'alerts';

  factory TripEntity.fromJson(Map<String, dynamic> json) => TripEntity(
    id: json[_id],
    gtfsId: json[_gtfsId],
    route:
        json[_route] != null
            ? RouteEntity.fromJson(json[_route] as Map<String, dynamic>)
            : null,
    serviceId: json[_serviceId],
    activeDates:
        json[_activeDates] != null
            ? (json[_activeDates] as List<dynamic>).cast<String>()
            : null,
    tripShortName: json[_tripShortName],
    tripHeadsign: json[_tripHeadsign],
    routeShortName: json[_routeShortName],
    directionId: json[_directionId],
    blockId: json[_blockId],
    shapeId: json[_shapeId],
    wheelchairAccessible: WheelchairBoardingExtension.getWheelchairBoardingByString(
      json[_wheelchairAccessible],
    ),
    bikesAllowed: BikesAllowedExtension.getBikesAllowedByString(json[_bikesAllowed]),
    pattern:
        json[_pattern] != null
            ? PatternOtpEntity.fromJson(json[_pattern] as Map<String, dynamic>)
            : null,
    stops:
        json[_stops] != null
            ? List<StopEntity>.from(
              (json[_stops] as List<dynamic>).map(
                (x) => StopEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    semanticHash: json[_semanticHash],
    stoptimes:
        json[_stoptimes] != null
            ? List<Stoptime>.from(
              (json[_stoptimes] as List<dynamic>).map(
                (x) => Stoptime.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    departureStoptime:
        json[_departureStoptime] != null
            ? Stoptime.fromJson(
              json[_departureStoptime] as Map<String, dynamic>,
            )
            : null,
    arrivalStoptime:
        json[_arrivalStoptime] != null
            ? Stoptime.fromJson(json[_arrivalStoptime] as Map<String, dynamic>)
            : null,
    stoptimesForDate:
        json[_stoptimesForDate] != null
            ? List<Stoptime>.from(
              (json[_stoptimesForDate] as List<dynamic>).map(
                (x) => Stoptime.fromJson(x as Map<String, dynamic>),
              ),
            )
            : null,
    geometry:
        json[_geometry] != null ? (json[_geometry] as List<double>) : null,
    tripGeometry:
        json[_tripGeometry] != null
            ? GeometryEntity.fromJson(json[_tripGeometry] as Map<String, dynamic>)
            : null,
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
    _gtfsId: gtfsId,
    _route: route?.toJson(),
    _serviceId: serviceId,
    _activeDates: activeDates,
    _tripShortName: tripShortName,
    _tripHeadsign: tripHeadsign,
    _routeShortName: routeShortName,
    _directionId: directionId,
    _blockId: blockId,
    _shapeId: shapeId,
    _wheelchairAccessible: wheelchairAccessible?.name,
    _bikesAllowed: bikesAllowed?.name,
    _pattern: pattern?.toJson(),
    _stops: List.generate(stops?.length ?? 0, (index) => stops![index].toJson()),
    _semanticHash: semanticHash,
    _stoptimes: List.generate(
      stoptimes?.length ?? 0,
      (index) => stoptimes![index].toJson(),
    ),
    _departureStoptime: departureStoptime?.toJson(),
    _arrivalStoptime: arrivalStoptime?.toJson(),
    _stoptimesForDate: List.generate(
      stoptimesForDate?.length ?? 0,
      (index) => stoptimesForDate![index].toJson(),
    ),
    _geometry: geometry,
    _tripGeometry: tripGeometry?.toJson(),
    _alerts: List.generate(
      alerts?.length ?? 0,
      (index) => alerts![index].toJson(),
    ),
  };
}
