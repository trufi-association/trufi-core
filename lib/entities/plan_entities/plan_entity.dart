import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

import '../../custom_icons.dart';

class PlanEntity {
  PlanEntity({
    this.from,
    this.to,
    this.itineraries,
    this.error,
  });

  static const _error = "error";
  static const _itineraries = "itineraries";
  static const _from = "from";
  static const _plan = "plan";
  static const _to = "to";

  final PlanLocation from;
  final PlanLocation to;
  final List<PlanItinerary> itineraries;
  final PlanError error;

  factory PlanEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json.containsKey(_error)) {
      return PlanEntity(
          error: PlanError.fromJson(json[_error] as Map<String, dynamic>));
    } else {
      final Map<String, dynamic> planJson = json[_plan] as Map<String, dynamic>;
      return PlanEntity(
        from: PlanLocation.fromJson(planJson[_from] as Map<String, dynamic>),
        to: PlanLocation.fromJson(planJson[_to] as Map<String, dynamic>),
        itineraries: _removePlanItineraryDuplicates(
          planJson[_itineraries]
              .map<PlanItinerary>(
                (dynamic itineraryJson) =>
                    PlanItinerary.fromJson(itineraryJson as Map<String, dynamic>),
              )
              .toList() as List<PlanItinerary>,
        ),
      );
    }
  }

  static List<PlanItinerary> _removePlanItineraryDuplicates(
    List<PlanItinerary> itineraries,
  ) {
    final usedRoutes = <String>{};
    // Fold the itinerary list to build up list without duplicates
    return itineraries.fold<List<PlanItinerary>>(
      <PlanItinerary>[],
      (itineraries, itinerary) {
        // Get first bus leg
        final firstBusLeg = itinerary.legs.firstWhere(
          (leg) => leg.mode == "BUS",
          orElse: () => null,
        );
        // If no bus leg exist just add the itinerary
        if (firstBusLeg == null) {
          itineraries.add(itinerary);
        } else {
          // If a bus leg exist and the first route isn't used yet just add the itinerary
          if (!usedRoutes.contains(firstBusLeg.route)) {
            itineraries.add(itinerary);
            usedRoutes.add(firstBusLeg.route);
          }
        }
        // Return current list
        return itineraries;
      },
    );
  }

  factory PlanEntity.fromError(String error) {
    return PlanEntity(error: PlanError.fromError(error));
  }

  Map<String, dynamic> toJson() {
    return error != null
        ? {_error: error.toJson()}
        : {
            _plan: {
              _from: from.toJson(),
              _to: to.toJson(),
              _itineraries:
                  itineraries.map((itinerary) => itinerary.toJson()).toList()
            }
          };
  }

  bool get hasError => error != null;
}

class PlanError {
  PlanError(this.id, this.message);

  static const String _id = "id";
  static const String _message = "msg";

  final int id;
  final String message;

  factory PlanError.fromJson(Map<String, dynamic> json) {
    return PlanError(json[_id] as int, json[_message] as String);
  }

  factory PlanError.fromError(String error) {
    return PlanError(-1, error);
  }

  Map<String, dynamic> toJson() {
    return {
      _id: id,
      _message: message,
    };
  }
}

class PlanLocation {
  PlanLocation({
    this.name,
    this.latitude,
    this.longitude,
  });

  static const String _name = "name";
  static const String _latitude = "lat";
  static const String _longitude = "lon";

  final String name;
  final double latitude;
  final double longitude;

  factory PlanLocation.fromJson(Map<String, dynamic> json) {
    return PlanLocation(
      name: json[_name] as String,
      latitude: json[_latitude] as double,
      longitude: json[_longitude] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _name: name,
      _latitude: latitude,
      _longitude: longitude,
    };
  }
}

class PlanItinerary {
  static const String _legs = "legs";

  static int _distanceForLegs(List<PlanItineraryLeg> legs) =>
      legs.fold<int>(0, (distance, leg) => distance += leg.distance.ceil());

  static int _timeForLegs(List<PlanItineraryLeg> legs) => legs.fold<int>(
      0, (time, leg) => time += (leg.duration.ceil() / 60).ceil());

  PlanItinerary({
    this.legs,
  })  : distance = _distanceForLegs(legs),
        time = _timeForLegs(legs);

  final List<PlanItineraryLeg> legs;
  final int distance;
  final int time;

  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return PlanItinerary(
      legs: json[_legs].map<PlanItineraryLeg>((dynamic json) {
        return PlanItineraryLeg.fromJson(json as Map<String, dynamic>);
      }).toList() as List<PlanItineraryLeg>,
    );
  }

  Map<String, dynamic> toJson() {
    return {_legs: legs.map((itinerary) => itinerary.toJson()).toList()};
  }
}

enum TransportMode {
  airplane,
  bicycle,
  bus,
  cableCar,
  car,
  ferry,
  flexible,
  funicular,
  gondola,
  legSwitch,
  rail,
  subway,
  tram,
  transit,
  walk,
}

TransportMode getTransportMode(String enumText) 
    => TransportModeExtension.names.keys.firstWhere(
      (key) => key.name == enumText,
      orElse: () => TransportMode.walk,
    );

