import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:trufi_core/trufi_models.dart';

import 'location_storage.dart';
// TODO this class is UnUsed,
class JSONLocationStorage extends LocationStorage {
  JSONLocationStorage(this.key);

  final String key;

  @override
  Future<bool> load() async {
    locations.clear();
    locations.addAll(await loadFromAssets(key));
    return true;
  }

  @override
  Future<bool> save() async {
    return false;
  }

  Future<List<TrufiLocation>> loadFromAssets(
    String key,
  ) async {
    // TODO for remove the context.
    // I changed from DefaultAssetBundle.of(context).loadString(key),
    return _parseLocationsJSON(await rootBundle.loadString(key));
  }

  List<TrufiLocation> _parseLocationsJSON(String encoded) {
    if (encoded != null && encoded.isNotEmpty) {
      try {
        return json
            .decode(encoded)
            .map<TrufiLocation>(
              (dynamic json) => TrufiLocation.fromLocationsJson(json as Map<String, dynamic>),
            )
            .toList() as List<TrufiLocation>;
      } catch (e) {
        // TODO: replace with error handling
        // ignore: avoid_print
        print("Failed to parse locations from JSON: $e");
      }
    }
    return [];
  }
}
