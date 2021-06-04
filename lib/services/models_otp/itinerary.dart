import 'fare.dart';
import 'leg.dart';

class Itinerary {
  final double startTime;
  final double endTime;
  final double duration;
  final int generalizedCost;
  final double waitingTime;
  final double walkTime;
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

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
        startTime: double.tryParse(json['startTime'].toString()) ?? 0,
        endTime: double.tryParse(json['endTime'].toString()) ?? 0,
        duration: double.tryParse(json['duration'].toString()) ?? 0,
        generalizedCost: int.tryParse(json['generalizedCost'].toString()) ?? 0,
        waitingTime: double.tryParse(json['waitingTime'].toString()) ?? 0,
        walkTime: double.tryParse(json['walkTime'].toString()) ?? 0,
        walkDistance: double.tryParse(json['walkDistance'].toString()) ?? 0,
        legs: json['legs'] != null
            ? List<Leg>.from((json["legs"] as List<dynamic>).map(
                (x) => Leg.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        fares: json['fares'] != null
            ? List<Fare>.from((json["fares"] as List<dynamic>).map(
                (x) => Fare.fromJson(x as Map<String, dynamic>),
              ))
            : null,
        elevationGained:
            double.tryParse(json['elevationGained'].toString()) ?? 0,
        elevationLost: double.tryParse(json['elevationLost'].toString()) ?? 0,
        arrivedAtDestinationWithRentedBicycle:
            json['arrivedAtDestinationWithRentedBicycle'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration,
        'generalizedCost': generalizedCost,
        'waitingTime': waitingTime,
        'walkTime': walkTime,
        'walkDistance': walkDistance,
        'legs': List<dynamic>.from(legs.map((x) => x.toJson())),
        'fares': List<dynamic>.from(fares.map((x) => x.toJson())),
        'elevationGained': elevationGained,
        'elevationLost': elevationLost,
        'arrivedAtDestinationWithRentedBicycle':
            arrivedAtDestinationWithRentedBicycle,
      };
}
