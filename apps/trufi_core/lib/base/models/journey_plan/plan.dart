/// Journey plan models for the app.
///
/// Defines app-specific wrappers around package types that add Flutter-specific
/// functionality (Colors, TrufiLatLng, translations).
///
/// Also exports TransportMode and related types from transport_mode_ui.dart
/// since they're always used together with journey plan models.
library;

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/map_utils/trufi_map_utils.dart';

// ============================================
// Place - wrapper around package Place
// ============================================

class Place extends Equatable {
  final String name;
  final double lat;
  final double lon;

  const Place({
    this.name = 'Not name',
    required this.lat,
    required this.lon,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] as String? ?? 'Not name',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  factory Place.fromPackage(routing.Place place) {
    return Place(
      name: place.name,
      lat: place.lat,
      lon: place.lon,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'lat': lat, 'lon': lon};

  Place copyWith({String? name, double? lat, double? lon}) {
    return Place(
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  List<Object?> get props => [name, lat, lon];
}

// ============================================
// RouteInfo - wrapper around package Route
// ============================================

class RouteInfo extends Equatable {
  final String id;
  final String gtfsId;
  final String? shortName;
  final String? longName;
  final routing.TransportMode? mode;
  final int? type;
  final String? desc;
  final String? url;
  final String? color;
  final String? textColor;

  const RouteInfo({
    required this.id,
    required this.gtfsId,
    this.shortName,
    this.longName,
    this.mode,
    this.type,
    this.desc,
    this.url,
    this.color,
    this.textColor,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
        id: json['id'] as String? ?? '',
        gtfsId: json['gtfsId'] as String? ?? '',
        shortName: json['shortName'] as String?,
        longName: json['longName'] as String?,
        mode: routing.TransportModeExtension.fromString(json['mode']?.toString() ?? ''),
        type: int.tryParse(json['type']?.toString() ?? ''),
        desc: json['desc'] as String?,
        url: json['url'] as String?,
        color: json['color'] as String?,
        textColor: json['textColor'] as String?,
      );

  factory RouteInfo.fromPackage(routing.Route route) => RouteInfo(
        id: route.gtfsId ?? '',
        gtfsId: route.gtfsId ?? '',
        shortName: route.shortName,
        longName: route.longName,
        mode: route.mode,
        type: route.type,
        url: route.url,
        color: route.color,
        textColor: route.textColor,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'gtfsId': gtfsId,
        'shortName': shortName,
        'longName': longName,
        'mode': mode?.otpName,
        'type': type,
        'desc': desc,
        'url': url,
        'color': color,
        'textColor': textColor,
      };

  Color get primaryColor {
    return color != null
        ? Color(int.tryParse('0xFF$color') ?? 0xFF000000)
        : mode?.color ?? Colors.black;
  }

  Color get backgroundColor {
    return color != null
        ? Color(int.tryParse('0xFF$color') ?? 0xFF000000)
        : mode?.backgroundColor ?? Colors.black;
  }

  @override
  List<Object?> get props =>
      [id, gtfsId, shortName, longName, mode, type, desc, url, color, textColor];
}

// ============================================
// Leg - wrapper around package Leg with UI
// ============================================

class Leg extends Equatable {
  final String points;
  final routing.TransportMode transportMode;
  final RouteInfo? route;
  final String? routeColor;
  final String? shortName;
  final String? routeLongName;
  final double distance;
  final Duration duration;
  final Place toPlace;
  final Place fromPlace;
  final DateTime startTime;
  final DateTime endTime;
  final List<Place>? intermediatePlaces;
  final bool transitLeg;
  final List<TrufiLatLng> accumulatedPoints;

  const Leg({
    required this.points,
    required this.transportMode,
    required this.route,
    required this.routeColor,
    required this.shortName,
    required this.routeLongName,
    required this.distance,
    required this.duration,
    required this.toPlace,
    required this.fromPlace,
    required this.startTime,
    required this.endTime,
    required this.intermediatePlaces,
    required this.transitLeg,
    this.accumulatedPoints = const [],
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      points: json['legGeometry']?['points'] as String? ?? '',
      transportMode: routing.TransportModeExtension.fromString(
        json['mode'] as String? ?? 'WALK',
        specificTransport: json['routeLongName'] as String?,
      ),
      route: json['route'] != null && json['route'] is Map<String, dynamic>
          ? RouteInfo.fromJson(json['route'] as Map<String, dynamic>)
          : null,
      routeColor: json['routeColor'] as String?,
      shortName: json['route'] != null
          ? json['routeShortName'] as String? ??
              (json['route'] is String && (json['route'] as String).isNotEmpty
                  ? json['route'] as String
                  : null)
          : null,
      routeLongName: json['routeLongName'] as String?,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      duration: Duration(
          seconds: (json['duration'] as num?)?.toInt() ?? 0),
      toPlace: Place.fromJson(json['to'] as Map<String, dynamic>),
      fromPlace: Place.fromJson(json['from'] as Map<String, dynamic>),
      startTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['startTime'].toString()) ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['endTime'].toString()) ?? 0),
      intermediatePlaces: json['intermediateStops'] != null
          ? (json['intermediateStops'] as List<dynamic>)
              .map((x) => Place.fromJson(x as Map<String, dynamic>))
              .toList()
          : null,
      transitLeg: json['transitLeg'] as bool? ?? false,
      accumulatedPoints:
          decodePolyline(json['legGeometry']?['points'] as String? ?? ''),
    );
  }

  factory Leg.fromPackage(routing.Leg leg) {
    return Leg(
      points: leg.encodedPoints ?? '',
      transportMode: leg.transportMode,
      route: leg.route != null ? RouteInfo.fromPackage(leg.route!) : null,
      routeColor: leg.routeColor,
      shortName: leg.shortName,
      routeLongName: leg.routeLongName,
      distance: leg.distance,
      duration: leg.duration,
      toPlace: leg.toPlace != null
          ? Place.fromPackage(leg.toPlace!)
          : const Place(lat: 0, lon: 0),
      fromPlace: leg.fromPlace != null
          ? Place.fromPackage(leg.fromPlace!)
          : const Place(lat: 0, lon: 0),
      startTime: leg.startTime,
      endTime: leg.endTime,
      intermediatePlaces: leg.intermediatePlaces
          ?.map((p) => Place.fromPackage(p))
          .toList(),
      transitLeg: leg.transitLeg,
      accumulatedPoints: leg.decodedPoints
          .map((p) => TrufiLatLng(p.latitude, p.longitude))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'legGeometry': {'points': points},
        'mode': transportMode.otpName,
        'route': route?.toJson() ?? shortName,
        'routeColor': routeColor,
        'routeLongName': routeLongName,
        'distance': distance,
        'duration': duration.inSeconds,
        'to': toPlace.toJson(),
        'from': fromPlace.toJson(),
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
        'intermediateStops':
            intermediatePlaces?.map((p) => p.toJson()).toList(),
        'transitLeg': transitLeg,
      };

  Leg copyWith({
    String? points,
    routing.TransportMode? transportMode,
    RouteInfo? route,
    String? routeColor,
    String? shortName,
    String? routeLongName,
    double? distance,
    Duration? duration,
    Place? toPlace,
    Place? fromPlace,
    DateTime? startTime,
    DateTime? endTime,
    List<Place>? intermediatePlaces,
    bool? transitLeg,
    List<TrufiLatLng>? accumulatedPoints,
  }) {
    return Leg(
      points: points ?? this.points,
      transportMode: transportMode ?? this.transportMode,
      route: route ?? this.route,
      routeColor: routeColor ?? this.routeColor,
      shortName: shortName ?? this.shortName,
      routeLongName: routeLongName ?? this.routeLongName,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      toPlace: toPlace ?? this.toPlace,
      fromPlace: fromPlace ?? this.fromPlace,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      intermediatePlaces: intermediatePlaces ?? this.intermediatePlaces,
      transitLeg: transitLeg ?? this.transitLeg,
      accumulatedPoints: accumulatedPoints ?? this.accumulatedPoints,
    );
  }

  // UI methods
  String distanceString(TrufiBaseLocalization localization) =>
      _distanceWithTranslation(localization, distance);

  String get startTimeString => DateFormat('HH:mm').format(startTime);
  String get endTimeString => DateFormat('HH:mm').format(endTime);

  String durationLeg(TrufiBaseLocalization localization) =>
      _durationFormatString(localization, duration);

  bool get isLegOnFoot => transportMode == routing.TransportMode.walk;

  String get headSign =>
      route?.shortName ?? (route?.longName ?? (shortName ?? ''));

  int? get codeColor => int.tryParse('0xFF${route?.color ?? routeColor}');

  Color get primaryColor => transportMode.color;

  Color get backgroundColor {
    return codeColor != null
        ? Color(codeColor!)
        : transportMode.backgroundColor;
  }

  @override
  List<Object?> get props => [
        points,
        transportMode,
        route,
        routeColor,
        shortName,
        routeLongName,
        distance,
        duration,
        toPlace,
        fromPlace,
        startTime,
        endTime,
        intermediatePlaces,
        transitLeg,
        accumulatedPoints,
      ];
}

// ============================================
// Itinerary - wrapper around package Itinerary
// ============================================

class Itinerary extends Equatable {
  final List<Leg> legs;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final Duration walkTime;
  final double distance;
  final double walkDistance;
  final int transfers;

  Itinerary({
    required this.legs,
    required this.startTime,
    required this.endTime,
    required this.walkTime,
    required this.duration,
    required this.walkDistance,
    required this.transfers,
  }) : distance = _sumDistances(legs);

  static double _sumDistances(List<Leg> legs) {
    return legs.isNotEmpty
        ? legs.map((e) => e.distance).reduce((a, b) => a + b)
        : 0;
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      legs: (json['legs'] as List<dynamic>?)
              ?.map((j) => Leg.fromJson(j as Map<String, dynamic>))
              .toList() ??
          [],
      startTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['startTime'].toString()) ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['endTime'].toString()) ?? 0),
      duration:
          Duration(seconds: int.tryParse(json['duration'].toString()) ?? 0),
      walkTime:
          Duration(seconds: int.tryParse(json['walkTime'].toString()) ?? 0),
      walkDistance: double.tryParse(json['walkDistance'].toString()) ?? 0,
      transfers: int.tryParse(json['transfers'].toString()) ?? 0,
    );
  }

  factory Itinerary.fromPackage(routing.Itinerary itinerary) {
    return Itinerary(
      legs: itinerary.legs.map((l) => Leg.fromPackage(l)).toList(),
      startTime: itinerary.startTime,
      endTime: itinerary.endTime,
      duration: itinerary.duration,
      walkTime: itinerary.walkTime,
      walkDistance: itinerary.walkDistance,
      transfers: itinerary.numberOfTransfers,
    );
  }

  Map<String, dynamic> toJson() => {
        'legs': legs.map((l) => l.toJson()).toList(),
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
        'duration': duration.inSeconds,
        'walkTime': walkTime.inSeconds,
        'walkDistance': walkDistance,
        'transfers': transfers,
      };

  Itinerary copyWith({
    List<Leg>? legs,
    DateTime? startTime,
    DateTime? endTime,
    Duration? walkTime,
    Duration? duration,
    double? walkDistance,
    int? transfers,
  }) {
    return Itinerary(
      legs: legs ?? this.legs,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      walkTime: walkTime ?? this.walkTime,
      duration: duration ?? this.duration,
      walkDistance: walkDistance ?? this.walkDistance,
      transfers: transfers ?? this.transfers,
    );
  }

  // Compress consecutive walk/bike legs
  List<Leg> get compressLegs {
    final compressedLegs = <Leg>[];
    Leg? compressedLeg;

    for (final currentLeg in legs) {
      if (compressedLeg == null) {
        compressedLeg = currentLeg.copyWith();
        continue;
      }

      if (_canCombineLegs(compressedLeg, currentLeg)) {
        compressedLeg = compressedLeg.copyWith(
          duration: compressedLeg.duration + currentLeg.duration,
          distance: compressedLeg.distance + currentLeg.distance,
          toPlace: currentLeg.toPlace,
          endTime: currentLeg.endTime,
          transportMode: routing.TransportMode.bicycle,
          accumulatedPoints: [
            ...compressedLeg.accumulatedPoints,
            ...currentLeg.accumulatedPoints
          ],
        );
        continue;
      }

      compressedLegs.add(compressedLeg);
      compressedLeg = currentLeg.copyWith();
    }

    if (compressedLeg != null) {
      compressedLegs.add(compressedLeg);
    }

    return compressedLegs;
  }

  static bool _canCombineLegs(Leg leg1, Leg leg2) {
    final bool isOnFoot1 = leg1.transportMode == routing.TransportMode.bicycle ||
        leg1.transportMode == routing.TransportMode.walk;
    final bool isOnFoot2 = leg2.transportMode == routing.TransportMode.bicycle ||
        leg2.transportMode == routing.TransportMode.walk;
    return isOnFoot1 && isOnFoot2;
  }

  // UI methods
  String startDateText(TrufiBaseLocalization localization) {
    final tempDate = DateTime.now();
    final nowDate = DateTime(tempDate.year, tempDate.month, tempDate.day);
    if (nowDate.difference(startTime).inDays == 0) return '';
    if (nowDate.difference(startTime).inDays == 1) {
      return localization.commonTomorrow;
    }
    return DateFormat('E dd.MM.', localization.localeName).format(startTime);
  }

  String get startTimeHHmm => DateFormat('HH:mm').format(startTime);
  String get endTimeHHmm => DateFormat('HH:mm').format(endTime);

  String getDistanceString(TrufiBaseLocalization localization) =>
      _distanceWithTranslation(localization, distance);

  String durationFormat(TrufiBaseLocalization localization) =>
      _durationFormatString(localization, duration);

  String getWalkDistanceString(TrufiBaseLocalization localization) =>
      _distanceWithTranslation(localization, walkDistance);

  double get totalBikingDistance => _getTotalBikingDistance(compressLegs);
  Duration get totalBikingDuration => _getTotalBikingDuration(compressLegs);

  String firstLegStartTime(TrufiBaseLocalization localization) {
    final firstTransport = getFirstDeparture;
    if (firstTransport != null) {
      final stopType =
          firstTransport.transportMode == routing.TransportMode.rail ||
                  firstTransport.transportMode == routing.TransportMode.subway
              ? localization.commonFromStation
              : localization.commonFromStop;
      return "${localization.commonLeavesAt} $stopType ${firstTransport.fromPlace.name}";
    }
    return localization.commonItineraryNoTransitLegs;
  }

  Leg? get getFirstDeparture {
    for (final leg in compressLegs) {
      if (leg.transitLeg) return leg;
    }
    return null;
  }

  int getNumberLegHide(double renderBarThreshold) {
    return compressLegs
        .where((leg) {
          final legLength = (leg.duration.inSeconds / duration.inSeconds) * 10;
          return legLength < renderBarThreshold &&
              leg.transportMode != routing.TransportMode.walk;
        })
        .length;
  }

  int getNumberLegTime(double renderBarThreshold) {
    return compressLegs.fold(0, (prev, leg) {
      final legLength = (leg.duration.inSeconds / duration.inSeconds) * 10;
      return legLength < renderBarThreshold
          ? prev + leg.duration.inSeconds
          : prev;
    });
  }

  @override
  List<Object?> get props => [
        legs,
        distance,
        startTime,
        endTime,
        walkTime,
        duration,
        walkDistance,
      ];
}

