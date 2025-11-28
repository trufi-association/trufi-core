import '../entities/plan.dart';
import '../entities/routing_location.dart';

/// Repository interface for fetching trip plans.
abstract class PlanRepository {
  /// Fetches a trip plan from origin to destination.
  ///
  /// [from] - The starting location.
  /// [to] - The destination location.
  /// [numItineraries] - Number of itineraries to request.
  /// [locale] - Locale for localized responses.
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
  });
}
