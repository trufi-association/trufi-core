import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:trufi_core_storage/trufi_core_storage.dart';

/// Local storage for persisting map layer visibility states.
class MapLayerLocalStorage {
  static const String _boxName = "MapLayerLocalStorage";
  static const String _key = "layerStatus";

  Box? _box;
  bool _isInitialized = false;

  /// Initialize the storage and open the Hive box.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await TrufiHive.ensureInitialized();
    _box = await Hive.openBox(_boxName);
    _isInitialized = true;
  }

  /// Close the storage and release resources.
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
    _isInitialized = false;
  }

  /// Save the layer visibility states.
  Future<bool> save(Map<String, bool> currentState) async {
    try {
      if (!_isInitialized || _box == null) {
        debugPrint('MapLayerLocalStorage: Cannot save, not initialized');
        return false;
      }
      await _box!.put(_key, jsonEncode(currentState));
      return true;
    } catch (e) {
      debugPrint('MapLayerLocalStorage: Error saving state: $e');
      return false;
    }
  }

  /// Load the saved layer visibility states.
  Future<Map<String, bool>> load() async {
    try {
      if (!_isInitialized || _box == null) {
        debugPrint('MapLayerLocalStorage: Cannot load, not initialized');
        return {};
      }
      final jsonString = _box!.get(_key);
      if (jsonString == null) return {};
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>?;
      return decoded?.map<String, bool>(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {};
    } catch (e) {
      debugPrint('MapLayerLocalStorage: Error loading state: $e');
      return {};
    }
  }
}
