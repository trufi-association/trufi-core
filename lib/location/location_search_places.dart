import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
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

  Future<List<TrufiLocation>> fetchLocations(
      BuildContext context, String query) async {
    FavoriteLocationsBloc bloc =
        BlocProvider.of<FavoriteLocationsBloc>(context);
    query = query.toLowerCase();
    var locations = query.isEmpty
        ? _locations.toList()
        : _locations
            .where((l) => l.description.toLowerCase().contains(query))
            .toList();
    locations.sort((a, b) => sortByFavorite(a, b, bloc.favorites));
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
        (json) => TrufiLocation.fromImportantPlacesJson(json),
      )
      .toList();
}
