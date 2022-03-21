import 'dart:async';
import 'dart:convert';

import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core/base/models/trufi_place.dart';

const String keyPlaces = 'pois';
const String keyStreets = 'streets';
const String keyStreetJunctions = 'streetJunctions';

class LocationSearchStorage {
  static const _levenshteinDistanceThreshold = 3;

  final _diffMatchPatch = DiffMatchPatch();
  final _places = <TrufiLocation>[];
  final _streets = <TrufiStreet>[];

  Future<void> load(String key) async {
    _places.clear();
    _streets.clear();
    try {
      final locationData = await loadFromAssets(key);
      _places.addAll(locationData.places);
      _streets.addAll(locationData.streets);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<List<TrufiLocation>> fetchPlaces(BuildContext context) async {
    return _sortedByFavorites(_places.toList(), context);
  }

  Future<List<LevenshteinObject<TrufiStreet>>> fetchStreetsWithQuery(
      String query) async {
    return _streets.fold<List<LevenshteinObject<TrufiStreet>>>(
      [],
      (streets, street) {
        final distance = _levenshteinDistanceForLocation(
          street.location,
          query.toLowerCase(),
        );
        if (distance < _levenshteinDistanceThreshold) {
          streets.add(LevenshteinObject(street, distance));
        }
        return streets;
      },
    );
  }

  Future<List<LevenshteinObject<TrufiLocation>>> fetchPlacesWithQuery(
      String query) async {
    return _places.fold<List<LevenshteinObject<TrufiLocation>>>(
      [],
      (locations, location) {
        final distance = _levenshteinDistanceForLocation(
          location,
          query.toLowerCase(),
        );
        if (distance < _levenshteinDistanceThreshold) {
          locations.add(LevenshteinObject(location, distance));
        }
        return locations;
      },
    );
  }

  int _levenshteinDistanceForLocation(
    TrufiLocation location,
    String query,
  ) {
    // Search in description
    final distance = _levenshteinDistanceForString(
      location.description.toLowerCase(),
      query,
    );

    // Return distance
    return distance;
  }

  int _levenshteinDistanceForString(
    String text,
    String query,
  ) {
    // Find match in text similar to query
    final position = _diffMatchPatch.match(text, query, 0);
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
    // final favoriteLocationsCubit = context.read<FavoriteLocationsCubit>();
    // locations.sort((a, b) {
    //   return sortByFavoriteLocations(a, b, favoriteLocationsCubit.locations);
    // });
    return locations;
  }
}

class LocationSearchData {
  LocationSearchData(this.places, this.streets);

  final List<TrufiLocation> places;
  final List<TrufiStreet> streets;
}

Future<LocationSearchData> loadFromAssets(
  String key,
) async {
  return compute(
    _parseSearchJson,
    await rootBundle.loadString(key),
  );
}

LocationSearchData _parseSearchJson(String encoded) {
  if (encoded.isNotEmpty) {
    try {
      final search = json.decode(encoded);
      // Places
      final places = search[keyPlaces]
          .map<TrufiLocation>(
            (dynamic json) =>
                TrufiLocation.fromSearchPlacesJson(json as List<dynamic>),
          )
          .toList() as List<TrufiLocation>;
      // Streets
      final streets = <String, TrufiStreet>{};
      search[keyStreets].keys.forEach((dynamic key) {
        streets[key as String] = TrufiStreet.fromSearchJson(
          search[keyStreets][key] as List<dynamic>,
        );
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
                  latitude: junction[1][1].toDouble() as double,
                  longitude: junction[1][0].toDouble() as double,
                ),
              );
            }
          });
          street1.junctions.sort(
            (TrufiStreetJunction a, TrufiStreetJunction b) {
              return a.description.compareTo(b.description);
            },
          );
        }
      });
      return LocationSearchData(places, streets.values.toList());
    } catch (e) {
      // ignore: avoid_print
      print('Failed to parse locations from JSON: $e');
    }
  }
  return LocationSearchData([], []);
}
