import 'dart:async';
import 'dart:convert';

import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

const String keyPlaces = 'pois';
const String keyStreets = 'streets';
const String keyStreetJunctions = 'streetJunctions';

class LocationSearchStorage {
  final _diffMatchPatch = DiffMatchPatch();
  final _places = List<TrufiLocation>();
  final _streets = List<TrufiStreet>();

  void load(BuildContext context, String key) async {
    _places.clear();
    _streets.clear();
    final locationData = await loadFromAssets(context, key);
    _places.addAll(locationData.places);
    _streets.addAll(locationData.streets);
  }

  Future<List<TrufiLocation>> fetchPlaces(BuildContext context) async {
    return _sortedByFavorites(_places.toList(), context);
  }

  Future<List<LevenshteinObject>> fetchPlacesWithQuery(
    BuildContext context,
    String query,
  ) async {
    query = query.toLowerCase();
    return _places.fold<List<LevenshteinObject>>(
      List<LevenshteinObject>(),
      (locations, location) {
        int distance = _findMatchAndCalculateStringDistance(
          location.description.toLowerCase(),
          query,
        );
        if (distance < 3) {
          locations.add(LevenshteinObject(location, distance));
        }
        return locations;
      },
    );
  }

  Future<List<LevenshteinObject>> fetchStreetsWithQuery(
    BuildContext context,
    String query,
  ) async {
    query = query.toLowerCase();
    return _streets.fold<List<LevenshteinObject>>(
      List<LevenshteinObject>(),
      (streets, street) {
        int distance = _findMatchAndCalculateStringDistance(
          street.location.description.toLowerCase(),
          query,
        );
        if (distance < 3) {
          streets.add(LevenshteinObject(street, distance));
        }
        return streets;
      },
    );
  }

  int _findMatchAndCalculateStringDistance(String text, String query) {
    // Find match in text similar to query
    var position = _diffMatchPatch.match(text, query, 0);
    // If match found, calculate levenshtein distance
    if (position != -1 && position < text.length) {
      return position + query.length + 1 <= text.length
          ? _diffMatchPatch.diff_levenshtein(
              _diffMatchPatch.diff(
                text.substring(position, position + query.length + 1),
                query,
              ),
            )
          : _diffMatchPatch.diff_levenshtein(
              _diffMatchPatch.diff(
                text.substring(position),
                query,
              ),
            );
    } else {
      // If no match found, return distance 100
      return 100;
    }
  }

  Future<List<TrufiLocation>> _sortedByFavorites(
    List<TrufiLocation> locations,
    BuildContext context,
  ) async {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    locations.sort((a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
  }
}

class LocationSearchData {
  LocationSearchData(this.places, this.streets);

  final List<TrufiLocation> places;
  final List<TrufiStreet> streets;
}

Future<LocationSearchData> loadFromAssets(
  BuildContext context,
  String key,
) async {
  return compute(
    _parseSearchJson,
    await DefaultAssetBundle.of(context).loadString(key),
  );
}

LocationSearchData _parseSearchJson(String encoded) {
  if (encoded != null && encoded.isNotEmpty) {
    try {
      final search = json.decode(encoded);
      // Places
      final places = search[keyPlaces]
          .map<TrufiLocation>(
            (json) => TrufiLocation.fromSearchPlacesJson(json),
          )
          .toList();
      // Streets
      final streets = Map<String, TrufiStreet>();
      search[keyStreets].keys.forEach((key) {
        streets[key] = TrufiStreet.fromSearchJson(search[keyStreets][key]);
      });
      // Junctions
      search[keyStreetJunctions].keys.forEach((key) {
        final street1 = streets[key];
        if (street1 is TrufiStreet) {
          search[keyStreetJunctions][key].forEach((junction) {
            final street2 = streets[junction[0]];
            if (street2 is TrufiStreet) {
              street1.junctions.add(
                TrufiStreetJunction(
                  street1: street1,
                  street2: street2,
                  longitude: junction[1][0].toDouble(),
                  latitude: junction[1][1].toDouble(),
                ),
              );
            }
          });
        }
        street1.junctions.sort((TrufiStreetJunction a, TrufiStreetJunction b) {
          return a.description.compareTo(b.description);
        });
      });
      return LocationSearchData(places, streets.values.toList());
    } catch (e) {
      print("Failed to parse locations from JSON: $e");
    }
  }
  return LocationSearchData(List(), List());
}
