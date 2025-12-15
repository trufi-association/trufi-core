import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_storage/trufi_core_storage.dart';

import 'search_locations_local_repository.dart';

/// Hive-based implementation of SearchLocationsLocalRepository.
class SearchLocationsHiveLocalRepository
    implements SearchLocationsLocalRepository {
  static const String _boxName = "SearchLocationsCubit";
  static const _favoritePlacesKey = 'SearchLocationsCubitFavoritePlaces';
  static const _historyPlacesKey = 'SearchLocationsCubitHistoryPlaces';
  static const _myDefaultPlacesKey = 'SearchLocationsCubitMyDefaultPlaces';
  static const _myPlacesKey = 'SearchLocationsCubitMyPlaces';

  Box? _box;
  bool _isInitialized = false;

  Box get _safeBox {
    if (!_isInitialized || _box == null) {
      throw StateError(
        'SearchLocationsHiveLocalRepository not initialized. '
        'Call loadRepository() first.',
      );
    }
    return _box!;
  }

  @override
  Future<void> loadRepository() async {
    if (_isInitialized) return;
    await TrufiHive.ensureInitialized();
    _box = await Hive.openBox(_boxName);
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
    _isInitialized = false;
  }

  @override
  Future<List<TrufiLocation>> getFavoritePlaces() async {
    return _getPlacesList(_favoritePlacesKey);
  }

  @override
  Future<List<TrufiLocation>> getHistoryPlaces() async {
    return _getPlacesList(_historyPlacesKey);
  }

  @override
  Future<List<TrufiLocation>> getMyDefaultPlaces() async {
    return _getPlacesList(_myDefaultPlacesKey);
  }

  @override
  Future<List<TrufiLocation>> getMyPlaces() async {
    return _getPlacesList(_myPlacesKey);
  }

  @override
  Future<void> saveFavoritePlaces(List<TrufiLocation> data) async {
    await _savePlacesList(_favoritePlacesKey, data);
  }

  @override
  Future<void> saveHistoryPlaces(List<TrufiLocation> data) async {
    await _savePlacesList(_historyPlacesKey, data);
  }

  @override
  Future<void> saveMyDefaultPlaces(List<TrufiLocation> data) async {
    await _savePlacesList(_myDefaultPlacesKey, data);
  }

  @override
  Future<void> saveMyPlaces(List<TrufiLocation> data) async {
    await _savePlacesList(_myPlacesKey, data);
  }

  // ============ Private Helpers ============

  Future<List<TrufiLocation>> _getPlacesList(String key) async {
    try {
      final box = _safeBox;
      if (!box.containsKey(key)) return [];
      final data = box.get(key);
      if (data == null) return [];
      final List<dynamic> jsonList = jsonDecode(data as String) as List<dynamic>;
      return jsonList
          .map<TrufiLocation>(
            (dynamic json) =>
                TrufiLocation.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Error loading places from $key: $e');
      return [];
    }
  }

  Future<void> _savePlacesList(String key, List<TrufiLocation> data) async {
    try {
      await _safeBox.put(key, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving places to $key: $e');
    }
  }
}
