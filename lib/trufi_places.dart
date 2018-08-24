import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trufi_app/trufi_models.dart';

const String _PlacesPath = 'assets/data/places.json';

class _PlacesData {
  final String encoded;
  final String query;

  _PlacesData(this.encoded, this.query);
}

Future<List<TrufiLocation>> fetchLocations(
    BuildContext context, String query) async {
  return compute(
      _parsePlaces,
      new _PlacesData(
          await DefaultAssetBundle
              .of(context)
              .loadString(_PlacesPath, cache: true),
          query));
}

List<TrufiLocation> _parsePlaces(_PlacesData data) {
  final parsed = json.decode(data.encoded);
  List<TrufiLocation> places = parsed
      .map<TrufiLocation>(
          (json) => new TrufiLocation.fromImportantPlacesJson(json))
      .toList();
  if (data.query.isEmpty) {
    return places;
  }
  final String query = data.query.toLowerCase();
  return places
      .where((l) => l.description.toLowerCase().contains(query))
      .toList();
}
