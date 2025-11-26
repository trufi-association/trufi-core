import 'package:trufi_core/models/trip.dart';

import 'alert.dart';
import 'enums/bikes_allowed.dart';
import 'enums/wheelchair_boarding.dart';
import 'geometry.dart';
import 'pattern.dart';
import 'route.dart';
import 'stop.dart';
import 'stoptime.dart';

class Trip {
  final String? id;
  final String? gtfsId;
  final RouteOtp? route;
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
  final PatternOtp? pattern;
  final List<Stop>? stops;
  final String? semanticHash;
  final List<Stoptime>? stoptimes;
  final Stoptime? departureStoptime;
  final Stoptime? arrivalStoptime;
  final List<Stoptime>? stoptimesForDate;
  final List<double>? geometry;
  final Geometry? tripGeometry;
  final List<Alert>? alerts;

  const Trip({
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

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String?,
    gtfsId: json['gtfsId'] as String?,
    route: json['route'] != null
        ? RouteOtp.fromJson(json['route'] as Map<String, dynamic>)
        : null,
    serviceId: json['serviceId'] as String?,
    activeDates: json['activeDates'] != null
        ? (json['activeDates'] as List<dynamic>).cast<String>()
        : null,
    tripShortName: json['tripShortName'] as String?,
    tripHeadsign: json['tripHeadsign'] as String?,
    routeShortName: json['routeShortName'] as String?,
    directionId: json['directionId'] as String?,
    blockId: json['blockId'] as String?,
    shapeId: json['shapeId'] as String?,
    wheelchairAccessible: getWheelchairBoardingByString(
      json['wheelchairAccessible'].toString(),
    ),
    bikesAllowed: getBikesAllowedByString(json['bikesAllowed'].toString()),
    pattern: json['pattern'] != null
        ? PatternOtp.fromJson(json['pattern'] as Map<String, dynamic>)
        : null,
    stops: json['stops'] != null
        ? List<Stop>.from(
            (json["stops"] as List<dynamic>).map(
              (x) => Stop.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    semanticHash: json['semanticHash'] as String?,
    stoptimes: json['stoptimes'] != null
        ? List<Stoptime>.from(
            (json["stoptimes"] as List<dynamic>).map(
              (x) => Stoptime.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    departureStoptime: json['departureStoptime'] != null
        ? Stoptime.fromJson(json['departureStoptime'] as Map<String, dynamic>)
        : null,
    arrivalStoptime: json['arrivalStoptime'] != null
        ? Stoptime.fromJson(json['arrivalStoptime'] as Map<String, dynamic>)
        : null,
    stoptimesForDate: json['stoptimesForDate'] != null
        ? List<Stoptime>.from(
            (json["stoptimesForDate"] as List<dynamic>).map(
              (x) => Stoptime.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    geometry: json['geometry'] != null
        ? (json['geometry'] as List<double>)
        : null,
    tripGeometry: json['tripGeometry'] != null
        ? Geometry.fromJson(json['tripGeometry'] as Map<String, dynamic>)
        : null,
    alerts: json['alerts'] != null
        ? List<Alert>.from(
            (json["alerts"] as List<dynamic>).map(
              (x) => Alert.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'gtfsId': gtfsId,
    'route': route?.toJson(),
    'serviceId': serviceId,
    'activeDates': activeDates,
    'tripShortName': tripShortName,
    'tripHeadsign': tripHeadsign,
    'routeShortName': routeShortName,
    'directionId': directionId,
    'blockId': blockId,
    'shapeId': shapeId,
    'wheelchairAccessible': wheelchairAccessible?.name,
    'bikesAllowed': bikesAllowed?.name,
    'pattern': pattern?.toJson(),
    'stops': List.generate(
      stops?.length ?? 0,
      (index) => stops![index].toJson(),
    ),
    'semanticHash': semanticHash,
    'stoptimes': List.generate(
      stoptimes?.length ?? 0,
      (index) => stoptimes![index].toJson(),
    ),
    'departureStoptime': departureStoptime?.toJson(),
    'arrivalStoptime': arrivalStoptime?.toJson(),
    'stoptimesForDate': List.generate(
      stoptimesForDate?.length ?? 0,
      (index) => stoptimesForDate![index].toJson(),
    ),
    'geometry': geometry,
    'tripGeometry': tripGeometry?.toJson(),
    'alerts': List.generate(
      alerts?.length ?? 0,
      (index) => alerts![index].toJson(),
    ),
  };

  TripEntity toTripEntity() {
    return TripEntity(
      id: id,
      gtfsId: gtfsId,
      // route: route,
      serviceId: serviceId,
      activeDates: activeDates,
      tripShortName: tripShortName,
      tripHeadsign: tripHeadsign,
      routeShortName: routeShortName,
      directionId: directionId,
      blockId: blockId,
      shapeId: shapeId,
      // wheelchairAccessible: wheelchairAccessible,
      // bikesAllowed: bikesAllowed,
      // pattern: pattern,
      // stops: stops,
      semanticHash: semanticHash,
      // stoptimes: stoptimes,
      // departureStoptime: departureStoptime,
      // arrivalStoptime: arrivalStoptime,
      // stoptimesForDate: stoptimesForDate,
      geometry: geometry,
      // tripGeometry: tripGeometry,
      // alerts: alerts,
    );
  }
}
