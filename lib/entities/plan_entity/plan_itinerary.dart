part of 'plan_entity.dart';

class PlanItinerary {
  static const String _legs = "legs";
  static const String _startTime = "startTime";
  static const String _endTime = "endTime";
  static const String _walkTime = "walkTime";
  static const String _durationTrip = "durationTrip";
  static const String _walkDistance = "walkDistance";

  static int _distanceForLegs(List<PlanItineraryLeg> legs) =>
      legs.fold<int>(0, (distance, leg) => distance += leg.distance.ceil());

  static int _timeForLegs(List<PlanItineraryLeg> legs) =>
      (legs.fold<double>(0, (time, leg) => time += leg.duration) / 60).ceil();

  PlanItinerary({
    this.legs,
    this.startTime,
    this.endTime,
    this.walkTime,
    this.durationTrip,
    this.walkDistance,
  })  : distance = _distanceForLegs(legs),
        time = _timeForLegs(legs);

  final List<PlanItineraryLeg> legs;
  final DateTime startTime;
  final DateTime endTime;
  final Duration walkTime;
  final Duration durationTrip;
  final double walkDistance;
  final int distance;
  final int time;

  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return PlanItinerary(
        legs: json[_legs].map<PlanItineraryLeg>((dynamic json) {
          return PlanItineraryLeg.fromJson(json as Map<String, dynamic>);
        }).toList() as List<PlanItineraryLeg>,
        startTime: json[_startTime] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.tryParse(json[_startTime].toString()) ?? 0)
            : null,
        endTime: json[_endTime] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                int.tryParse(json[_endTime].toString()) ?? 0)
            : null,
        walkTime: json[_walkTime] != null
            ? Duration(seconds: json[_walkTime] as int)
            : null,
        durationTrip: json[_durationTrip] != null
            ? Duration(seconds: json[_durationTrip] as int)
            : null,
        walkDistance: double.tryParse(json[_walkDistance].toString()) ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      _legs: legs.map((itinerary) => itinerary.toJson()).toList(),
      _startTime: startTime?.millisecondsSinceEpoch,
      _endTime: endTime?.millisecondsSinceEpoch,
      _walkTime: walkTime?.inSeconds,
      _durationTrip: durationTrip?.inSeconds,
      _walkDistance: walkDistance
    };
  }

  bool get hasAdvencedData =>
      startTime != null &&
      endTime != null &&
      walkTime != null &&
      durationTrip != null &&
      walkDistance != null;

  String get startTimeHHmm => DateFormat(' HH:mm').format(startTime);

  String startTimeComplete(String languageCode) {
    return DateFormat('E dd.MM.  HH:mm', languageCode).format(startTime);
  }

  String get endTimeHHmm => DateFormat('HH:mm').format(endTime);

  String durationTripString(TrufiLocalization localization) =>
      parseDurationTime(localization, durationTrip);

  String walkTimeHHmm(TrufiLocalization localization) =>
      parseDurationTime(localization, walkTime);

  String getDistanceString(TrufiLocalization localization) =>
      getDistance(localization, distance.toDouble());

  String getWalkDistanceString(TrufiLocalization localization) =>
      getDistance(localization, walkDistance.toDouble());
}
