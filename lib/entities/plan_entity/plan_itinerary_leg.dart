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
    this.fromName,
    this.startTime,
    this.endTime,
    this.intermediatePlaces,
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
  static const _from = "from";
  static const _startTime = "startTime";
  static const _endTime = "endTime";
  static const _intermediatePlaces = "intermediatePlaces";

  final String points;
  final String mode;
  final String route;
  final String routeLongName;
  final double distance;
  final double duration;
  final String toName;
  final String fromName;
  final DateTime startTime;
  final DateTime endTime;
  TransportMode transportMode;

  final List<PlaceEntity> intermediatePlaces;

  factory PlanItineraryLeg.fromJson(Map<String, dynamic> json) {
    return PlanItineraryLeg(
      points: json[_legGeometry][_points] as String,
      mode: json[_mode] as String,
      route: json[_route] as String,
      routeLongName: json[_routeLongName] as String,
      distance: json[_distance] as double,
      duration: json[_duration] as double,
      toName: json[_to][_name] as String,
      fromName: json[_from][_name] as String,
      startTime: json[_startTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(json[_startTime].toString()) ?? 0)
          : null,
      endTime: json[_endTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(json[_endTime].toString()) ?? 0)
          : null,
      intermediatePlaces: json[_intermediatePlaces] != null
          ? List<PlaceEntity>.from(
              (json[_intermediatePlaces] as List<dynamic>).map(
                (x) => PlaceEntity.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
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
      _to: {_name: toName},
      _from: {_name: fromName},
      _startTime: startTime?.millisecondsSinceEpoch,
      _endTime: endTime?.millisecondsSinceEpoch,
      _intermediatePlaces: intermediatePlaces != null
          ? List<dynamic>.from(intermediatePlaces.map((x) => x.toJson()))
          : null,
    };
  }

  String toInstruction(TrufiLocalization localization) {
    final StringBuffer sb = StringBuffer();
    if (transportMode == TransportMode.walk) {
      sb.write(localization.instructionWalk(_durationString(localization),
          distanceString(localization), _toString(localization)));
    } else {
      sb.write(localization.instructionRide(
          transportMode.getTranslate(localization) +
              (route.isNotEmpty ? " $route" : ""),
          _durationString(localization),
          distanceString(localization),
          _toString(localization)));
    }
    return sb.toString();
  }

  String distanceString(TrufiLocalization localization) => getDistance(
        localization,
        distance,
      );

  String _durationString(TrufiLocalization localization) {
    final value = (duration.ceil() / 60).ceil();
    return localization.instructionDurationMinutes(value);
  }

  String get startTimeString => DateFormat('HH:mm').format(startTime);

  String get endTimeString => DateFormat('HH:mm').format(endTime);

  String durationInHours(TrufiLocalization localization) =>
      parseDurationTime(localization, Duration(seconds: duration.toInt()));

  String _toString(TrufiLocalization localization) {
    return toName == 'Destination' ? localization.commonDestination : toName;
  }

  IconData get iconData => transportMode.icon;
}
