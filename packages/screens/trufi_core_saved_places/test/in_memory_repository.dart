import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

/// Test double: keeps places in a map, no platform channels.
class InMemorySavedPlacesRepository implements SavedPlacesRepository {
  final Map<String, SavedPlace> _places = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<SavedPlace>> getPlacesByType(SavedPlaceType type) async =>
      _places.values.where((p) => p.type == type).toList();

  @override
  Future<List<SavedPlace>> getAllPlaces() async => _places.values.toList();

  @override
  Future<SavedPlace?> getHome() async =>
      _places.values.where((p) => p.type == SavedPlaceType.home).firstOrNull;

  @override
  Future<SavedPlace?> getWork() async =>
      _places.values.where((p) => p.type == SavedPlaceType.work).firstOrNull;

  @override
  Future<List<SavedPlace>> getOtherPlaces() async =>
      getPlacesByType(SavedPlaceType.other);

  @override
  Future<List<SavedPlace>> getHistory() async =>
      getPlacesByType(SavedPlaceType.history);

  @override
  Future<void> savePlace(SavedPlace place) async => _places[place.id] = place;

  @override
  Future<void> updatePlace(SavedPlace place) async => _places[place.id] = place;

  @override
  Future<void> deletePlace(String id) async => _places.remove(id);

  @override
  Future<void> deletePlacesByType(SavedPlaceType type) async =>
      _places.removeWhere((_, p) => p.type == type);

  @override
  Future<void> clearHistory() async =>
      deletePlacesByType(SavedPlaceType.history);

  @override
  Future<void> addToHistory(SavedPlace place) async => savePlace(place);
}
