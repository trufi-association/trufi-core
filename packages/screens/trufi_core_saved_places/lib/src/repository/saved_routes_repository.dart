import '../models/saved_route.dart';

/// Abstract interface for saved routes persistence (#1005).
abstract class SavedRoutesRepository {
  /// Initializes the repository (e.g., opens database connections).
  Future<void> initialize();

  /// Disposes the repository (e.g., closes database connections).
  Future<void> dispose();

  /// Gets every saved route in insertion order.
  Future<List<SavedRoute>> getAllRoutes();

  /// Appends a route.
  Future<void> saveRoute(SavedRoute route);

  /// Replaces the stored route with the same id; no-op when absent.
  Future<void> updateRoute(SavedRoute route);

  /// Deletes a route by its ID.
  Future<void> deleteRoute(String id);
}
