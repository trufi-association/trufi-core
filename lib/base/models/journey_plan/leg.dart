part of 'plan.dart';

class Leg extends Equatable {
  static const _distance = "distance";
  static const _duration = "duration";
  static const _legGeometry = "legGeometry";
  static const _points = "points";
  static const _mode = "mode";
  static const _route = "route";
  static const _routeLongName = "routeLongName";
  static const _toPlace = "to";
  static const _fromPlace = "from";
  static const _startTime = "startTime";
  static const _endTime = "endTime";
  static const _intermediatePlaces = "intermediatePlaces";
  static const _transitLeg = "transitLeg";

  final String points;
  final TransportMode transportMode;
  final TransportRoute? route;
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
  final List<LatLng> accumulatedPoints;

  const Leg({
    required this.points,
    required this.transportMode,
    required this.route,
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
      points: json[_legGeometry][_points] as String,
      transportMode: getTransportMode(
        mode: json[_mode] as String,
        specificTransport: json[_routeLongName],
      ),
      route: json[_route] != null
          ? ((json[_route] is Map<String, dynamic>)
              ? TransportRoute.fromJson(json[_route] as Map<String, dynamic>)
              : null)
          : null,
      shortName: json[_route] != null
          ? ((json[_route] is String) && json[_route] != ''
              ? json[_route] as String
              : null)
          : null,
      routeLongName: json[_routeLongName] as String?,
      distance: json[_distance] as double,
      duration: Duration(
          seconds: (double.tryParse(json[_duration].toString()) ?? 0).toInt()),
      toPlace: Place.fromJson(json[_toPlace] as Map<String, dynamic>),
      fromPlace: Place.fromJson(json[_fromPlace] as Map<String, dynamic>),
      startTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json[_startTime].toString()) ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json[_endTime].toString()) ?? 0),
      intermediatePlaces: json[_intermediatePlaces] != null
          ? List<Place>.from(
              (json[_intermediatePlaces] as List<dynamic>).map(
                (x) => Place.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
      transitLeg: json[_transitLeg] as bool,
      accumulatedPoints: decodePolyline(json[_legGeometry][_points] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _legGeometry: {_points: points},
      _mode: transportMode.name,
      _route: route?.toJson() ?? shortName,
      _routeLongName: routeLongName,
      _distance: distance,
      _duration: duration.inSeconds,
      _toPlace: toPlace.toJson(),
      _fromPlace: fromPlace.toJson(),
      _startTime: startTime.millisecondsSinceEpoch,
      _endTime: endTime.millisecondsSinceEpoch,
      _intermediatePlaces:
          intermediatePlaces?.map((itinerary) => itinerary.toJson()).toList(),
      _transitLeg: transitLeg,
    };
  }

  Leg copyWith({
    String? points,
    TransportMode? transportMode,
    TransportRoute? route,
    String? shortName,
    String? routeLongName,
    double? distance,
    Duration? duration,
    Place? toPlace,
    Place? fromPlace,
    DateTime? startTime,
    DateTime? endTime,
    bool? rentedBike,
    bool? intermediatePlace,
    bool? transitLeg,
    bool? interlineWithPreviousLeg,
    List<Place>? intermediatePlaces,
    List<LatLng>? accumulatedPoints,
  }) {
    return Leg(
      points: points ?? this.points,
      transportMode: transportMode ?? this.transportMode,
      route: route ?? this.route,
      shortName: shortName ?? this.shortName,
      routeLongName: routeLongName ?? this.routeLongName,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      toPlace: toPlace ?? this.toPlace,
      fromPlace: fromPlace ?? this.fromPlace,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      transitLeg: transitLeg ?? this.transitLeg,
      intermediatePlaces: intermediatePlaces ?? this.intermediatePlaces,
      accumulatedPoints: accumulatedPoints ?? this.accumulatedPoints,
    );
  }

  String distanceString(TrufiBaseLocalization localization) =>
      distanceWithTranslation(
        localization,
        distance,
      );

  String get startTimeString => durationToHHmm(startTime);

  String get endTimeString => durationToHHmm(endTime);

  String durationLeg(TrufiBaseLocalization localization) =>
      durationFormatString(localization, duration);

  bool get isLegOnFoot => transportMode == TransportMode.walk;

  String get headSign {
    return route?.shortName ?? (route?.longName ?? (shortName ?? ''));
  }

  Color get primaryColor {
    return route?.color != null
        ? Color(int.tryParse('0xFF${route?.color}')!)
        : transportMode.color;
  }

  Color get backgroundColor {
    return route?.color != null
        ? Color(int.tryParse('0xFF${route?.color}')!)
        : transportMode.backgroundColor;
  }

  @override
  List<Object?> get props => [
        points,
        transportMode,
        route,
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
