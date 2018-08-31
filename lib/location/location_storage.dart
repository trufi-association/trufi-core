import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:trufi_app/trufi_models.dart';

class LocationStorage {
  final File file;
  final List<TrufiLocation> locations;

  LocationStorage(this.file, this.locations);

  Future<List<TrufiLocation>> fetchLocations() async {
    return locations;
  }

  Future<List<TrufiLocation>> fetchLocationsWithLimit(int limit) async {
    return locations.sublist(0, min(locations.length, limit));
  }

  add(TrufiLocation location) {
    remove(location);
    locations.add(location);
    _save();
  }

  remove(TrufiLocation location) {
    locations.remove(location);
    _save();
  }

  bool contains(TrufiLocation location) {
    return locations.contains(location);
  }

  _save() {
    writeStorage(file, locations);
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
    return compute(_parseStorage, "[]");
  }
}

List<TrufiLocation> _parseStorage(String encoded) {
  final parsed = json.decode(encoded);
  return parsed
      .map<TrufiLocation>((json) => new TrufiLocation.fromJson(json))
      .toList();
}
