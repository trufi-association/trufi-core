import 'package:latlong2/latlong.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_routing/trufi_core_routing.dart' show TransportMode;

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/services/request_plan_service.dart';

/// Implementation of [RequestPlanService] that uses the routing package.
///
/// This converts between the app's models and the routing package's models.
class RoutingRequestPlanService implements RequestPlanService {
  final routing.PlanRepository _repository;

  RoutingRequestPlanService(routing.OtpConfiguration otpConfiguration)
      : _repository = otpConfiguration.createPlanRepository();

  @override
  Future<Plan> fetchAdvancedPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    required List<TransportMode> transportModes,
    String? localeName,
  }) async {
    try {
      final routingPlan = await _repository.fetchPlan(
        from: routing.RoutingLocation(
          position: LatLng(from.latitude, from.longitude),
          description: from.description,
        ),
        to: routing.RoutingLocation(
          position: LatLng(to.latitude, to.longitude),
          description: to.description,
        ),
        locale: localeName,
      );

      final plan = Plan.fromPackage(routingPlan);

      // Sort itineraries by weighted sum (transfers, walk distance, total distance)
      plan.itineraries?.sort((a, b) {
        double weightedSumA = (a.transfers * 0.65) +
            (a.walkDistance * 0.3) +
            ((a.distance / 100) * 0.05);
        double weightedSumB = (b.transfers * 0.65) +
            (b.walkDistance * 0.3) +
            ((b.distance / 100) * 0.05);
        return weightedSumA.compareTo(weightedSumB);
      });

      return plan;
    } catch (e) {
      return Plan(error: PlanError.fromError(e.toString()));
    }
  }
}
