import 'dart:convert';
import 'package:hive/hive.dart';

/// Local storage for persisting map layer visibility states.
class MapLayerLocalStorage {
  static const String path = "MapLayerLocalStorage";
  Future<bool> save(Map<String, bool> currentState) async {
    try {
      final box = Hive.box(path);
      await box.put(path, jsonEncode(currentState));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, bool>> load() async {
    final box = Hive.box(path);
    final jsonString = box.get(path);
    return jsonString != null
        ? (jsonDecode(jsonString) as Map<String, dynamic>?)?.map<String, bool>(
                (key, value) => MapEntry(key, value as bool)) ??
            {}
        : {};
  }
}