// ============================================
// Plan - app-specific Plan with error handling
// ============================================

class Plan extends Equatable {
  final List<Itinerary>? itineraries;
  final PlanError? error;

  const Plan({this.itineraries, this.error});

  factory Plan.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      return Plan(
          error: PlanError.fromJson(json['error'] as Map<String, dynamic>));
    }
    final planJson = json['plan'] as Map<String, dynamic>?;
    if (planJson == null) return const Plan();

    return Plan(
      itineraries: _removeDuplicates(
        (planJson['itineraries'] as List<dynamic>?)
                ?.map((j) => Itinerary.fromJson(j as Map<String, dynamic>))
                .toList() ??
            [],
      ),
    );
  }

  factory Plan.fromPackage(routing.Plan plan) {
    return Plan(
      itineraries: plan.itineraries
          ?.map((i) => Itinerary.fromPackage(i))
          .toList(),
    );
  }

  static List<Itinerary> _removeDuplicates(List<Itinerary> itineraries) {
    final usedRoutes = <String>{};
    return itineraries.fold<List<Itinerary>>([], (result, itinerary) {
      final firstBusLeg = itinerary.legs.cast<Leg?>().firstWhere(
            (leg) => leg?.transitLeg ?? false,
            orElse: () => null,
          );
      if (firstBusLeg == null) {
        result.add(itinerary);
      } else if (!usedRoutes.contains(firstBusLeg.shortName)) {
        result.add(itinerary);
        if (firstBusLeg.shortName != null) {
          usedRoutes.add(firstBusLeg.shortName!);
        }
      }
      return result;
    });
  }

  static List<Itinerary> removePlanItineraryDuplicates(
          List<Itinerary> itineraries) =>
      _removeDuplicates(itineraries);

  Plan copyWith({List<Itinerary>? itineraries}) {
    return Plan(itineraries: itineraries ?? this.itineraries);
  }

  Map<String, dynamic> toJson() {
    return error != null
        ? {'error': error?.toJson()}
        : {
            'plan': {
              'itineraries': itineraries?.map((i) => i.toJson()).toList(),
            },
          };
  }

  bool get isOnlyWalk =>
      itineraries != null &&
      (itineraries!.isEmpty ||
          (itineraries!.length == 1 &&
              itineraries![0].legs.length == 1 &&
              itineraries![0].legs[0].transportMode ==
                  routing.TransportMode.walk));

  bool get hasError => error != null;

  @override
  List<Object?> get props => [itineraries, error];
}

