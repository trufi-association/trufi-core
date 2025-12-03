import '../entities/plan.dart';
import '../entities/routing_location.dart';

/// Repository interface for persisting route data locally.
abstract class MapRouteRepository {
  /// Initializes the repository.
  Future<void> loadRepository();

  /// Saves the current plan.
  Future<void> savePlan(Plan? data);

  /// Retrieves the cached plan.
  Future<Plan?> getPlan();

  /// Saves the origin position.
  Future<void> saveOriginPosition(RoutingLocation? location);

  /// Retrieves the cached origin position.
  Future<RoutingLocation?> getOriginPosition();

  /// Saves the destination position.
  Future<void> saveDestinationPosition(RoutingLocation? location);

  /// Retrieves the cached destination position.
  Future<RoutingLocation?> getDestinationPosition();
}
