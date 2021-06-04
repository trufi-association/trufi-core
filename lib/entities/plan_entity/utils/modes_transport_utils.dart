import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

import '../plan_entity.dart';

bool hasItinerariesContainingPublicTransit(PlanEntity bikeAndPublicPlan) {
  if (bikeAndPublicPlan?.itineraries?.isNotEmpty ?? false) {
    if (bikeAndPublicPlan.itineraries.length == 1) {
      return bikeAndPublicPlan.itineraries[0].legs
          .where((leg) => ![
                TransportMode.walk,
                TransportMode.bicycle,
                TransportMode.car,
              ].contains(leg.transportMode))
          .isNotEmpty;
    }
    return true;
  }
  return false;
}
