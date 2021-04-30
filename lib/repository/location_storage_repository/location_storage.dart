import 'dart:collection';
import 'dart:math';

import 'package:diff_match_patch/diff_match_patch.dart';

import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/trufi_models.dart';

import 'i_location_storage.dart';

abstract class LocationStorage implements ILocationStorage {
  LocationStorage();

  DiffMatchPatch diffMatchPatch = DiffMatchPatch();

  final List<TrufiLocation> locations = [];

  @override
  Future<bool> load();

  @override
  Future<bool> save();

  @override
  void addLocation(TrufiLocation location) {
    removeLocation(location);
    locations.insert(0, location);
    save();
  }

  @override
  bool containsLocation(
    TrufiLocation location,
  ) {
    return locations.contains(location);
  }

  @override
  Future<List<TrufiLocation>> fetchLocations(
    FavoriteLocationsBloc favoriteLocationsBloc,
  ) async {
    return _sortedByFavorites(locations.toList(), favoriteLocationsBloc);
  }

  @override
  Future<List<TrufiLocation>> fetchLocationsWithLimit(
    int limit,
    FavoriteLocationsBloc favoriteLocationsBloc,
  ) async {
    return _sortedByFavorites(
      locations.sublist(0, min(locations.length, limit)),
      favoriteLocationsBloc,
    );
  }

  @override
  Future<List<LevenshteinObject>> fetchLocationsWithQuery(String query) async {
    final fold = locations.fold<List<LevenshteinObject>>(
      <LevenshteinObject>[],
      (locations, location) {
        final int distance = _findMatchAndCalculateStringDistance(
          location.description.toLowerCase(),
          query.toLowerCase(),
        );
        if (distance < 3) {
          locations.add(LevenshteinObject(location, distance));
        }
        return locations;
      },
    );
    return fold;
  }

  @override
  UnmodifiableListView<TrufiLocation> getUnmodifiableListView() {
    return UnmodifiableListView(locations);
  }

  @override
  void removeLocation(TrufiLocation location) {
    locations.remove(location);
    save();
  }

  @override
  void replaceLocation(Map<String, TrufiLocation> data) {
    final TrufiLocation oldLocation = data['oldLocation'];
    final TrufiLocation newLocation = data['newLocation'];
    final int indexLocation = locations.indexOf(oldLocation);
    locations[indexLocation] = newLocation;
    save();
  }

  int _findMatchAndCalculateStringDistance(String text, String query) {
    // Find match in text similar to query
    final position = diffMatchPatch.match(text, query, 0);
    // If match found, calculate levenshtein distance
    if (position != -1 && position < text.length) {
      return position + query.length + 1 <= text.length
          ? diffMatchPatch.diff_levenshtein(
              diffMatchPatch.diff(
                text.substring(position, position + query.length + 1),
                query,
              ),
            )
          : diffMatchPatch.diff_levenshtein(
              diffMatchPatch.diff(
                text.substring(position),
                query,
              ),
            );
    } else {
      // If no match found, return distance 100
      return 100;
    }
  }

  List<TrufiLocation> _sortedByFavorites(
    List<TrufiLocation> locations,
    FavoriteLocationsBloc favoriteLocationsBloc,
  ) {
    locations.sort((a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
  }

  int sortByFavoriteLocations(dynamic a, dynamic b, List<TrufiLocation> favorites) {
    return sortByLocations(a, b, favorites);
  }

  int sortByLocations(dynamic a, dynamic b, List<TrufiLocation> locations) {
    final bool aIsAvailable = (a is TrufiLocation)
        ? locations.contains(a)
        // TODO: Fix Linting problem with tests
        // ignore: avoid_bool_literals_in_conditional_expressions
        : (a is TrufiStreet)
            ? a.junctions.fold<bool>(
                false,
                (result, j) => result |= locations.contains(j.location),
              )
            : false;
    final bool bIsAvailable = (b is TrufiLocation)
        ? locations.contains(b)
        // TODO: Fix Linting problem with tests
        // ignore: avoid_bool_literals_in_conditional_expressions
        : (b is TrufiStreet)
            ? b.junctions.fold<bool>(
                false,
                (result, j) => result |= locations.contains(j.location),
              )
            : false;
    return aIsAvailable == bIsAvailable
        ? 0
        : aIsAvailable
            ? -1
            : 1;
  }
}
