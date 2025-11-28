import '../entities/itinerary.dart';
import '../entities/plan.dart';
import '../entities/routing_location.dart';
import '../entities/transport_mode.dart';
import '../repositories/plan_repository.dart';

/// High-level routing service that provides trip planning with business logic.
class RoutingService {
  RoutingService({required PlanRepository repository}) : _repository = repository;

  final PlanRepository _repository;

  /// Fetches a trip plan, filtering out walk-only itineraries.
  ///
  /// If no transit itineraries are found, retries with default modes.
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 10,
    String? locale,
    bool filterWalkOnly = true,
  }) async {
    var plan = await _repository.fetchPlan(
      from: from,
      to: to,
      numItineraries: numItineraries,
      locale: locale,
    );

    if (filterWalkOnly) {
      plan = _filterWalkOnlyItineraries(plan);
    }

    return plan;
  }

  /// Fetches additional itineraries for pagination.
  Future<Plan> fetchMoreItineraries({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    bool filterWalkOnly = true,
  }) async {
    var plan = await _repository.fetchPlan(
      from: from,
      to: to,
      numItineraries: numItineraries,
      locale: locale,
    );

    if (filterWalkOnly) {
      plan = _filterWalkOnlyItineraries(plan);
    }

    return plan;
  }

  /// Filters out itineraries that only contain walking legs.
  Plan _filterWalkOnlyItineraries(Plan plan) {
    final filtered = plan.itineraries?.where((itinerary) {
      return !_isWalkOnlyItinerary(itinerary);
    }).toList();

    return Plan(
      from: plan.from,
      to: plan.to,
      itineraries: filtered,
    );
  }

  /// Checks if an itinerary contains only walking legs.
  bool _isWalkOnlyItinerary(Itinerary itinerary) {
    return itinerary.legs.every((leg) => leg.transportMode == TransportMode.walk);
  }
}
