import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../trufi_models.dart';
import 'places_storage.dart';

class SharedPreferencesPlaceStorage extends PlacesStorage {
  List<TrufiLocation> _places = [];

  SharedPreferencesPlaceStorage(String id) : super(id);

  @override
  Future<void> delete(TrufiLocation location) async {
    _places.remove(location);
    await _save();
  }

  @override
  Future<void> insert(TrufiLocation location) async {
    _places.add(location);
    await _save();
  }

  @override
  Future<void> replace(TrufiLocation location) async {
    _places = _places.where((value) => value != location).toList();
    _places.add(location);
    await _save();
  }

  @override
  Future<void> update(TrufiLocation old, TrufiLocation location) async {
    final int index = _places.indexOf(old);
    if (index != -1) {
      _places.replaceRange(index, index + 1, [location]);
    }
    await _save();
  }

  @override
  Future<List<TrufiLocation>> all() async {
    _places = await _load();
    return _places.toList();
  }

  Future<bool> _save() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(
      id,
      json.encode(_places.map((location) => location.toJson()).toList()),
    );
  }

  Future<List<TrufiLocation>> _load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    return _parseTrufiLocations(preferences.getString(id));
  }

  List<TrufiLocation> _parseTrufiLocations(String encoded) {
    List<TrufiLocation> response = [];
    if (encoded != null && encoded.isNotEmpty) {
      try {
        response = json
            .decode(encoded)
            .map<TrufiLocation>((dynamic json) =>
                TrufiLocation.fromJson(json as Map<String, dynamic>))
            .toList() as List<TrufiLocation>;
      } catch (e) {
        // TODO: Replace with proper error handling
        // ignore: avoid_print
        print("Failed to parse $id: $e");
      }
    }
    return response;
  }
}
