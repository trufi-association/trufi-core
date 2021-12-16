import 'package:trufi_core/entities/plan_entity/enum/leg_mode.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

import '../plan_entity.dart';

bool continueWithBicycle(PlanItineraryLeg leg1, PlanItineraryLeg leg2) {
  final bool isBicycle1 = leg1.transportMode == TransportMode.bicycle ||
      leg1.transportMode == TransportMode.walk;
  final bool isBicycle2 = leg2.transportMode == TransportMode.bicycle ||
      leg2.transportMode == TransportMode.walk;
  return isBicycle1 && isBicycle2 && leg1.toPlace!.bikeParkEntity == null;
}

bool continueWithRentedBicycle(PlanItineraryLeg leg1, PlanItineraryLeg? leg2) {
  return leg1 != null &&
      leg1.rentedBike == true &&
      leg2 != null &&
      leg2.rentedBike == true &&
      sameBicycleNetwork(leg1, leg2);
}

bool sameBicycleNetwork(PlanItineraryLeg leg1, PlanItineraryLeg leg2) {
  if (leg1.fromPlace?.bikeRentalStation != null &&
      leg2.fromPlace?.bikeRentalStation != null) {
    return leg1.fromPlace!.bikeRentalStation!.networks![0] ==
        leg2.fromPlace!.bikeRentalStation!.networks![0];
  }
  return true;
}

bool bikingEnded(PlanItineraryLeg leg) {
  return leg.fromPlace!.bikeRentalStation != null &&
      leg.transportMode == TransportMode.walk;
}

double getTotalWalkingDistance(List<PlanItineraryLeg?> legs) =>
    sumDistances(legs.where(isWalkingLeg).toList());

double getTotalBikingDistance(List<PlanItineraryLeg?> legs) =>
    sumDistances(legs.where(isBikingLeg).toList());

double sumDistances(List<PlanItineraryLeg?> legs) {
  return legs.isNotEmpty
      ? legs
          .map((e) => e!.distance ?? 0)
          .reduce((value, element) => value + element)
      : 0;
}

double getTotalWalkingDuration(List<PlanItineraryLeg?> legs) {
  return sumDurations(legs.where(isWalkingLeg).toList());
}

double getTotalBikingDuration(List<PlanItineraryLeg?> legs) {
  return sumDurations(legs.where(isBikingLeg).toList());
}

double sumDurations(List<PlanItineraryLeg?> legs) {
  return legs.isNotEmpty
      ? legs
          .map((e) => e!.duration ?? 0)
          .reduce((value, element) => value + element)
      : 0;
}

bool isWalkingLeg(PlanItineraryLeg? leg) {
  return [LegMode.bicycleWalk, LegMode.walk]
      .contains(getLegModeByKey(leg!.mode));
}

bool isBikingLeg(PlanItineraryLeg? leg) {
  return [LegMode.bicycle, LegMode.cityBike]
      .contains(getLegModeByKey(leg!.mode));
}
