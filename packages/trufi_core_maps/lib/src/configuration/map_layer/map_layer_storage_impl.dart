import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'map_layer_local_storage.dart';

/// Default implementation of [MapLayerLocalStorage].
///
/// Uses [StorageService] for persistence. By default uses [SharedPreferencesStorage],
/// but can be configured with any [StorageService] implementation for testing or
/// alternative storage backends.
class MapLayerStorageImpl implements MapLayerLocalStorage {
  static const String _key = 'trufi_map_layer_status';

  final StorageService _storage;
  bool _isInitialized = false;

  MapLayerStorageImpl({StorageService? storage})
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

  @override
  Future<bool> save(Map<String, bool> currentState) async {
    try {
      if (!_isInitialized) {
        debugPrint(
          'MapLayerStorageImpl: Cannot save, not initialized',
        );
        return false;
      }
      await _storage.write(_key, jsonEncode(currentState));
      return true;
    } catch (e) {
      debugPrint('MapLayerStorageImpl: Error saving state: $e');
      return false;
    }
  }

  @override
  Future<Map<String, bool>> load() async {
    try {
      if (!_isInitialized) {
        debugPrint(
          'MapLayerStorageImpl: Cannot load, not initialized',
        );
        return {};
      }
      final jsonString = await _storage.read(_key);
      if (jsonString == null) return {};
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>?;
      return decoded?.map<String, bool>(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {};
    } catch (e) {
      debugPrint('MapLayerStorageImpl: Error loading state: $e');
      return {};
    }
  }
}