// ============================================
// PlanError - app-specific error class
// ============================================

class PlanError {
  final int id;
  final String message;

  PlanError(this.id, this.message);

  factory PlanError.fromJson(Map<String, dynamic> json) {
    return PlanError(json['id'] as int? ?? -1, json['msg'] as String? ?? '');
  }

  factory PlanError.fromError(String error) => PlanError(-1, error);

  Map<String, dynamic> toJson() => {'id': id, 'msg': message};
}

// ============================================
// Utility functions
// ============================================

String _durationFormatString(
    TrufiBaseLocalization localization, Duration duration) {
  final minutes =
      localization.instructionDurationMinutes(duration.inMinutes.remainder(60));
  if (duration.inHours >= 1) {
    final hours = localization
        .instructionDurationHours(duration.inHours + duration.inDays * 24);
    return '$hours $minutes';
  }
  if (duration.inMinutes < 1) {
    return '< ${localization.instructionDurationMinutes(1)}';
  }
  return minutes;
}

String _distanceWithTranslation(
    TrufiBaseLocalization localization, double meters) {
  if (meters < 100) {
    double roundMeters = (meters / 10).round() * 10;
    return localization.instructionDistanceMeters(
        NumberFormat('#.0', localization.localeName)
            .format(roundMeters > 0 ? roundMeters : 1));
  }
  if (meters < 975) {
    return localization.instructionDistanceMeters(
        NumberFormat('#.0', localization.localeName)
            .format((meters / 50).round() * 50));
  }
  if (meters < 10000) {
    return localization.instructionDistanceKm(
        NumberFormat('#.0', localization.localeName)
            .format(((meters / 100).round() * 100) / 1000));
  }
  if (meters < 100000) {
    return localization.instructionDistanceKm(
        NumberFormat('#.0', localization.localeName)
            .format((meters / 1000).round()));
  }
  return localization.instructionDistanceKm(
      NumberFormat('#.0', localization.localeName)
          .format((meters / 1000).round() * 10));
}

