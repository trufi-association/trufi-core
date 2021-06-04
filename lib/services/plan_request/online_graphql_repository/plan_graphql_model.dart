import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/place_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/stop_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class ModesTransport {
  final PlanGraphQl walkPlan;
  final PlanGraphQl bikePlan;
  final PlanGraphQl bikeAndPublicPlan;
  final PlanGraphQl bikeParkPlan;
  final PlanGraphQl carPlan;
  final PlanGraphQl parkRidePlan;

  ModesTransport({
    this.walkPlan,
    this.bikePlan,
    this.bikeAndPublicPlan,
    this.bikeParkPlan,
    this.carPlan,
    this.parkRidePlan,
  });

  factory ModesTransport.fromJson(Map<String, dynamic> json) => ModesTransport(
        walkPlan: json["walkPlan"] != null
            ? PlanGraphQl.fromJson(json["walkPlan"] as Map<String, dynamic>)
            : null,
        bikePlan: json["bikePlan"] != null
            ? PlanGraphQl.fromJson(json["bikePlan"] as Map<String, dynamic>)
            : null,
        bikeAndPublicPlan: json["bikeAndPublicPlan"] != null
            ? PlanGraphQl.fromJson(
                json["bikeAndPublicPlan"] as Map<String, dynamic>)
            : null,
        bikeParkPlan: json["bikeParkPlan"] != null
            ? PlanGraphQl.fromJson(json["bikeParkPlan"] as Map<String, dynamic>)
            : null,
        carPlan: json["carPlan"] != null
            ? PlanGraphQl.fromJson(json["carPlan"] as Map<String, dynamic>)
            : null,
        parkRidePlan: json["parkRidePlan"] != null
            ? PlanGraphQl.fromJson(json["parkRidePlan"] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'walkPlan': walkPlan?.toJson(),
        'bikePlan': bikePlan?.toJson(),
        'bikeAndPublicPlan': bikeAndPublicPlan?.toJson(),
        'bikeParkPlan': bikeParkPlan?.toJson(),
        'carPlan': carPlan?.toJson(),
        'parkRidePlan': parkRidePlan?.toJson(),
      };

  ModesTransportEntity toModesTransport() {
    return ModesTransportEntity(
      walkPlan: walkPlan?.toPlan(),
      bikePlan: bikePlan?.toPlan(),
      bikeAndPublicPlan: bikeAndPublicPlan?.toPlan(),
      bikeParkPlan: bikeParkPlan?.toPlan(),
      carPlan: carPlan?.toPlan(),
      parkRidePlan: parkRidePlan?.toPlan(),
    );
  }
}

class PlanGraphQl {
  PlanGraphQl({
    this.from,
    this.to,
    this.itineraries,
  });

  final _Location from;
  final _Location to;
  final List<_Itinerary> itineraries;

  factory PlanGraphQl.fromJson(Map<String, dynamic> json) => PlanGraphQl(
        from: json["from"] != null
            ? _Location.fromJson(json["from"] as Map<String, dynamic>)
            : null,
        to: json["to"] != null
            ? _Location.fromJson(json["to"] as Map<String, dynamic>)
            : null,
        itineraries: json["itineraries"] != null
            ? List<_Itinerary>.from(
                (json["itineraries"] as List<dynamic>).map(
                  (x) => _Itinerary.fromJson(x as Map<String, dynamic>),
                ),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        "from": from.toJson(),
        "to": to.toJson(),
        "itineraries": List<dynamic>.from(itineraries.map((x) => x.toJson())),
      };

  PlanGraphQl copyWith({
    _Location from,
    _Location to,
    List<_Itinerary> itineraries,
  }) {
    return PlanGraphQl(
      from: from ?? this.from,
      to: to ?? this.to,
      itineraries: itineraries ?? this.itineraries,
    );
  }

  PlanEntity toPlan() {
    return PlanEntity(
      to: to.toPlanLocation(),
      from: from.toPlanLocation(),
      itineraries: itineraries
          .map(
            (itinerary) => itinerary.toPlanItinerary(),
          )
          .toList(),
      error: itineraries.isEmpty ? PlanError(404, "Not found routes") : null,
    );
  }
}

class _Location {
  _Location({
    this.name,
    this.lon,
    this.lat,
  });

  final String name;
  final double lon;
  final double lat;

  factory _Location.fromJson(Map<String, dynamic> json) => _Location(
        name: json["name"] as String,
        lon: json["lon"] as double,
        lat: json["lat"] as double,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "lon": lon,
        "lat": lat,
      };
  PlanLocation toPlanLocation() {
    return PlanLocation(
      name: name,
      longitude: lon,
      latitude: lat,
    );
  }

  PlaceEntity toPlaceEntity() {
    return PlaceEntity(
      name: name,
      lat: lat,
      lon: lon,
    );
  }
}

class _Itinerary {
  _Itinerary({
    this.legs,
    this.startTime,
    this.endTime,
    this.duration,
    this.walkTime,
    this.walkDistance,
  });

  final List<_ItineraryLeg> legs;
  final int startTime;
  final int endTime;
  final int duration;
  final int walkTime;
  final double walkDistance;

  factory _Itinerary.fromJson(Map<String, dynamic> json) => _Itinerary(
        legs: List<_ItineraryLeg>.from(
          (json["legs"] as List<dynamic>).map(
            (x) => _ItineraryLeg.fromJson(x as Map<String, dynamic>),
          ),
        ),
        startTime: int.tryParse(json["startTime"].toString()) ?? 0,
        endTime: int.tryParse(json["endTime"].toString()) ?? 0,
        duration: int.tryParse(json["duration"].toString()) ?? 0,
        walkTime: int.tryParse(json["walkTime"].toString()) ?? 0,
        walkDistance: double.tryParse(json["walkDistance"].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
        "startTime": startTime,
        "endTime": endTime,
        "duration": duration,
        "walkTime": walkTime,
        "walkDistance": walkDistance,
      };

  PlanItinerary toPlanItinerary() {
    return PlanItinerary(
      legs: legs
          .map((itineraryLeg) => itineraryLeg.toPlanItineraryLeg())
          .toList(),
      startTime: startTime != null
          ? DateTime.fromMillisecondsSinceEpoch(startTime)
          : null,
      endTime:
          endTime != null ? DateTime.fromMillisecondsSinceEpoch(endTime) : null,
      durationTrip: duration != null ? Duration(seconds: duration) : null,
      walkDistance: walkDistance,
      walkTime: walkTime != null ? Duration(seconds: walkTime) : null,
    );
  }
}

class _ItineraryLeg {
  _ItineraryLeg({
    @required this.distance,
    @required this.duration,
    @required this.agencyName,
    @required this.startTime,
    @required this.endTime,
    @required this.mode,
    @required this.route,
    @required this.from,
    @required this.to,
    @required this.legGeometry,
    @required this.intermediatePlaces,
  });

  final double distance;
  final double duration;
  final String agencyName;
  final int startTime;
  final int endTime;

  final TransportMode mode;
  final _Route route;
  final _Location from;
  final _Location to;
  final _LegGeometry legGeometry;
  final List<Place> intermediatePlaces;

  factory _ItineraryLeg.fromJson(Map<String, dynamic> json) => _ItineraryLeg(
        distance: json["distance"] as double,
        duration: json["duration"] as double,
        agencyName:
            (json["agency"] != null) ? json["agency"]["name"] as String : '',
        startTime: int.tryParse(json["startTime"].toString()) ?? 0,
        endTime: int.tryParse(json["endTime"].toString()) ?? 0,
        mode: getTransportMode(mode: json["mode"] as String),
        route: json["route"] == null
            ? _Route(url: '', routeShortName: '', routeLongName: '')
            : _Route.fromJson(json["route"] as Map<String, dynamic>),
        from: _Location.fromJson(json["from"] as Map<String, dynamic>),
        to: _Location.fromJson(json["to"] as Map<String, dynamic>),
        legGeometry:
            _LegGeometry.fromJson(json["legGeometry"] as Map<String, dynamic>),
        intermediatePlaces: json["intermediatePlaces"] != null
            ? List<Place>.from(
                (json["intermediatePlaces"] as List<dynamic>).map(
                  (x) => Place.fromJson(x as Map<String, dynamic>),
                ),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        "distance": distance,
        "duration": duration,
        "startTime": startTime,
        "endTime": endTime,
        "mode": mode.name,
        "route": route.toJson(),
        "from": from.toJson(),
        "to": to.toJson(),
        "legGeometry": legGeometry.toJson(),
        "intermediatePlaces": intermediatePlaces != null
            ? List<dynamic>.from(intermediatePlaces.map((x) => x.toJson()))
            : null,
      };

  PlanItineraryLeg toPlanItineraryLeg() {
    return PlanItineraryLeg(
      points: legGeometry.points,
      mode: mode.name,
      route: route.routeShortName,
      startTime: startTime != null
          ? DateTime.fromMillisecondsSinceEpoch(startTime)
          : null,
      endTime:
          endTime != null ? DateTime.fromMillisecondsSinceEpoch(endTime) : null,
      distance: distance,
      duration: duration,
      routeLongName: route.routeLongName,
      toPlace: to.toPlaceEntity(),
      fromPlace: from.toPlaceEntity(),
      // ignore: prefer_null_aware_operators
      intermediatePlaces: intermediatePlaces != null
          ? intermediatePlaces.map((x) => x.toPlaceEntity()).toList()
          : null,
    );
  }
}

class _LegGeometry {
  _LegGeometry({
    this.points,
    this.length,
  });

  final String points;
  final int length;

  factory _LegGeometry.fromJson(Map<String, dynamic> json) => _LegGeometry(
        points: json["points"] as String,
        length: json["length"] as int,
      );

  Map<String, dynamic> toJson() => {
        "points": points,
        "length": length,
      };
}

class _Route {
  _Route({
    @required this.url,
    @required this.routeShortName,
    @required this.routeLongName,
  });

  final String url;
  final String routeShortName;
  final String routeLongName;

  factory _Route.fromJson(Map<String, dynamic> json) => _Route(
        url: json["url"] as String,
        routeShortName: json["shortName"] as String,
        routeLongName: json["longName"] as String,
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "shortName": url,
        "longName": url,
      };
}

class Place {
  final int arrivalTime;
  final Stop stop;

  const Place({
    this.arrivalTime,
    this.stop,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        arrivalTime: int.tryParse(json["arrivalTime"].toString()) ?? 0,
        stop: json['stop'] != null
            ? Stop.fromJson(json['stop'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'arrivalTime': arrivalTime,
        'stop': stop?.toJson(),
      };

  PlaceEntity toPlaceEntity() {
    return PlaceEntity(
      arrivalTime: arrivalTime != null
          ? DateTime.fromMillisecondsSinceEpoch(arrivalTime)
          : null,
      stopEntity: stop?.toPlaceEntity(),
    );
  }
}

class Stop {
  final String gtfsId;
  final double lat;
  final double lon;
  final String name;
  final String code;
  final String platformCode;
  final String zoneId;
  final String id;

  const Stop({
    this.gtfsId,
    this.lat,
    this.lon,
    this.name,
    this.code,
    this.platformCode,
    this.zoneId,
    this.id,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        id: json['id'] as String,
        gtfsId: json['gtfsId'] as String,
        name: json['name'] as String,
        lat: double.tryParse(json['lat'].toString()) ?? 0,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
        code: json['code'] as String,
        zoneId: json['zoneId'] as String,
        platformCode: json['platformCode'] as String,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "gtfsId": gtfsId,
        "name": name,
        "lat": lat,
        "lon": lon,
        "code": code,
        "zoneId": zoneId,
        "platformCode": platformCode,
      };

  StopEntity toPlaceEntity() {
    return StopEntity(
        id: id,
        gtfsId: gtfsId,
        lat: lat,
        name: name,
        code: code,
        platformCode: platformCode,
        zoneId: zoneId);
  }
}
