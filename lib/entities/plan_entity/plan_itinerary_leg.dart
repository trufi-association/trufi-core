part of 'plan_entity.dart';

class PlanItineraryLeg {
  PlanItineraryLeg({
    this.points,
    this.mode,
    this.route,
    this.routeLongName,
    this.distance,
    this.duration,
    this.toName,
  }) {
    transportMode =
        getTransportMode(mode: mode, specificTransport: routeLongName);
  }

  static const _distance = "distance";
  static const _duration = "duration";
  static const _legGeometry = "legGeometry";
  static const _points = "points";
  static const _mode = "mode";
  static const _name = "name";
  static const _route = "route";
  static const _routeLongName = "routeLongName";
  static const _to = "to";

  final String points;
  final String mode;
  final String route;
  final String routeLongName;
  final double distance;
  final double duration;
  final String toName;
  TransportMode transportMode;

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

  String toInstruction(TrufiLocalization localization) {
    final StringBuffer sb = StringBuffer();
    if (transportMode == TransportMode.walk) {
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

  String _carTypeString(TrufiLocalization localization) {
    String carType = "";
    switch (transportMode) {
      case TransportMode.airplane:
        // TODO translate
        carType = localization.instructionVehicleBus;
        break;
      // TODO translate
      case TransportMode.bicycle:
        carType = localization.instructionVehicleBus;
        break;
      case TransportMode.bus:
        carType = localization.instructionVehicleBus;
        break;
      case TransportMode.cableCar:
        carType = localization.instructionVehicleGondola;
        break;
      case TransportMode.car:
        carType = localization.instructionVehicleCar;
        break;
      // TODO translate
      case TransportMode.carPool:
        carType = localization.instructionVehicleCar;
        break;
      // TODO translate
      case TransportMode.ferry:
        carType = localization.instructionVehicleBus;
        break;
      // TODO translate
      case TransportMode.flexible:
        carType = localization.instructionVehicleBus;
        break;
      case TransportMode.funicular:
        carType = localization.instructionVehicleBus;
        break;
      case TransportMode.gondola:
        carType = localization.instructionVehicleGondola;
        break;
      // TODO translate
      case TransportMode.legSwitch:
        carType = localization.instructionVehicleBus;
        break;
      case TransportMode.rail:
        carType = localization.instructionVehicleLightRail;
        break;
      // TODO translate
      case TransportMode.subway:
        carType = localization.instructionVehicleLightRail;
        break;
      // TODO translate
      case TransportMode.tram:
        carType = localization.instructionVehicleLightRail;
        break;
      case TransportMode.transit:
        carType = localization.instructionVehicleBus;
        break;
      case TransportMode.walk:
        carType = localization.instructionVehicleBus;
        break;
      // route name keywords for specific types of transportation
      case TransportMode.trufi:
        carType = localization.instructionVehicleTrufi;
        break;
      case TransportMode.micro:
        carType = localization.instructionVehicleMicro;
        break;
      case TransportMode.miniBus:
        carType = localization.instructionVehicleMinibus;
        break;
      case TransportMode.lightRail:
        carType = localization.instructionVehicleLightRail;
        break;
      default:
        carType = localization.instructionVehicleBus;
    }
    return carType;
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

  IconData iconData() => transportMode.icon;
}
