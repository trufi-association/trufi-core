import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import './trufi_configuration.dart';
import './trufi_localizations.dart';
import './custom_icons.dart';

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
      description: json['name'],
      latitude: json['coords']['lat'],
      longitude: json['coords']['lng'],
    );
  }

  factory TrufiLocation.fromSearchPlacesJson(List<dynamic> json) {
    return TrufiLocation(
      description: json[0].toString(),
      alternativeNames: json[1].cast<String>(),
      localizedNames: json[2].cast<String, String>(),
      longitude: json[3][0].toDouble(),
      latitude: json[3][1].toDouble(),
      address: json[4],
      type: json[5],
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
      description: json['description'],
      latitude: json['lat'],
      longitude: json['lng'],
    );
  }

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return TrufiLocation(
      description: json[keyDescription],
      latitude: json[keyLatitude],
      longitude: json[keyLongitude],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      keyDescription: description,
      keyLatitude: latitude,
      keyLongitude: longitude,
    };
  }

  bool operator ==(o) =>
      o is TrufiLocation &&
      o.description == description &&
      o.latitude == latitude &&
      o.longitude == longitude;

  int get hashCode =>
      description.hashCode ^ latitude.hashCode ^ longitude.hashCode;

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
  final junctions = List<TrufiStreetJunction>();

  factory TrufiStreet.fromSearchJson(List<dynamic> json) {
    return TrufiStreet(
      location: TrufiLocation(
        description: json[0],
        alternativeNames: json[1].cast<String>(),
        longitude: json[2][0].toDouble(),
        latitude: json[2][1].toDouble(),
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

  static const _Error = "error";
  static const _Itineraries = "itineraries";
  static const _From = "from";
  static const _Plan = "plan";
  static const _To = "to";

  final PlanLocation from;
  final PlanLocation to;
  final List<PlanItinerary> itineraries;
  final PlanError error;

  factory Plan.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json.containsKey(_Error)) {
      return Plan(error: PlanError.fromJson(json[_Error]));
    } else {
      Map<String, dynamic> planJson = json[_Plan];
      return Plan(
        from: PlanLocation.fromJson(planJson[_From]),
        to: PlanLocation.fromJson(planJson[_To]),
        itineraries: _removePlanItineraryDuplicates(
          planJson[_Itineraries]
              .map<PlanItinerary>(
                (itineraryJson) => PlanItinerary.fromJson(itineraryJson),
              )
              .toList(),
        ),
      );
    }
  }

  static List<PlanItinerary> _removePlanItineraryDuplicates(
    List<PlanItinerary> itineraries,
  ) {
    final usedRoutes = Set<String>();
    // Fold the itinerary list to build up list without duplicates
    return itineraries.fold<List<PlanItinerary>>(
      List<PlanItinerary>(),
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
        ? {_Error: error.toJson()}
        : {
            _Plan: {
              _From: from.toJson(),
              _To: to.toJson(),
              _Itineraries:
                  itineraries.map((itinerary) => itinerary.toJson()).toList()
            }
          };
  }

  bool get hasError => error != null;
}

class PlanError {
  PlanError(this.id, this.message);

  static const String _Id = "id";
  static const String _Message = "msg";

  final int id;
  final String message;

  factory PlanError.fromJson(Map<String, dynamic> json) {
    return PlanError(json[_Id], json[_Message]);
  }

  factory PlanError.fromError(String error) {
    return PlanError(-1, error);
  }

  Map<String, dynamic> toJson() {
    return {
      _Id: id,
      _Message: message,
    };
  }
}

class PlanLocation {
  PlanLocation({
    this.name,
    this.latitude,
    this.longitude,
  });

  static const String _Name = "name";
  static const String _Latitude = "lat";
  static const String _Longitude = "lon";

  final String name;
  final double latitude;
  final double longitude;

  factory PlanLocation.fromJson(Map<String, dynamic> json) {
    return PlanLocation(
      name: json[_Name],
      latitude: json[_Latitude],
      longitude: json[_Longitude],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _Name: name,
      _Latitude: latitude,
      _Longitude: longitude,
    };
  }
}

class PlanItinerary {
  static const String _Legs = "legs";

  static int _distanceForLegs(List<PlanItineraryLeg> legs) =>
      legs.fold<int>(0, (distance, leg) => distance += leg.distance.ceil());

  static int _timeForLegs(List<PlanItineraryLeg> legs) => legs.fold<int>(
      0, (time, leg) => time += (leg.duration.ceil() / 60).ceil());

  PlanItinerary({
    this.legs,
  })  : this.distance = _distanceForLegs(legs),
        this.time = _timeForLegs(legs);

  final List<PlanItineraryLeg> legs;
  final int distance;
  final int time;

  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return PlanItinerary(
        legs: json[_Legs].map<PlanItineraryLeg>((json) {
      return PlanItineraryLeg.fromJson(json);
    }).toList());
  }

  Map<String, dynamic> toJson() {
    return {_Legs: legs.map((itinerary) => itinerary.toJson()).toList()};
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

  static const _Distance = "distance";
  static const _Duration = "duration";
  static const _LegGeometry = "legGeometry";
  static const _Points = "points";
  static const _Mode = "mode";
  static const _Name = "name";
  static const _Route = "route";
  static const _RouteLongName = "routeLongName";
  static const _To = "to";

  // route name keywords for specfic types of transportation
  static const type_trufi = "trufi";
  static const type_micro = "micro";
  static const type_minibus = "minibus";
  static const type_gondola = "gondola";
  static const type_light_rail = "light rail";


  final String points;
  final String mode;
  final String route;
  final String routeLongName;
  final double distance;
  final double duration;
  final String toName;

  factory PlanItineraryLeg.fromJson(Map<String, dynamic> json) {
    return PlanItineraryLeg(
      points: json[_LegGeometry][_Points],
      mode: json[_Mode],
      route: json[_Route],
      routeLongName: json[_RouteLongName],
      distance: json[_Distance],
      duration: json[_Duration],
      toName: json[_To][_Name],
    );
  }

  String toInstruction(TrufiLocalization localization) {
    StringBuffer sb = StringBuffer();
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
      _LegGeometry: {_Points: points},
      _Mode: mode,
      _Route: route,
      _RouteLongName: routeLongName,
      _Distance: distance,
      _Duration: duration,
      _To: {_Name: toName}
    };
  }

  String _carTypeString(TrufiLocalization localization) {
    String carType = routeLongName?.toLowerCase() ?? "";
    return mode == 'CAR'
        ? localization.instructionVehicleCar()
        : carType.contains(type_trufi)
            ? localization.instructionVehicleTrufi()
            : carType.contains(type_micro)
                ? localization.instructionVehicleMicro()
                : carType.contains(type_minibus)
                    ? localization.instructionVehicleMinibus()
                    : carType.contains(type_gondola)
                        ? localization.instructionVehicleGondola()
                        : carType.contains(type_light_rail)
                            ? localization.instructionVehicleLightRail()
                            : localization.instructionVehicleBus();
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
    return toName == 'Destination' ? localization.commonDestination() : toName;
  }

  IconData iconData() {
    String carType = routeLongName?.toLowerCase() ?? "";
    return mode == 'WALK'
        ? Icons.directions_walk
        : mode == 'CAR'
            ? Icons.drive_eta
            : carType.contains(type_trufi)
                ? Icons.local_taxi
                : carType.contains(type_micro)
                    ? Icons.directions_bus
                    : carType.contains(type_minibus)
                        ? Icons.airport_shuttle
                        : carType.contains(type_gondola)
                            ? CustomIcons.gondola
                            : carType.contains(type_light_rail)
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

  static const _Ad = "ad";
  static const _Text = "text";
  static const _Url = "url";
  static const _Location = "location";

  final String text;
  final String url;
  final PlanLocation location;

  factory Ad.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Map<String, dynamic> adJson = json[_Ad];
    return Ad(
      text: adJson[_Text],
      url: adJson[_Url] ?? null,
      location: adJson[_Location].isEmpty ? null : PlanLocation.fromJson(adJson[_Location]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _Ad: {
        _Text: text.toString(),
        _Url: url.toString(),
        _Location: location.toJson(),
      }
    };
  }
}