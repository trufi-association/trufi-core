import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class LocationStorage {
  LocationStorage(this.key, this._locations);

  final String key;
  final List<TrufiLocation> _locations;

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
    _save();
  }

  void remove(TrufiLocation location) {
    _locations.remove(location);
    _save();
  }

  bool contains(TrufiLocation location) {
    return _locations.contains(location);
  }

  void _save() {
    writeStorage(key, _locations);
  }
}

void writeStorage(String key, List<TrufiLocation> locations) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(
    key,
    json.encode(locations.map((location) => location.toJson()).toList()),
  );
}

Future<List<TrufiLocation>> readStorage(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  try {
    return compute(_parseStorage, preferences.getString(key));
  } catch (e) {
    print("Failed to read location storage: $e");
    return Future<List<TrufiLocation>>.value(<TrufiLocation>[]);
  }
}

List<TrufiLocation> _parseStorage(String encoded) {
  if (encoded == null || encoded.isEmpty) {
    return List();
  }
  try {
    final parsed = json.decode(encoded);
    return parsed
        .map<TrufiLocation>((json) => TrufiLocation.fromJson(json))
        .toList();
  } catch (e) {
    print("Failed to parse location storage: $e");
    return List();
  }
}
