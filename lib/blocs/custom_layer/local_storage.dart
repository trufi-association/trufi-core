import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final String customLayersStorage = "custom_layers_storage";
  Future<bool> save(Map<String, bool?>? currentState) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(
      customLayersStorage,
      json.encode(currentState),
    );
  }

  Future<Map<String, bool>> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final data = json.decode(preferences.getString(customLayersStorage) ?? "{}")
        as Map<String, dynamic>;
    return data.map<String, bool>((key, value) => MapEntry(key, value as bool));
  }
}
