part of 'plan_entity.dart';

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