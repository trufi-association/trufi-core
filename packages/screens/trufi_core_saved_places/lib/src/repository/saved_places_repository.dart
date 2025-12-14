import '../models/saved_place.dart';

/// Abstract interface for saved places persistence.
abstract class SavedPlacesRepository {
  /// Initializes the repository (e.g., opens database connections).
  Future<void> initialize();

  /// Disposes the repository (e.g., closes database connections).
  Future<void> dispose();

  /// Gets all saved places of a specific type.
  Future<List<SavedPlace>> getPlacesByType(SavedPlaceType type);

  /// Gets all saved places.
  Future<List<SavedPlace>> getAllPlaces();

  /// Gets the home location.
  Future<SavedPlace?> getHome();

  /// Gets the work location.
  Future<SavedPlace?> getWork();

  /// Gets all other places (custom saved places).
  Future<List<SavedPlace>> getOtherPlaces();

  /// Gets the history of places.
  Future<List<SavedPlace>> getHistory();

  /// Saves a place.
  Future<void> savePlace(SavedPlace place);

  /// Updates an existing place.
  Future<void> updatePlace(SavedPlace place);

  /// Deletes a place by its ID.
  Future<void> deletePlace(String id);

  /// Deletes all places of a specific type.
  Future<void> deletePlacesByType(SavedPlaceType type);

  /// Clears all history.
  Future<void> clearHistory();

  /// Adds a place to history.
  Future<void> addToHistory(SavedPlace place);
}
