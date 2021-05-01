import 'package:flutter/material.dart';
import 'package:trufi_core/trufi_models.dart';

enum TransportMode { walk, rail, bus, transit, car }

extension TransportModeExtension on TransportMode {
  static const names = {
    TransportMode.walk: 'WALK',
    TransportMode.bus: 'BUS',
    TransportMode.car: 'CAR',
    TransportMode.rail: 'LIGHT RAIL',
    TransportMode.transit: 'TRANSIT',
  };
  String get name => names[this] ?? 'WALK';
}

const transportModeMap= {
  'WALK': TransportMode.walk,
  'BUS': TransportMode.bus,
  'CAR': TransportMode.car,
  'RAIL': TransportMode.rail,
  'TRANSIT': TransportMode.transit,
};

TransportMode _getTransportMode(String enumText) 
  => transportModeMap[enumText] ?? TransportMode.walk;

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
        from: _Location.fromJson(json["from"] as Map<String, dynamic>),
        to: _Location.fromJson(json["to"] as Map<String, dynamic>),
        itineraries: List<_Itinerary>.from(
          (json["itineraries"] as List<dynamic>).map(
            (x) => _Itinerary.fromJson(x as Map<String, dynamic>),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "from": from.toJson(),
        "to": to.toJson(),
        "itineraries": List<dynamic>.from(itineraries.map((x) => x.toJson())),
      };

  Plan toPlan() {
    return Plan(
      to: to.toPlanLocation(),
      from: from.toPlanLocation(),
      itineraries: itineraries
          .map(
            (itinerary) => itinerary.toPlanItinerary(),
          )
          .toList(),
      error: itineraries.isEmpty ? PlanError(404, 'Not found routes') : null,
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
}

class _Itinerary {
  _Itinerary({
    this.legs,
  });

  final List<_ItineraryLeg> legs;

  factory _Itinerary.fromJson(Map<String, dynamic> json) => _Itinerary(
        legs: List<_ItineraryLeg>.from(
          (json["legs"] as List<dynamic>).map(
            (x) => _ItineraryLeg.fromJson(x as Map<String, dynamic>),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
      };

  PlanItinerary toPlanItinerary() {
    return PlanItinerary(
      legs: legs.map((itineraryLeg) => itineraryLeg.toPlanItineraryLeg()).toList(),
    );
  }
}

class _ItineraryLeg {
  _ItineraryLeg({
    @required this.distance,
    @required this.duration,
    @required this.agencyName,
    @required this.mode,
    @required this.route,
    @required this.from,
    @required this.to,
    @required this.legGeometry,
  });

  final double distance;
  final double duration;
  final String agencyName;
  final TransportMode mode;
  final _Route route;
  final _Location from;
  final _Location to;
  final _LegGeometry legGeometry;

  factory _ItineraryLeg.fromJson(Map<String, dynamic> json) => _ItineraryLeg(
        distance: json["distance"] as double,
        duration: json["duration"] as double,
        agencyName: (json["agency"] != null) ? json["agency"]["name"] as String : '',
        mode: _getTransportMode(json["mode"] as String),
        route: json["route"] == null
            ? _Route(url: '')
            : _Route.fromJson(json["route"] as Map<String, dynamic>),
        from: _Location.fromJson(json["from"] as Map<String, dynamic>),
        to: _Location.fromJson(json["to"] as Map<String, dynamic>),
        legGeometry: _LegGeometry.fromJson(json["legGeometry"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "distance": distance,
        "duration": duration,
        "mode": mode.name,
        "route": route.toJson(),
        "from": from.toJson(),
        "to": to.toJson(),
        "legGeometry": legGeometry.toJson(),
      };

  PlanItineraryLeg toPlanItineraryLeg() {
    return PlanItineraryLeg(
      points: legGeometry.points,
      mode: mode.name,
      route: agencyName,
      distance: distance,
      duration: duration,
      routeLongName: mode.name,
      toName: to.name,
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
  });

  final dynamic url;

  factory _Route.fromJson(Map<String, dynamic> json) => _Route(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}
