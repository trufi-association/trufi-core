import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core/repositories/storage/i_local_storage.dart';

/// Implementation of ILocalStorage using SharedPreferences
/// 
/// This is a temporary solution while we evaluate better storage options.
/// SharedPreferences is simple and reliable for storing key-value pairs.
class SharedPreferencesStorage implements ILocalStorage {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError(
        'SharedPreferencesStorage not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _instance.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _instance.getString(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _instance.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    await _instance.remove(key);
  }

  @override
  Future<void> clear() async {
    await _instance.clear();
  }

  @override
  Future<Set<String>> getKeys() async {
    return _instance.getKeys();
  }
}
