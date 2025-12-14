import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'request_plan_service.dart';

/// Implementation of [RequestPlanService] using the routing package.
class RoutingRequestPlanService implements RequestPlanService {
  final routing.PlanRepository _repository;

  RoutingRequestPlanService(routing.OtpConfiguration otpConfiguration)
      : _repository = otpConfiguration.createPlanRepository();

  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    List<routing.TransportMode>? transportModes,
    String? locale,
    DateTime? dateTime,
  }) async {
    final plan = await _repository.fetchPlan(
      from: routing.RoutingLocation(
        position: LatLng(from.latitude, from.longitude),
        description: from.description,
      ),
      to: routing.RoutingLocation(
        position: LatLng(to.latitude, to.longitude),
        description: to.description,
      ),
      locale: locale,
      dateTime: dateTime ?? DateTime.now(),
    );

    // Sort itineraries by weighted sum (transfers, walk distance, total distance)
    if (plan.itineraries != null && plan.itineraries!.isNotEmpty) {
      final sortedItineraries = List<routing.Itinerary>.from(plan.itineraries!);
      sortedItineraries.sort((a, b) {
        final weightA = _calculateWeight(a);
        final weightB = _calculateWeight(b);
        return weightA.compareTo(weightB);
      });
      return plan.copyWith(itineraries: sortedItineraries);
    }

    return plan;
  }

  double _calculateWeight(routing.Itinerary itinerary) {
    return (itinerary.numberOfTransfers * 0.65) +
        (itinerary.walkDistance * 0.3) +
        ((itinerary.distance / 100) * 0.05);
  }
}
