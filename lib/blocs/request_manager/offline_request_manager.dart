import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/request_manager_bloc.dart';
import 'package:trufi_app/blocs/search_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class OfflineRequestManager implements RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
    int limit,
  ) async {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    final placeLocationsBloc = PlaceLocationsBloc.of(context);
    final searchLocationsBloc = SearchLocationsBloc.of(context);
    // Search in places and locations
    final levenshteinObjects = (await Future.wait([
      placeLocationsBloc.fetchWithQuery(context, query), // High priority
      searchLocationsBloc.fetchWithQuery(context, query), // Low priority
    ]))
        .expand((levenshteinObjects) => levenshteinObjects) // Concat lists
        .toList();
    // Sort by levenshtein
    levenshteinObjects.sort((a, b) => a.distance.compareTo(b.distance));
    // Cutoff by limit
    if (levenshteinObjects.length > limit) {
      levenshteinObjects.removeRange(limit, levenshteinObjects.length);
    }
    // Remove levenshtein
    final objects = levenshteinObjects.map((l) => l.object).toList();
    // Favorites to the top
    objects.sort((a, b) {
      return sortByFavoriteLocations(
        a,
        b,
        favoriteLocationsBloc.locations,
      );
    });
    // Return result
    return objects;
  }

  Future<Plan> fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) async {
    throw FetchOfflineRequestException(
      Exception("Fetch plan offline is not implemented yet."),
    );
  }
}
