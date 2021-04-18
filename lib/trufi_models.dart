import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

import './custom_icons.dart';
import './trufi_configuration.dart';

class MapStyle {
  static const String streets = 'streets';
  static const String satellite = 'satellite';
  static const String terrain = 'terrain';
}

class TrufiLocation {
  TrufiLocation({
    @required this.description,
    @required this.latitude,
    @required this.longitude,
    this.alternativeNames,
    this.localizedNames,
    this.address,
    this.type,
  })  : assert(description != null),
        assert(latitude != null),
        assert(longitude != null);

  static const String keyDescription = 'description';
  static const String keyLatitude = 'latitude';
  static const String keyLongitude = 'longitude';
  static const String keyType = 'type';

  final String description;
  final double latitude;
  final double longitude;
  final List<String> alternativeNames;
  final Map<String, String> localizedNames;
  final String address;
  final String type;

  factory TrufiLocation.fromLatLng(String description, LatLng point) {
    return TrufiLocation(
      description: description,
      latitude: point.latitude,
      longitude: point.longitude,
    );
  }

  factory TrufiLocation.fromLocationsJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['name'] as String,
      latitude: json['coords']['lat'] as double,
      longitude: json['coords']['lng'] as double,
    );
  }

  factory TrufiLocation.fromSearchPlacesJson(List<dynamic> json) {
    return TrufiLocation(
      description: json[0].toString(),
      alternativeNames: json[1].cast<String>() as List<String>,
      localizedNames: json[2].cast<String, String>() as Map<String, String>,
      longitude: json[3][0].toDouble() as double,
      latitude: json[3][1].toDouble() as double,
      address: json[4] as String,
      type: json[5] as String,
    );
  }

  factory TrufiLocation.fromPlanLocation(PlanLocation value) {
    return TrufiLocation(
      description: value.name,
      latitude: value.latitude,
      longitude: value.longitude,
    );
  }

  factory TrufiLocation.fromSearch(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'] as String,
      latitude: json['lat'] as double,
      longitude: json['lng'] as double,
    );
  }

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return TrufiLocation(
      description: json[keyDescription] as String,
      latitude: json[keyLatitude] as double,
      longitude: json[keyLongitude] as double,
      type: json[keyType] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      keyDescription: description,
      keyLatitude: latitude,
      keyLongitude: longitude,
      keyType: type,
    };
  }

  @override
  bool operator ==(Object o) =>
      o is TrufiLocation &&
      o.description == description &&
      o.latitude == latitude &&
      o.longitude == longitude;

  @override
  int get hashCode =>
      description.hashCode ^ latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() {
    return '$latitude,$longitude';
  }

  String get displayName {
    final abbreviations = TrufiConfiguration().abbreviations;
    return abbreviations.keys.fold<String>(description, (
      description,
      abbreviation,
    ) {
      return description.replaceAll(
        abbreviation,
        abbreviations[abbreviation],
      );
    });
  }
}

class TrufiStreet {
  TrufiStreet({@required this.location});

  final TrufiLocation location;
  final junctions = <TrufiStreetJunction>[];

  factory TrufiStreet.fromSearchJson(List<dynamic> json) {
    return TrufiStreet(
      location: TrufiLocation(
        description: json[0] as String,
        alternativeNames: json[1].cast<String>() as List<String>,
        longitude: json[2][0].toDouble() as double,
        latitude: json[2][1].toDouble() as double,
      ),
    );
  }

  String get description => location.description;

  String get displayName => location.displayName;
}

class TrufiStreetJunction {
  TrufiStreetJunction({
    @required this.street1,
    @required this.street2,
    @required this.latitude,
    @required this.longitude,
  });

  final TrufiStreet street1;
  final TrufiStreet street2;
  final double latitude;
  final double longitude;

  String get description {
    return "${street1.location.description} & ${street2.location.description}";
  }

  String displayName(TrufiLocalization localization) =>
      localization.instructionJunction(
        street1.displayName,
        street2.displayName,
      );

  TrufiLocation location(TrufiLocalization localization) {
    return TrufiLocation(
      description: displayName(localization),
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class LevenshteinObject {
  LevenshteinObject(this.object, this.distance);

  final dynamic object;
  final int distance;
}

class Plan {
  Plan({
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

  factory Plan.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json.containsKey(_error)) {
      return Plan(
          error: PlanError.fromJson(json[_error] as Map<String, dynamic>));
    } else {
      final Map<String, dynamic> planJson = json[_plan] as Map<String, dynamic>;
      return Plan(
        from: PlanLocation.fromJson(planJson[_from] as Map<String, dynamic>),
        to: PlanLocation.fromJson(planJson[_to] as Map<String, dynamic>),
        itineraries: _removePlanItineraryDuplicates(
          planJson[_itineraries]
              .map<PlanItinerary>(
                (Map<String, dynamic> itineraryJson) =>
                    PlanItinerary.fromJson(itineraryJson),
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

  factory Plan.fromError(String error) {
    return Plan(error: PlanError.fromError(error));
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
      legs: json[_legs].map<PlanItineraryLeg>((Map<String, dynamic> json) {
        return PlanItineraryLeg.fromJson(json);
      }).toList() as List<PlanItineraryLeg>,
    );
  }

  Map<String, dynamic> toJson() {
    return {_legs: legs.map((itinerary) => itinerary.toJson()).toList()};
  }
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

  // route name keywords for specfic types of transportation
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
