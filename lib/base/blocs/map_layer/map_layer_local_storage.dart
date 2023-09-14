import 'dart:convert';
import 'package:hive/hive.dart';

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
    final _box = Hive.box(path);
    final jsonString = _box.get(path);
    return jsonString != null
        ? (jsonDecode(jsonString) as Map<String, dynamic>?)?.map<String, bool>(
                (key, value) => MapEntry(key, value as bool)) ??
            {}
        : {};
  }
}