extension TransportModeExtension on TransportMode {
  static const names = {
    TransportMode.airplane: "AIRPLANE",
    TransportMode.bicycle: "BICYCLE",
    TransportMode.bus: "BUS",
    TransportMode.cableCar: "CABLE_CAR",
    TransportMode.car: "CAR",
    TransportMode.ferry: "FERRY",
    TransportMode.flexible: "FLEXIBLE",
    TransportMode.funicular: "FUNICULAR",
    TransportMode.gondola: "GONDOLA",
    TransportMode.legSwitch: "LEG_SWITCH",
    TransportMode.rail: "RAIL",
    TransportMode.subway: "SUBWAY",
    TransportMode.tram: "TRAM",
    TransportMode.transit: "TRANSIT",
    TransportMode.walk: "WALK",
  };
  String get name => names[this] ?? 'WALK';
}

class PlanItineraryLeg {
  PlanItineraryLeg({
    this.points,
    this.mode,
    this.route,
    this.routeLongName,
    this.distance,
    this.duration,
    this.toName,
  });

  static const _distance = "distance";
  static const _duration = "duration";
  static const _legGeometry = "legGeometry";
  static const _points = "points";
  static const _mode = "mode";
  static const _name = "name";
  static const _route = "route";
  static const _routeLongName = "routeLongName";
  static const _to = "to";

  // route name keywords for specific types of transportation
  static const typeTrufi = "trufi";
  static const typeMicro = "micro";
  static const typeMinibus = "minibus";
  static const typeGondola = "gondola";
  static const typeLightRail = "light rail";

  final String points;
  final String mode;
  final String route;
  final String routeLongName;
  final double distance;
  final double duration;
  final String toName;

  factory PlanItineraryLeg.fromJson(Map<String, dynamic> json) {
    return PlanItineraryLeg(
      points: json[_legGeometry][_points] as String,
      mode: json[_mode] as String,
      route: json[_route] as String,
      routeLongName: json[_routeLongName] as String,
      distance: json[_distance] as double,
      duration: json[_duration] as double,
      toName: json[_to][_name] as String,
    );
  }

  String toInstruction(TrufiLocalization localization) {
    final StringBuffer sb = StringBuffer();
    if (mode == 'WALK') {
      sb.write(localization.instructionWalk(_durationString(localization),
          _distanceString(localization), _toString(localization)));
    } else {
      sb.write(localization.instructionRide(
          _carTypeString(localization) + (route.isNotEmpty ? " $route" : ""),
          _durationString(localization),
          _distanceString(localization),
          _toString(localization)));
    }
    return sb.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      _legGeometry: {_points: points},
      _mode: mode,
      _route: route,
      _routeLongName: routeLongName,
      _distance: distance,
      _duration: duration,
      _to: {_name: toName}
    };
  }

  String _carTypeString(TrufiLocalization localization) {
    final String carType = routeLongName?.toLowerCase() ?? "";
    return mode == 'CAR'
        ? localization.instructionVehicleCar
        : carType.contains(typeTrufi)
            ? localization.instructionVehicleTrufi
            : carType.contains(typeMicro)
                ? localization.instructionVehicleMicro
                : carType.contains(typeMinibus)
                    ? localization.instructionVehicleMinibus
                    : carType.contains(typeGondola)
                        ? localization.instructionVehicleGondola
                        : carType.contains(typeLightRail)
                            ? localization.instructionVehicleLightRail
                            : localization.instructionVehicleBus;
  }

  String _distanceString(TrufiLocalization localization) {
    return distance >= 1000
        ? localization.instructionDistanceKm(distance.ceil() ~/ 1000)
        : localization.instructionDistanceMeters(distance.ceil());
  }

  String _durationString(TrufiLocalization localization) {
    final value = (duration.ceil() / 60).ceil();
    return localization.instructionDurationMinutes(value);
  }

  String _toString(TrufiLocalization localization) {
    return toName == 'Destination' ? localization.commonDestination : toName;
  }

  IconData iconData() {
    final String carType = routeLongName?.toLowerCase() ?? "";
    return mode == 'WALK'
        ? Icons.directions_walk
        : mode == 'CAR'
            ? Icons.drive_eta
            : carType.contains(typeTrufi)
                ? Icons.local_taxi
                : carType.contains(typeMicro)
                    ? Icons.directions_bus
                    : carType.contains(typeMinibus)
                        ? Icons.airport_shuttle
                        : carType.contains(typeGondola)
                            ? CustomIcons.gondola
                            : carType.contains(typeLightRail)
                                ? Icons.train
                                : Icons.directions_bus;
  }
}

class Ad {
  Ad({
    this.text,
    this.url,
    this.location,
  });

  static const _ad = "ad";
  static const _text = "text";
  static const _url = "url";
  static const _location = "location";

  final String text;
  final String url;
  final PlanLocation location;

  factory Ad.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    final Map<String, dynamic> adJson = json[_ad] as Map<String, dynamic>;
    return Ad(
      text: adJson[_text] as String,
      url: adJson[_url] as String,
      location: (adJson[_location] as Map<String, dynamic>).isEmpty
          ? null
          : PlanLocation.fromJson(adJson[_location] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _ad: {
        _text: text.toString(),
        _url: url.toString(),
        _location: location.toJson(),
      }
    };
  }
}
