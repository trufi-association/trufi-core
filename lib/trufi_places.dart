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
  return data.query.isEmpty
      ? places
      : places
          .where((location) => location.description.contains(data.query))
          .toList();
}
