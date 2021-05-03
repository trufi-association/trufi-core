part of 'plan_entity.dart';

class PlanItinerary {
  static const String _legs = "legs";

  static int _distanceForLegs(List<PlanItineraryLeg> legs) =>
      legs.fold<int>(0, (distance, leg) => distance += leg.distance.ceil());

  static int _timeForLegs(List<PlanItineraryLeg> legs) => legs.fold<int>(
      0, (time, leg) => time += (leg.duration.ceil() / 60).ceil());

  PlanItinerary({
    this.legs,
  })  : distance = _distanceForLegs(legs),
        time = _timeForLegs(legs);

  final List<PlanItineraryLeg> legs;
  final int distance;
  final int time;

  factory PlanItinerary.fromJson(Map<String, dynamic> json) {
    return PlanItinerary(
      legs: json[_legs].map<PlanItineraryLeg>((dynamic json) {
        return PlanItineraryLeg.fromJson(json as Map<String, dynamic>);
      }).toList() as List<PlanItineraryLeg>,
    );
  }

  Map<String, dynamic> toJson() {
    return {_legs: legs.map((itinerary) => itinerary.toJson()).toList()};
  }
}