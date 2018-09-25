import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

abstract class LocationStorage {
  final List<TrufiLocation> _locations = List();

  Future<bool> load(BuildContext context);

  Future<bool> save();

  UnmodifiableListView<TrufiLocation> get unmodifiableListView {
    return UnmodifiableListView(_locations);
  }

  Future<List<TrufiLocation>> fetchLocations(BuildContext context) async {
    return _sortedByFavorites(_locations.toList(), context);
  }

  Future<List<TrufiLocation>> fetchLocationsWithQuery(
    BuildContext context,
    String query,
  ) async {
    query = query.toLowerCase();
    var locations = query.isEmpty
        ? _locations.toList()
        : _locations
            .where((l) => l.description.toLowerCase().contains(query))
            .toList();
    return _sortedByFavorites(locations, context);
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

  Future<List<TrufiLocation>> _sortedByFavorites(
    List<TrufiLocation> locations,
    BuildContext context,
  ) async {
    final FavoriteLocationsBloc favoriteLocationsBloc =
        BlocProvider.of<FavoriteLocationsBloc>(context);
    locations.sort((a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
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

  bool contains(TrufiLocation location) {
    return _locations.contains(location);
  }
}

class SharedPreferencesLocationStorage extends LocationStorage {
  SharedPreferencesLocationStorage(this.key);

  final String key;

  Future<bool> load(BuildContext context) async {
    _locations.clear();
    _locations.addAll(await loadFromPreferences(key));
    return true;
  }

  Future<bool> save() async {
    return saveToPreferences(key, _locations);
  }
}

class ImportantLocationStorage extends LocationStorage {
  ImportantLocationStorage(this.key);

  final String key;

  Future<bool> load(BuildContext context) async {
    _locations.clear();
    _locations.addAll(await loadFromAssets(context, key));
    return true;
  }

  Future<bool> save() async {
    return false;
  }
}

Future<bool> saveToPreferences(
  String key,
  List<TrufiLocation> locations,
) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.setString(
    key,
    json.encode(locations.map((location) => location.toJson()).toList()),
  );
}

Future<List<TrufiLocation>> loadFromPreferences(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  try {
    return compute(_parseTrufiLocations, preferences.getString(key));
  } catch (e) {
    print("Failed to read location storage: $e");
    return Future<List<TrufiLocation>>.value(null);
  }
}

Future<List<TrufiLocation>> loadFromAssets(
  BuildContext context,
  String key,
) async {
  return compute(
    _parseImportantPlaces,
    await DefaultAssetBundle.of(context).loadString(key),
  );
}

List<TrufiLocation> _parseTrufiLocations(String encoded) {
  if (encoded != null && encoded.isNotEmpty) {
    try {
      return json
          .decode(encoded)
          .map<TrufiLocation>((json) => TrufiLocation.fromJson(json))
          .toList();
    } catch (e) {
      print("Failed to parse trufi locations: $e");
    }
  }
  return List();
}

List<TrufiLocation> _parseImportantPlaces(String encoded) {
  if (encoded != null && encoded.isNotEmpty) {
    try {
      return json
          .decode(encoded)
          .map<TrufiLocation>(
            (json) => TrufiLocation.fromImportantPlacesJson(json),
          )
          .toList();
    } catch (e) {
      print("Failed to parse important places: $e");
    }
  }
  return List();
}
