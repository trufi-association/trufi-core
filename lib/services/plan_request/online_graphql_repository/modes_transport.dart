import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/services/models_otp/enums/mode.dart';
import 'package:trufi_core/services/models_otp/plan.dart';

class ModesTransport {
  final Plan walkPlan;
  final Plan bikePlan;
  final Plan bikeAndPublicPlan;
  final Plan bikeParkPlan;
  final Plan carPlan;
  final Plan parkRidePlan;
  final Plan onDemandTaxiPlan;

  ModesTransport({
    this.walkPlan,
    this.bikePlan,
    this.bikeAndPublicPlan,
    this.bikeParkPlan,
    this.carPlan,
    this.parkRidePlan,
    this.onDemandTaxiPlan,
  });

  factory ModesTransport.fromJson(Map<String, dynamic> json) => ModesTransport(
        walkPlan: json["walkPlan"] != null
            ? Plan.fromMap(json["walkPlan"] as Map<String, dynamic>)
            : null,
        bikePlan: json["bikePlan"] != null
            ? Plan.fromMap(json["bikePlan"] as Map<String, dynamic>)
            : null,
        bikeAndPublicPlan: json["bikeAndPublicPlan"] != null
            ? Plan.fromMap(json["bikeAndPublicPlan"] as Map<String, dynamic>)
            : null,
        bikeParkPlan: json["bikeParkPlan"] != null
            ? Plan.fromMap(json["bikeParkPlan"] as Map<String, dynamic>)
            : null,
        carPlan: json["carPlan"] != null
            ? Plan.fromMap(json["carPlan"] as Map<String, dynamic>)
            : null,
        parkRidePlan: json["parkRidePlan"] != null
            ? Plan.fromMap(json["parkRidePlan"] as Map<String, dynamic>)
            : null,
        onDemandTaxiPlan: json["onDemandTaxiPlan"] != null
            ? Plan.fromMap(json["onDemandTaxiPlan"] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'walkPlan': walkPlan?.toMap(),
        'bikePlan': bikePlan?.toMap(),
        'bikeAndPublicPlan': bikeAndPublicPlan?.toMap(),
        'bikeParkPlan': bikeParkPlan?.toMap(),
        'carPlan': carPlan?.toMap(),
        'parkRidePlan': parkRidePlan?.toMap(),
        'onDemandTaxiPlan': onDemandTaxiPlan?.toMap(),
      };

  ModesTransportEntity toModesTransport() {
    return ModesTransportEntity(
      walkPlan: walkPlan?.toPlan(),
      bikePlan: bikePlan?.toPlan(),
      bikeAndPublicPlan: bikeAndPublicPlan?.toPlan(),
      bikeParkPlan: bikeParkPlan?.toPlan(),
      carPlan: carPlan?.toPlan(),
      parkRidePlan: parkRidePlan?.toPlan(),
      onDemandTaxiPlan: onDemandTaxiPlan?.toPlan()?.copyWith(
          itineraries: onDemandTaxiPlan.itineraries
              .where((itinerary) =>
                  !itinerary.legs.every((leg) => leg.mode == Mode.walk))
              .map((e) => e.toPlanItinerary())
              .toList()),
    );
  }
}
