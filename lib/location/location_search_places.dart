import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:trufi_app/location/location_search_favorites.dart';
import 'package:trufi_app/trufi_models.dart';

class Places {
  static Places _instance;

  static Places get instance => _instance;

  static void init(BuildContext context) async {
    _instance ??= Places._init(await _readPlaces(context));
  }

  final List<TrufiLocation> _locations;

  Places._init(this._locations);

  factory Places() => _instance;

  Future<List<TrufiLocation>> fetchLocations(String query) async {
    query = query.toLowerCase();
    var locations = query.isEmpty
        ? _locations.toList()
        : _locations
            .where((l) => l.description.toLowerCase().contains(query))
            .toList();
    locations.sort(sortByFavorite);
    return locations;
  }
}

Future<List<TrufiLocation>> _readPlaces(BuildContext context) async {
  return compute(
    _parsePlaces,
    await DefaultAssetBundle.of(context).loadString(
          "assets/data/places.json",
          cache: true,
        ),
  );
}

List<TrufiLocation> _parsePlaces(String encoded) {
  final parsed = json.decode(encoded);
  return parsed
      .map<TrufiLocation>(
          (json) => new TrufiLocation.fromImportantPlacesJson(json))
      .toList();
}
