import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:trufi_app/trufi_models.dart';

Future<List<TrufiLocation>> fetchLocations(int limit) async {
  List<TrufiLocation> history = await _readHistory();
  return history.sublist(0, min(history.length, limit));
}

addLocation(TrufiLocation location) async {
  List<TrufiLocation> history = await _readHistory();
  history.removeWhere((l) => l.description == location.description);
  history.insert(0, location);
  _writeHistory(history);
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/location_search_history.txt');
}

Future<File> _writeHistory(List<TrufiLocation> locations) async {
  final file = await _localFile;
  return file.writeAsString(
      json.encode(locations.map((location) => location.toJson()).toList()));
}

Future<List<TrufiLocation>> _readHistory() async {
  try {
    final file = await _localFile;
    String encoded = await file.readAsString();
    return compute(_parseHistory, encoded);
  } catch (e) {
    return compute(_parseHistory, "[]");
  }
}

List<TrufiLocation> _parseHistory(String encoded) {
  final parsed = json.decode(encoded);
  return parsed
      .map<TrufiLocation>((json) => new TrufiLocation.fromJson(json))
      .toList();
}
