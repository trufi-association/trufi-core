import 'dart:convert';

import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../models/saved_place.dart';
import 'saved_places_repository.dart';

/// Default implementation of [SavedPlacesRepository].
///
/// Uses [StorageService] for persistence. By default uses [SharedPreferencesStorage],
/// but can be configured with any [StorageService] implementation for testing or
/// alternative storage backends.
class SavedPlacesRepositoryImpl implements SavedPlacesRepository {
  static const String _homePlaceKey = 'trufi_saved_home_place';
  static const String _workPlaceKey = 'trufi_saved_work_place';
  static const String _otherPlacesKey = 'trufi_saved_other_places';
  static const String _historyKey = 'trufi_saved_history';

  static const int _maxHistoryItems = 50;

  final StorageService _storage;
  bool _isInitialized = false;

  SavedPlacesRepositoryImpl({StorageService? storage})
      : _storage = storage ?? SharedPreferencesStorage();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _storage.initialize();
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    await _storage.dispose();
    _isInitialized = false;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'SavedPlacesRepositoryImpl not initialized. Call initialize() first.',
      );
    }
  }

  @override
  Future<SavedPlace?> getHome() async {
    _ensureInitialized();
    final data = await _storage.read(_homePlaceKey);
    if (data == null) return null;
    return SavedPlace.fromJson(
      jsonDecode(data) as Map<String, dynamic>,
    );
  }

  @override
  Future<SavedPlace?> getWork() async {
    _ensureInitialized();
    final data = await _storage.read(_workPlaceKey);
    if (data == null) return null;
    return SavedPlace.fromJson(
      jsonDecode(data) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<SavedPlace>> getOtherPlaces() async {
    _ensureInitialized();
    return _getPlacesList(_otherPlacesKey);
  }

  @override
  Future<List<SavedPlace>> getHistory() async {
    _ensureInitialized();
    return _getPlacesList(_historyKey);
  }

  @override
  Future<List<SavedPlace>> getPlacesByType(SavedPlaceType type) async {
    _ensureInitialized();
    switch (type) {
      case SavedPlaceType.home:
        final home = await getHome();
        return home != null ? [home] : [];
      case SavedPlaceType.work:
        final work = await getWork();
        return work != null ? [work] : [];
      case SavedPlaceType.other:
        return getOtherPlaces();
      case SavedPlaceType.history:
        return getHistory();
    }
  }

  @override
  Future<List<SavedPlace>> getAllPlaces() async {
    _ensureInitialized();
    final List<SavedPlace> allPlaces = [];

    final home = await getHome();
    if (home != null) allPlaces.add(home);

    final work = await getWork();
    if (work != null) allPlaces.add(work);

    allPlaces.addAll(await getOtherPlaces());

    return allPlaces;
  }

  @override
  Future<void> savePlace(SavedPlace place) async {
    _ensureInitialized();
    switch (place.type) {
      case SavedPlaceType.home:
        await _storage.write(_homePlaceKey, jsonEncode(place.toJson()));
        break;
      case SavedPlaceType.work:
        await _storage.write(_workPlaceKey, jsonEncode(place.toJson()));
        break;
      case SavedPlaceType.other:
        await _addToList(_otherPlacesKey, place);
        break;
      case SavedPlaceType.history:
        await addToHistory(place);
        break;
    }
  }

  @override
  Future<void> updatePlace(SavedPlace place) async {
    _ensureInitialized();
    switch (place.type) {
      case SavedPlaceType.home:
        await _storage.write(_homePlaceKey, jsonEncode(place.toJson()));
        break;
      case SavedPlaceType.work:
        await _storage.write(_workPlaceKey, jsonEncode(place.toJson()));
        break;
      case SavedPlaceType.other:
        await _updateInList(_otherPlacesKey, place);
        break;
      case SavedPlaceType.history:
        await _updateInList(_historyKey, place);
        break;
    }
  }

  @override
  Future<void> deletePlace(String id) async {
    _ensureInitialized();

    // Check home
    final home = await getHome();
    if (home?.id == id) {
      await _storage.delete(_homePlaceKey);
      return;
    }

    // Check work
    final work = await getWork();
    if (work?.id == id) {
      await _storage.delete(_workPlaceKey);
      return;
    }

    // Check other places
    await _deleteFromList(_otherPlacesKey, id);

    // Check history
    await _deleteFromList(_historyKey, id);
  }

  @override
  Future<void> deletePlacesByType(SavedPlaceType type) async {
    _ensureInitialized();
    switch (type) {
      case SavedPlaceType.home:
        await _storage.delete(_homePlaceKey);
        break;
      case SavedPlaceType.work:
        await _storage.delete(_workPlaceKey);
        break;
      case SavedPlaceType.other:
        await _storage.delete(_otherPlacesKey);
        break;
      case SavedPlaceType.history:
        await _storage.delete(_historyKey);
        break;
    }
  }

  @override
  Future<void> clearHistory() async {
    _ensureInitialized();
    await _storage.delete(_historyKey);
  }

  @override
  Future<void> addToHistory(SavedPlace place) async {
    _ensureInitialized();
    final history = await _getPlacesList(_historyKey);

    // Remove duplicates (same coordinates)
    history.removeWhere(
      (p) => p.latitude == place.latitude && p.longitude == place.longitude,
    );

    // Add new place with updated lastUsedAt
    final updatedPlace = place.copyWith(
      type: SavedPlaceType.history,
      lastUsedAt: DateTime.now(),
    );
    history.insert(0, updatedPlace);

    // Limit history size
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await _savePlacesList(_historyKey, history);
  }

  // Helper methods

  Future<List<SavedPlace>> _getPlacesList(String key) async {
    final data = await _storage.read(key);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
    return jsonList
        .map((json) => SavedPlace.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _savePlacesList(String key, List<SavedPlace> places) async {
    final jsonList = places.map((p) => p.toJson()).toList();
    await _storage.write(key, jsonEncode(jsonList));
  }

  Future<void> _addToList(String key, SavedPlace place) async {
    final places = await _getPlacesList(key);
    places.add(place);
    await _savePlacesList(key, places);
  }

  Future<void> _updateInList(String key, SavedPlace place) async {
    final places = await _getPlacesList(key);
    final index = places.indexWhere((p) => p.id == place.id);
    if (index != -1) {
      places[index] = place;
      await _savePlacesList(key, places);
    }
  }

  Future<void> _deleteFromList(String key, String id) async {
    final places = await _getPlacesList(key);
    final originalLength = places.length;
    places.removeWhere((p) => p.id == id);
    if (places.length != originalLength) {
      await _savePlacesList(key, places);
    }
  }
}
