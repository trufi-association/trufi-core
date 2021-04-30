import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core/trufi_models.dart';

import 'location_storage.dart';

class SharedPreferencesLocationStorage extends LocationStorage {
  SharedPreferencesLocationStorage(this.key);

  final String key;

  @override
  Future<bool> load() async {
    locations.clear();
    locations.addAll(await _loadFromPreferences(key));
    return true;
  }

  @override
  Future<bool> save() async {
    return _saveToPreferences(key, locations);
  }

  Future<bool> _saveToPreferences(
    String key,
    List<TrufiLocation> locations,
  ) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(
      key,
      json.encode(locations.map((location) => location.toJson()).toList()),
    );
  }

  Future<List<TrufiLocation>> _loadFromPreferences(String key) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      return _parseTrufiLocations(preferences.getString(key));
    } catch (e) {
      // TODO: replace with error handling
      // ignore: avoid_print
      print("Failed to read location storage: $e");
      return Future<List<TrufiLocation>>.value();
    }
  }

  List<TrufiLocation> _parseTrufiLocations(String encoded) {
    if (encoded != null && encoded.isNotEmpty) {
      try {
        return json
            .decode(encoded)
            .map<TrufiLocation>(
                (dynamic json) => TrufiLocation.fromJson(json as Map<String, dynamic>))
            .toList() as List<TrufiLocation>;
      } catch (e) {
        // TODO: Replace with proper error handling
        // ignore: avoid_print
        print("Failed to parse trufi locations: $e");
      }
    }
    return [];
  }
}
