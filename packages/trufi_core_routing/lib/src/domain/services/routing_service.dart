import '../entities/itinerary.dart';
import '../entities/itinerary_group.dart';
import '../entities/plan.dart';
import '../entities/routing_location.dart';
import '../entities/transport_mode.dart';
import '../repositories/plan_repository.dart';
import '../utils/itinerary_signature.dart';

/// High-level routing service that provides trip planning with business logic.
class RoutingService {
  RoutingService({required PlanRepository repository})
    : _repository = repository;

  final PlanRepository _repository;

  /// Fetches a trip plan, filtering out walk-only itineraries.
  ///
  /// If no transit itineraries are found, retries with default modes.
  /// The returned plan includes both individual itineraries and grouped itineraries.
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 10,
    String? locale,
    bool filterWalkOnly = true,
    DateTime? dateTime,
  }) async {
    var plan = await _repository.fetchPlan(
      from: from,
      to: to,
      numItineraries: numItineraries,
      locale: locale,
      dateTime: dateTime ?? DateTime.now(),
    );

    if (filterWalkOnly) {
      plan = _filterWalkOnlyItineraries(plan);
    }

    // Group itineraries by route pattern
    final grouped = groupItineraries(plan.itineraries ?? []);
    return plan.copyWith(groupedItineraries: grouped);
  }

  /// Fetches additional itineraries for pagination.
  Future<Plan> fetchMoreItineraries({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    bool filterWalkOnly = true,
    DateTime? dateTime,
  }) async {
    var plan = await _repository.fetchPlan(
      from: from,
      to: to,
      numItineraries: numItineraries,
      locale: locale,
      dateTime: dateTime ?? DateTime.now(),
    );

    if (filterWalkOnly) {
      plan = _filterWalkOnlyItineraries(plan);
    }

    // Group itineraries by route pattern
    final grouped = groupItineraries(plan.itineraries ?? []);
    return plan.copyWith(groupedItineraries: grouped);
  }

  /// Filters out itineraries that only contain walking legs.
  Plan _filterWalkOnlyItineraries(Plan plan) {
    final filtered = plan.itineraries?.where((itinerary) {
      return !_isWalkOnlyItinerary(itinerary);
    }).toList();

    return Plan(from: plan.from, to: plan.to, itineraries: filtered);
  }

  /// Checks if an itinerary contains only walking legs.
  bool _isWalkOnlyItinerary(Itinerary itinerary) {
    return itinerary.legs.every(
      (leg) => leg.transportMode == TransportMode.walk,
    );
  }

  /// Groups itineraries by their route pattern.
  ///
  /// Itineraries that use the same buses, stops, and transfers are grouped together.
  /// Each group has a representative (earliest departure) and a list of alternatives.
  ///
  /// Returns a list of [ItineraryGroup] sorted by the representative's start time.
  List<ItineraryGroup> groupItineraries(List<Itinerary> itineraries) {
    if (itineraries.isEmpty) return [];

    final Map<String, List<Itinerary>> grouped = {};

    for (final itinerary in itineraries) {
      final signature = generateItinerarySignature(itinerary);
      grouped.putIfAbsent(signature, () => []).add(itinerary);
    }

    final groups = grouped.entries.map((entry) {
      // Sort by start time, pick earliest as representative
      final sorted = List<Itinerary>.from(entry.value)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      return ItineraryGroup(
        representative: sorted.first,
        alternatives: sorted,
        signature: entry.key,
      );
    }).toList();

    // Sort groups by representative's start time
    groups.sort((a, b) =>
        a.representative.startTime.compareTo(b.representative.startTime));

    return groups;
  }
}
