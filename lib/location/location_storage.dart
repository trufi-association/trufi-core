import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/favorite_locations_bloc.dart';
import '../trufi_models.dart';

abstract class LocationStorage {
  DiffMatchPatch diffMatchPatch = DiffMatchPatch();

  final List<TrufiLocation> _locations = [];

  Future<bool> load(BuildContext context);

  Future<bool> save();

  UnmodifiableListView<TrufiLocation> get unmodifiableListView {
    return UnmodifiableListView(_locations);
  }

  Future<List<TrufiLocation>> fetchLocations(BuildContext context) async {
    return _sortedByFavorites(_locations.toList(), context);
  }

  Future<List<TrufiLocation>> fetchLocationsWithLimit(
    BuildContext context,
    int limit,
  ) async {
    return _sortedByFavorites(
      _locations.sublist(0, min(_locations.length, limit)),
      context,
    );
  }

  Future<List<LevenshteinObject>> fetchLocationsWithQuery(
    BuildContext context,
    String query,
  ) async {
    return _locations.fold<List<LevenshteinObject>>(
      <LevenshteinObject>[],
      (locations, location) {
        final int distance = _findMatchAndCalculateStringDistance(
          location.description.toLowerCase(),
          query.toLowerCase(),
        );
        if (distance < 3) {
          locations.add(LevenshteinObject(location, distance));
        }
        return locations;
      },
    );
  }

  void add(TrufiLocation location) {
    remove(location);
    _locations.insert(0, location);
    save();
  }

  void remove(TrufiLocation location) {
    _locations.remove(location);
    save();
  }

  void replace(Map<String, TrufiLocation> data) {
    final TrufiLocation oldLocation = data['oldLocation'];
    final TrufiLocation newLocation = data['newLocation'];
    final int indexLocation = _locations.indexOf(oldLocation);
    _locations[indexLocation] = newLocation;
    save();
  }

  bool contains(TrufiLocation location) {
    return _locations.contains(location);
  }

  int _findMatchAndCalculateStringDistance(String text, String query) {
    // Find match in text similar to query
    final position = diffMatchPatch.match(text, query, 0);
    // If match found, calculate levenshtein distance
    if (position != -1 && position < text.length) {
      return position + query.length + 1 <= text.length
          ? diffMatchPatch.diff_levenshtein(
              diffMatchPatch.diff(
                text.substring(position, position + query.length + 1),
                query,
              ),
            )
          : diffMatchPatch.diff_levenshtein(
              diffMatchPatch.diff(
                text.substring(position),
                query,
              ),
            );
    } else {
      // If no match found, return distance 100
      return 100;
    }
  }

  Future<List<TrufiLocation>> _sortedByFavorites(
    List<TrufiLocation> locations,
    BuildContext context,
  ) async {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    locations.sort((a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
  }
}

class SharedPreferencesLocationStorage extends LocationStorage {
  SharedPreferencesLocationStorage(this.key);

  final String key;

  @override
  Future<bool> load(BuildContext context) async {
    _locations.clear();
    _locations.addAll(await loadFromPreferences(key));
    return true;
  }

  @override
  Future<bool> save() async {
    return saveToPreferences(key, _locations);
  }
}

class JSONLocationStorage extends LocationStorage {
  JSONLocationStorage(this.key);

  final String key;

  @override
  Future<bool> load(BuildContext context) async {
    _locations.clear();
    _locations.addAll(await loadFromAssets(context, key));
    return true;
  }

  @override
  Future<bool> save() async {
    return false;
  }
}

Future<bool> saveToPreferences(
  String key,
  List<TrufiLocation> locations,
) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.setString(
    key,
    json.encode(locations.map((location) => location.toJson()).toList()),
  );
}

Future<List<TrufiLocation>> loadFromPreferences(String key) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  try {
    return compute(_parseTrufiLocations, preferences.getString(key));
  } catch (e) {
    // TODO: replace with error handling
    // ignore: avoid_print
    print("Failed to read location storage: $e");
    return Future<List<TrufiLocation>>.value();
  }
}

Future<List<TrufiLocation>> loadFromAssets(
  BuildContext context,
  String key,
) async {
  return compute(
    _parseLocationsJSON,
    await DefaultAssetBundle.of(context).loadString(key),
  );
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

List<TrufiLocation> _parseLocationsJSON(String encoded) {
  if (encoded != null && encoded.isNotEmpty) {
    try {
      return json
          .decode(encoded)
          .map<TrufiLocation>(
            (dynamic json) =>
                TrufiLocation.fromLocationsJson(json as Map<String, dynamic>),
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
