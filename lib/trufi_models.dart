import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/routing/routing_manager.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/trufi_localizations.dart';

class TrufiLocation {
  TrufiLocation({
    @required this.description,
    @required this.latitude,
    @required this.longitude,
    this.importance,
  })  : assert(description != null),
        assert(latitude != null),
        assert(longitude != null);

  static const String _Description = 'description';
  static const String _Latitude = 'latitude';
  static const String _Longitude = 'longitude';
  static const String _Importance = 'importance';

  final String description;
  final double latitude;
  final double longitude;
  final num importance;

  int tempLevenshteinDistance = 100;

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
      importance: json['importance'],
    );
  }

  factory TrufiLocation.fromPlanLocation(PlanLocation value) {
    return TrufiLocation(
      description: value.name,
      latitude: value.latitude,
      longitude: value.longitude,
    );
  }

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return TrufiLocation(
      description: json[_Description],
      latitude: json[_Latitude],
      longitude: json[_Longitude],
      importance: json[_Importance],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      _Description: description,
      _Latitude: latitude,
      _Longitude: longitude,
      _Importance: importance,
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
          itineraries: planJson[_Itineraries]
              .map<PlanItinerary>(
                (itineraryJson) => PlanItinerary.fromJson(itineraryJson),
              )
              .toList());
    }
  }

  factory Plan.fromError(String error) {
    return Plan(error: PlanError.fromError(error));
  }

  factory Plan.fromRoutingResult(final RoutingResult result) {
    final itineraries = List<PlanItinerary>();
    result.simpleRoutes.forEach((simpleRoute) {
      itineraries.add(PlanItinerary.fromSimpleRoute(simpleRoute));
    });
    result.complexRoutes.values.forEach((complexRouteGroup) {
      itineraries.add(PlanItinerary.fromComplexRouteGroup(complexRouteGroup));
    });
    return Plan(
      from: PlanLocation.fromPoint(result.origin, "Origin"),
      to: PlanLocation.fromPoint(result.destination, "Destination"),
      itineraries: itineraries,
    );
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

  factory PlanLocation.fromPoint(Point point, String name) {
    return PlanLocation(
      name: name,
      latitude: point.lat,
      longitude: point.lng,
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
  PlanItinerary({
    this.legs,
  });

  static const String _Legs = "legs";

  final List<PlanItineraryLeg> legs;

  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return PlanItinerary(
        legs: json[_Legs].map<PlanItineraryLeg>((json) {
      return PlanItineraryLeg.fromJson(json);
    }).toList());
  }

  factory PlanItinerary.fromSimpleRoute(SimpleRoute simpleRoute) {
    return PlanItinerary(
      legs: [PlanItineraryLeg.fromSimpleRoute(simpleRoute)],
    );
  }

  factory PlanItinerary.fromComplexRouteGroup(ComplexRouteGroup group) {
    final legs = List<PlanItineraryLeg>();
    group.transfers.forEach((complexRoute) {
      legs.add(PlanItineraryLeg.fromComplexRoute(complexRoute));
    });
    return PlanItinerary(
      legs: legs,
    );
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

  factory PlanItineraryLeg.fromSimpleRoute(SimpleRoute simpleRoute) {
    final polyline = List<LatLng>();
    simpleRoute.points.forEach((point) {
      polyline.add(LatLng(point.lat, point.lng));
    });
    return PlanItineraryLeg(
      points: encodePolyline(polyline),
      mode: "BUS",
      route: simpleRoute.from.route.name,
      routeLongName: "",
      distance: simpleRoute.distance,
      duration: 0,
      toName: simpleRoute.to.route.name,
    );
  }

  factory PlanItineraryLeg.fromComplexRoute(ComplexRoute complexRoute) {
    final polyline = List<LatLng>();
    complexRoute.pointsA.forEach((point) {
      polyline.add(LatLng(point.lat, point.lng));
    });
    complexRoute.pointsB.forEach((point) {
      polyline.add(LatLng(point.lat, point.lng));
    });
    return PlanItineraryLeg(
      points: encodePolyline(polyline),
      mode: "BUS",
      route: complexRoute.from.route.name,
      routeLongName: "",
      distance: complexRoute.distance,
      duration: 0,
      toName: complexRoute.to.route.name,
    );
  }

  String toInstructionQuechua(TrufiLocalizations localizations) {
    StringBuffer sb = StringBuffer();
    if (mode == 'WALK') {
      sb.write(
        "${localizations.instructionWalkStart} ${_durationString(localizations)} (${_distanceString(localizations)}) ${localizations.instructionTo} ${_toString(localizations)} ${localizations.instructionWalk}",
      );
    } else if (mode == 'BUS') {
      sb.write(
        "${_carTypeString(localizations)} #$route ${localizations.instructionRide} ${_distanceString(localizations)} - ${_toString(localizations)} ${localizations.instructionFor} (${_durationString(localizations)})",
      );
    }
    return sb.toString();
  }

  String toInstruction(TrufiLocalizations localizations) {
    StringBuffer sb = StringBuffer();
    if (mode == 'WALK') {
      sb.write("${localizations.instructionWalk}");
    } else if (mode == 'BUS') {
      sb.write(
        "${localizations.instructionRide} ${_carTypeString(localizations)} #$route ${localizations.instructionFor}",
      );
    }
    sb.write(
      " ${_durationString(localizations)} (${_distanceString(localizations)}) ${localizations.instructionTo}\n${_toString(localizations)}",
    );
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

  String _carTypeString(TrufiLocalizations localizations) {
    String carType = routeLongName?.toLowerCase() ?? "";
    return carType.contains('trufi')
        ? localizations.instructionRideTrufi
        : carType.contains('micro')
            ? localizations.instructionRideMicro
            : carType.contains('minibus')
                ? localizations.instructionRideMinibus
                : localizations.instructionRideBus;
  }

  String _distanceString(TrufiLocalizations localizations) {
    return distance >= 1000
        ? "${(distance.ceil() ~/ 1000)} ${localizations.instructionUnitKm}"
        : "${distance.ceil()} ${localizations.instructionUnitMeter}";
  }

  String _durationString(TrufiLocalizations localizations) {
    return "${(duration.ceil() / 60).ceil()} ${localizations.instructionMinutes}";
  }

  String _toString(TrufiLocalizations localizations) {
    return toName == 'Destination' ? localizations.commonDestination : toName;
  }

  IconData iconData() {
    String carType = routeLongName?.toLowerCase() ?? "";
    return mode == 'WALK'
        ? Icons.directions_walk
        : carType.contains('trufi')
            ? Icons.local_taxi
            : carType.contains('micro')
                ? Icons.directions_bus
                : carType.contains('minibus')
                    ? Icons.airport_shuttle
                    : Icons.directions_bus;
  }
}
