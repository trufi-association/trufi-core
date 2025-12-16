import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'home_screen_repository.dart';

/// Default local implementation of [HomeScreenRepository].
///
/// Uses [StorageService] for persistence. By default uses [SharedPreferencesStorage],
/// but can be configured with any [StorageService] implementation for testing or
/// alternative storage backends.
class HomeScreenRepositoryImpl implements HomeScreenRepository {
  static const String _fromPlaceKey = 'trufi_home_from_place';
  static const String _toPlaceKey = 'trufi_home_to_place';
  static const String _planKey = 'trufi_home_plan';
  static const String _selectedItineraryKey = 'trufi_home_selected_itinerary';

  final StorageService _storage;
  bool _isInitialized = false;

  HomeScreenRepositoryImpl({StorageService? storage})
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
        'HomeScreenRepositoryImpl not initialized. Call initialize() first.',
      );
    }
  }

  @override
  Future<TrufiLocation?> getFromPlace() async {
    _ensureInitialized();
    try {
      final data = await _storage.read(_fromPlaceKey);
      if (data == null) return null;
      return TrufiLocation.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error getting fromPlace: $e');
      return null;
    }
  }

  @override
  Future<void> saveFromPlace(TrufiLocation? data) async {
    _ensureInitialized();
    try {
      if (data == null) {
        await _storage.delete(_fromPlaceKey);
      } else {
        await _storage.write(_fromPlaceKey, jsonEncode(data.toJson()));
      }
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error saving fromPlace: $e');
    }
  }

  @override
  Future<TrufiLocation?> getToPlace() async {
    _ensureInitialized();
    try {
      final data = await _storage.read(_toPlaceKey);
      if (data == null) return null;
      return TrufiLocation.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error getting toPlace: $e');
      return null;
    }
  }

  @override
  Future<void> saveToPlace(TrufiLocation? data) async {
    _ensureInitialized();
    try {
      if (data == null) {
        await _storage.delete(_toPlaceKey);
      } else {
        await _storage.write(_toPlaceKey, jsonEncode(data.toJson()));
      }
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error saving toPlace: $e');
    }
  }

  @override
  Future<routing.Plan?> getPlan() async {
    _ensureInitialized();
    try {
      final data = await _storage.read(_planKey);
      if (data == null) return null;
      return routing.Plan.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error getting plan: $e');
      return null;
    }
  }

  @override
  Future<void> savePlan(routing.Plan? data) async {
    _ensureInitialized();
    try {
      if (data == null) {
        await _storage.delete(_planKey);
      } else {
        await _storage.write(_planKey, jsonEncode(data.toJson()));
      }
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error saving plan: $e');
    }
  }

  @override
  Future<routing.Itinerary?> getSelectedItinerary() async {
    _ensureInitialized();
    try {
      final data = await _storage.read(_selectedItineraryKey);
      if (data == null) return null;
      return routing.Itinerary.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error getting selectedItinerary: $e');
      return null;
    }
  }

  @override
  Future<void> saveSelectedItinerary(routing.Itinerary? data) async {
    _ensureInitialized();
    try {
      if (data == null) {
        await _storage.delete(_selectedItineraryKey);
      } else {
        await _storage.write(_selectedItineraryKey, jsonEncode(data.toJson()));
      }
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error saving selectedItinerary: $e');
    }
  }

  @override
  Future<void> clear() async {
    _ensureInitialized();
    try {
      await _storage.delete(_fromPlaceKey);
      await _storage.delete(_toPlaceKey);
      await _storage.delete(_planKey);
      await _storage.delete(_selectedItineraryKey);
    } catch (e) {
      debugPrint('HomeScreenRepositoryImpl: Error clearing: $e');
    }
  }
}
