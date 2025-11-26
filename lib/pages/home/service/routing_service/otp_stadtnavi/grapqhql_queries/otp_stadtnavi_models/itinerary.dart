import 'package:trufi_core/models/plan_entity.dart';
import 'fare.dart';
import 'leg.dart';

class Itinerary {
  final int? startTime;
  final int? endTime;
  final int? duration;
  final int? generalizedCost;
  final int? waitingTime;
  final int? walkTime;
  final double? walkDistance;
  final List<Leg>? legs;
  final List<Fare>? fares;
  final double? elevationGained;
  final double? elevationLost;
  final bool? arrivedAtDestinationWithRentedBicycle;
  final double? emissionsPerPerson;

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
    this.emissionsPerPerson,
  });

  factory Itinerary.fromMap(Map<String, dynamic> json) {
    return Itinerary(
      startTime: int.tryParse(json['startTime'].toString()),
      endTime: int.tryParse(json['endTime'].toString()),
      duration: int.tryParse(json['duration'].toString()),
      generalizedCost: int.tryParse(json['generalizedCost'].toString()),
      waitingTime: int.tryParse(json['waitingTime'].toString()),
      walkTime: int.tryParse(json['walkTime'].toString()),
      walkDistance: double.tryParse(json['walkDistance'].toString()),
      legs: json['legs'] != null
          ? List<Leg>.from(
              (json["legs"] as List<dynamic>).map(
                (x) => Leg.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      fares: json['fares'] != null
          ? List<Fare>.from(
              (json["fares"] as List<dynamic>).map(
                (x) => Fare.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      elevationGained: double.tryParse(json['elevationGained'].toString()),
      elevationLost: double.tryParse(json['elevationLost'].toString()),
      arrivedAtDestinationWithRentedBicycle:
          json['arrivedAtDestinationWithRentedBicycle'] as bool?,
      emissionsPerPerson: double.tryParse(
        json['emissionsPerPerson']?["co2"].toString() ?? "",
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'startTime': startTime,
    'endTime': endTime,
    'duration': duration,
    'generalizedCost': generalizedCost,
    'waitingTime': waitingTime,
    'walkTime': walkTime,
    'walkDistance': walkDistance,
    'legs': legs != null
        ? List<dynamic>.from(legs!.map((x) => x.toMap()))
        : null,
    'fares': fares != null
        ? List<dynamic>.from(fares!.map((x) => x.toMap()))
        : null,
    'elevationGained': elevationGained,
    'elevationLost': elevationLost,
    'arrivedAtDestinationWithRentedBicycle':
        arrivedAtDestinationWithRentedBicycle,
    'emissionsPerPerson': emissionsPerPerson,
  };

  PlanItinerary toPlanItinerary() {
    return PlanItinerary(
      legs:
          legs
              ?.map((itineraryLeg) => itineraryLeg.toPlanItineraryLeg())
              .toList() ??
          [],
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime ?? 0),
      duration: Duration(seconds: duration ?? 0),
      walkDistance: walkDistance ?? 0,
      walkTime: Duration(seconds: walkTime ?? 0),
      arrivedAtDestinationWithRentedBicycle:
          arrivedAtDestinationWithRentedBicycle ?? false,
      emissionsPerPerson: emissionsPerPerson,
    );
  }
}
