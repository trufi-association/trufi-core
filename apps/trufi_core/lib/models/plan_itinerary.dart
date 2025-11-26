part of 'plan_entity.dart';

class PlanItinerary {
  static int _distanceForLegs(List<PlanItineraryLeg> legs) =>
      legs.fold<int>(0, (distance, leg) => distance += leg.distance.ceil());

  PlanItinerary({
    this.legs = const [],
    required this.startTime,
    required this.endTime,
    required this.walkTime,
    required this.duration,
    required this.walkDistance,
    required this.arrivedAtDestinationWithRentedBicycle,
    this.isOnlyShowItinerary = false,
    required this.emissionsPerPerson,
    this.isMinorEmissionsPerPerson = false,
  }) : distance = _distanceForLegs(legs);

  static const String _legs = "legs";
  static const String _startTime = "startTime";
  static const String _endTime = "endTime";
  static const String _walkTime = "walkTime";
  static const String _durationTrip = "duration";
  static const String _walkDistance = "walkDistance";
  static const String _arrivedAtDestinationWithRentedBicycle =
      "arrivedAtDestinationWithRentedBicycle";
  static const String _emissionsPerPerson = "emissionsPerPerson";
  static const String _emissionsPerPersonCo2 = "emissionsPerPersonCo2";

  final List<PlanItineraryLeg> legs;
  final DateTime startTime;
  final DateTime endTime;
  final Duration walkTime;
  final Duration duration;
  final double walkDistance;
  final bool arrivedAtDestinationWithRentedBicycle;
  final bool isOnlyShowItinerary;
  final double? emissionsPerPerson;
  final bool isMinorEmissionsPerPerson;

  final int distance;
  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return PlanItinerary(
      legs:
          json[_legs].map<PlanItineraryLeg>((dynamic json) {
                return PlanItineraryLeg.fromJson(json as Map<String, dynamic>);
              }).toList()
              as List<PlanItineraryLeg>,
      startTime: DateTime.fromMillisecondsSinceEpoch(json[_startTime]),
      endTime: DateTime.fromMillisecondsSinceEpoch(json[_endTime]),
      walkTime: Duration(seconds: json[_walkTime]),
      duration: Duration(seconds: json[_durationTrip]),
      walkDistance: json[_walkDistance],
      arrivedAtDestinationWithRentedBicycle:
          json[_arrivedAtDestinationWithRentedBicycle],
      emissionsPerPerson: json[_emissionsPerPerson]?[_emissionsPerPersonCo2],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _legs: legs.map((itinerary) => itinerary.toJson()).toList(),
      _startTime: startTime.millisecondsSinceEpoch,
      _endTime: endTime.millisecondsSinceEpoch,
      _walkTime: walkTime.inSeconds,
      _durationTrip: duration.inSeconds,
      _walkDistance: walkDistance,
      _arrivedAtDestinationWithRentedBicycle:
          arrivedAtDestinationWithRentedBicycle,
      _emissionsPerPerson: {_emissionsPerPersonCo2: emissionsPerPerson},
    };
  }

  String getFirstLegDepartureMessage() {
    final firstTransport = getFirstDeparture;
    String legStartTime = '';
    if (firstTransport != null) {
      final String firstDepartureStopType =
          firstTransport.transportMode == TransportMode.rail ||
              firstTransport.transportMode == TransportMode.subway
          ? "from station"
          : "from stop";
      legStartTime =
          "Leaves $firstDepartureStopType ${firstTransport.fromPlace?.name ?? ''}";
    } else {
      legStartTime = "Leave when it suits you";
    }

    return legStartTime;
  }

  PlanItineraryLeg? get getFirstDeparture {
    final firstDeparture = legs.firstWhereOrNull(
      (element) => element.transitLeg,
    );
    return firstDeparture;
  }
}