double _getTotalBikingDistance(List<Leg> legs) {
  final bikingLegs =
      legs.where((l) => l.transportMode == routing.TransportMode.bicycle);
  return bikingLegs.isNotEmpty
      ? bikingLegs.map((e) => e.distance).reduce((a, b) => a + b)
      : 0;
}

Duration _getTotalBikingDuration(List<Leg> legs) {
  final bikingLegs =
      legs.where((l) => l.transportMode == routing.TransportMode.bicycle);
  return bikingLegs.isNotEmpty
      ? bikingLegs.map((e) => e.duration).reduce((a, b) => a + b)
      : Duration.zero;
}

// Backwards compatibility exports
String durationFormatString(
        TrufiBaseLocalization localization, Duration duration) =>
    _durationFormatString(localization, duration);

String distanceWithTranslation(
        TrufiBaseLocalization localization, double meters) =>
    _distanceWithTranslation(localization, meters);

String durationToHHmm(DateTime dateTime) => DateFormat('HH:mm').format(dateTime);

bool continueWithNoTransit(Leg leg1, Leg leg2) =>
    Itinerary._canCombineLegs(leg1, leg2);

double getTotalBikingDistance(List<Leg> legs) => _getTotalBikingDistance(legs);

Duration getTotalBikingDuration(List<Leg> legs) => _getTotalBikingDuration(legs);

double sumDistances(List<Leg> legs) => Itinerary._sumDistances(legs);

bool isWalkingLeg(Leg leg) => leg.transportMode == routing.TransportMode.walk;

bool isBikingLeg(Leg leg) => leg.transportMode == routing.TransportMode.bicycle;
