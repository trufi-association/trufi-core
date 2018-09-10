import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class LocationStorage {
  final File _file;
  final Lock _fileLock = new Lock();
  final List<TrufiLocation> _locations;

  LocationStorage(this._file, this._locations);

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
    FavoriteLocationsBloc bloc =
        BlocProvider.of<FavoriteLocationsBloc>(context);
    locations.sort((a, b) => sortByFavoriteLocations(a, b, bloc.favorites));
    return locations;
  }

  add(TrufiLocation location) {
    remove(location);
    _locations.insert(0, location);
    _save();
  }

  remove(TrufiLocation location) {
    _locations.remove(location);
    _save();
  }

  bool contains(TrufiLocation location) {
    return _locations.contains(location);
  }

  _save() async {
    await _fileLock.synchronized(() => writeStorage(_file, _locations));
  }
}

Future<String> get _localPath async {
  return (await getApplicationDocumentsDirectory()).path;
}

Future<File> localFile(String fileName) async {
  return File('${await _localPath}/$fileName');
}

Future<File> writeStorage(File file, List<TrufiLocation> locations) {
  return file.writeAsString(
      json.encode(locations.map((location) => location.toJson()).toList()));
}

Future<List<TrufiLocation>> readStorage(File file) async {
  try {
    String encoded = await file.readAsString();
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
