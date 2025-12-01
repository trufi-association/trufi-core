import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:trufi_core/base/models/trufi_place.dart';

const String keyPlaces = 'pois';
const String keyStreets = 'streets';
const String keyStreetJunctions = 'streetJunctions';

class LocationSearchStorage {
  static const _levenshteinDistanceThreshold = 3;

  final _places = <TrufiLocation>[];
  final _streets = <TrufiStreet>[];

  Future<void> load(String key) async {
    _places.clear();
    _streets.clear();
    try {
      final locationData = await loadFromAssets(key);
      // _places.addAll(locationData.places);
      _streets.addAll(locationData.streets);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<List<LevenshteinObject<TrufiStreet>>> fetchStreetsWithQuery(
      String query) async {
    final listValues = splitString(query, 3);

    return _streets.fold<List<LevenshteinObject<TrufiStreet>>>(
      [],
      (streets, street) {
        final distance = getDistance(
          street.location,
          listValues,
          query.length,
        );
        if (distance < _levenshteinDistanceThreshold) {
          streets.add(LevenshteinObject(street, distance));
        }
        return streets;
      },
    );
  }

  int getDistance(
    TrufiLocation location,
    List<String> querySplited,
    int queryLength,
  ) {
    final direction = location.description.toLowerCase();
    // log(address.description);
    for (final sectionQuery in querySplited) {
      if (direction.contains(sectionQuery)) {
        // results.add(address);
        return queryLength - sectionQuery.length;
      }
    }
    return 100;
  }

  List<TrufiLocation> search(
      TrufiLocation location, List<String> querySplited, String query) {
    // if (query.length < 3) {
    //   // If the query is less than 3 characters, return all addresses.
    //   return _places;
    // }

    final results = <TrufiLocation>[];

    for (final address in _places) {
      final direction = address.description.toLowerCase();
      // log(address.description);
      for (final word in querySplited) {
        if (direction.contains(word)) {
          results.add(address);
          break; // Break out of the inner loop to avoid duplicate entries.
        }
      }
    }
    results.forEach((element) => log(element.description));

    return results;
  }

  List<String> splitString(String input, int minLength) {
    final List<String> substrings = [];

    void recursiveSplit(String str) {
      if (str.length < minLength) {
        return;
      }

      substrings.add(str);

      if (str.length > minLength) {
        recursiveSplit(str.substring(0, str.length - 1));
      }
    }

    recursiveSplit(input);

    return substrings;
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
      debugPrint('Failed to parse locations from JSON: $e');
    }
  }
  return LocationSearchData([], []);
}
