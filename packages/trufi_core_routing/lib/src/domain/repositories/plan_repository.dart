import '../entities/plan.dart';
import '../entities/routing_location.dart';
import '../entities/routing_preferences.dart';

/// Repository interface for fetching trip plans.
abstract class PlanRepository {
  /// Fetches a trip plan from origin to destination.
  ///
  /// [from] - The starting location.
  /// [to] - The destination location.
  /// [numItineraries] - Number of itineraries to request.
  /// [locale] - Locale for localized responses.
  /// [dateTime] - The date and time for the trip.
  /// [arriveBy] - If true, [dateTime] is the desired arrival time; otherwise departure time.
  /// [preferences] - Optional routing preferences (accessibility, walk speed, etc.).
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
    RoutingPreferences? preferences,
  });
}
