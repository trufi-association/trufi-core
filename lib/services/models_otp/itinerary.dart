import 'package:trufi_core/entities/plan_entity/plan_entity.dart';

import 'fare.dart';
import 'leg.dart';

class Itinerary {
  final int startTime;
  final int endTime;
  final int duration;
  final int generalizedCost;
  final int waitingTime;
  final int walkTime;
  final double walkDistance;
  final List<Leg> legs;
  final List<Fare> fares;
  final double elevationGained;
  final double elevationLost;
  final bool arrivedAtDestinationWithRentedBicycle;

  const Itinerary({
    this.startTime,
    this.endTime,
    this.duration,
    this.generalizedCost,
    this.waitingTime,
    this.walkTime,
    this.walkDistance,
    this.legs,
    this.fares,
    this.elevationGained,
    this.elevationLost,
    this.arrivedAtDestinationWithRentedBicycle,
  });

  factory Itinerary.fromMap(Map<String, dynamic> json) => Itinerary(
        startTime: int.tryParse(json['startTime'].toString()),
        endTime: int.tryParse(json['endTime'].toString()),
        duration: int.tryParse(json['duration'].toString()),
        generalizedCost: int.tryParse(json['generalizedCost'].toString()),
        waitingTime: int.tryParse(json['waitingTime'].toString()),
        walkTime: int.tryParse(json['walkTime'].toString()),
        walkDistance: double.tryParse(json['walkDistance'].toString()),
        legs: json['legs'] != null
            ? List<Leg>.from((json["legs"] as List<dynamic>).map(
                (x) => Leg.fromMap(x as Map<String, dynamic>),
              ))
            : null,
        fares: json['fares'] != null
            ? List<Fare>.from((json["fares"] as List<dynamic>).map(
                (x) => Fare.fromMap(x as Map<String, dynamic>),
              ))
            : null,
        elevationGained: double.tryParse(json['elevationGained'].toString()),
        elevationLost: double.tryParse(json['elevationLost'].toString()),
        arrivedAtDestinationWithRentedBicycle:
            json['arrivedAtDestinationWithRentedBicycle'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration,
        'generalizedCost': generalizedCost,
        'waitingTime': waitingTime,
        'walkTime': walkTime,
        'walkDistance': walkDistance,
        'legs': legs != null
            ? List<dynamic>.from(legs.map((x) => x.toMap()))
            : null,
        'fares': fares != null
            ? List<dynamic>.from(fares.map((x) => x.toMap()))
            : null,
        'elevationGained': elevationGained,
        'elevationLost': elevationLost,
        'arrivedAtDestinationWithRentedBicycle':
            arrivedAtDestinationWithRentedBicycle,
      };

  PlanItinerary toPlanItinerary() {
    return PlanItinerary(
        legs: legs
            ?.map((itineraryLeg) => itineraryLeg.toPlanItineraryLeg())
            ?.toList(),
        startTime: startTime != null
            ? DateTime.fromMillisecondsSinceEpoch(startTime)
            : null,
        endTime: endTime != null
            ? DateTime.fromMillisecondsSinceEpoch(endTime)
            : null,
        durationTrip: duration != null ? Duration(seconds: duration) : null,
        walkDistance: walkDistance,
        walkTime: walkTime != null ? Duration(seconds: walkTime) : null,
        arrivedAtDestinationWithRentedBicycle:
            arrivedAtDestinationWithRentedBicycle);
  }
}
