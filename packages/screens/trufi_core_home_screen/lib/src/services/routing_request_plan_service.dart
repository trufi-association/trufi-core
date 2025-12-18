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
    routing.RoutingPreferences? preferences,
  }) async {
    // Use dateTime from preferences if timeMode is not leaveNow
    final effectiveDateTime = _getEffectiveDateTime(preferences, dateTime);
    // Determine if this is an "arrive by" query
    final arriveBy = preferences?.timeMode == routing.TimeMode.arriveBy;

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
      dateTime: effectiveDateTime,
      arriveBy: arriveBy,
      preferences: preferences,
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

  /// Gets the effective dateTime based on preferences.
  DateTime _getEffectiveDateTime(
    routing.RoutingPreferences? preferences,
    DateTime? fallback,
  ) {
    if (preferences == null) return fallback ?? DateTime.now();

    // If timeMode is leaveNow, always use current time
    if (preferences.timeMode == routing.TimeMode.leaveNow) {
      return DateTime.now();
    }

    // Otherwise use the dateTime from preferences, or fallback to now
    return preferences.dateTime ?? fallback ?? DateTime.now();
  }
}
