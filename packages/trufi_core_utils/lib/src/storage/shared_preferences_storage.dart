import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// SharedPreferences implementation of [StorageService].
class SharedPreferencesStorage implements StorageService {
  final bool enableLogging;
  SharedPreferences? _prefs;

  SharedPreferencesStorage({this.enableLogging = false});

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    if (enableLogging) {
      debugPrint('[Storage] Initialized with SharedPreferences');
    }
  }

  @override
  Future<void> dispose() async {
    _prefs = null;
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError(
        'SharedPreferencesStorage not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  @override
  Future<void> write(String key, String value) async {
    await prefs.setString(key, value);
    _log('write', key, value);
  }

  @override
  Future<String?> read(String key) async {
    final value = prefs.getString(key);
    _log('read', key, value);
    return value;
  }

  @override
  Future<void> delete(String key) async {
    await prefs.remove(key);
    _log('delete', key, null);
  }

  @override
  Future<void> clear() async {
    await prefs.clear();
    _log('clear', 'all', null);
  }

  @override
  Future<void> writeInt(String key, int value) async {
    await prefs.setInt(key, value);
    _log('writeInt', key, value);
  }

  @override
  Future<int?> readInt(String key) async {
    final value = prefs.getInt(key);
    _log('readInt', key, value);
    return value;
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    await prefs.setBool(key, value);
    _log('writeBool', key, value);
  }

  @override
  Future<bool?> readBool(String key) async {
    final value = prefs.getBool(key);
    _log('readBool', key, value);
    return value;
  }

  @override
  Future<void> writeDouble(String key, double value) async {
    await prefs.setDouble(key, value);
    _log('writeDouble', key, value);
  }

  @override
  Future<double?> readDouble(String key) async {
    final value = prefs.getDouble(key);
    _log('readDouble', key, value);
    return value;
  }

  @override
  Future<void> writeStringList(String key, List<String> value) async {
    await prefs.setStringList(key, value);
    _log('writeStringList', key, value);
  }

  @override
  Future<List<String>?> readStringList(String key) async {
    final value = prefs.getStringList(key);
    _log('readStringList', key, value);
    return value;
  }

  @override
  Future<bool> containsKey(String key) async {
    return prefs.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    return prefs.getKeys();
  }

  void _log(String operation, String key, dynamic value) {
    if (enableLogging) {
      debugPrint('[Storage] $operation: $key = $value');
    }
  }
}
