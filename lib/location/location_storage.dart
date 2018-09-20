import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class LocationStorage {
  LocationStorage(this.key, this._locations);

  final String key;
  final List<TrufiLocation> _locations;

  UnmodifiableListView<TrufiLocation> get unmodifiableListView =>
      UnmodifiableListView(_locations);

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

Future<String> get _localPath async {
  return (await getApplicationDocumentsDirectory()).path;
}

Future<File> localFile(String fileName) async {
  return File('${await _localPath}/$fileName');
}

Future<bool> writeStorage(String key, List<TrufiLocation> locations) {
  return SharedPreferences.getInstance().then((prefs) => prefs.setString(key, json.encode(locations.map((location) => location.toJson()).toList())));
}

Future<List<TrufiLocation>> readStorage(String key) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encoded = prefs.getString(key);
    return compute(_parseStorage, encoded);
  } catch (e) {
    print(e);
    return compute(_parseStorage, "[]");
  }
}

List<TrufiLocation> _parseStorage(String encoded) {
  List<TrufiLocation> locations;
  try {
    final parsed = json.decode(encoded);
    locations = parsed
        .map<TrufiLocation>((json) => TrufiLocation.fromJson(json))
        .toList();
  } catch (e) {
    print(e);
    locations = List();
  }
  return locations;
}
