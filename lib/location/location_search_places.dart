import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_models.dart';

const String _PlacesPath = 'assets/data/places.json';

class Places {
  static Places _instance;

  static Places get instance => _instance;

  static void init(BuildContext context) async {
    _instance ??= Places._init(await _readPlaces(context));
  }

  final List<TrufiLocation> locations;

  Places._init(this.locations);

  factory Places() => _instance;

  Future<List<TrufiLocation>> fetchLocations(String query) async {
    if (query.isEmpty) {
      return locations;
    }
    query = query.toLowerCase();
    return locations
        .where((l) => l.description.toLowerCase().contains(query))
        .toList();
  }
}

Future<List<TrufiLocation>> _readPlaces(BuildContext context) async {
  return compute(
    _parsePlaces,
    await DefaultAssetBundle.of(context).loadString(
          _PlacesPath,
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
