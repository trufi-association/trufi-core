import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/important_locations_bloc.dart';
import 'package:trufi_app/blocs/offline_locations_bloc.dart';
import 'package:trufi_app/blocs/request_manager_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class OfflineRequestManager implements RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
    int limit,
  ) async {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    final offlineLocationsBloc = OfflineLocationsBloc.of(context);
    final placeLocationsBloc = ImportantLocationsBloc.of(context);
    // Search in places and locations
    final locations = (await Future.wait([
      placeLocationsBloc.fetchWithQuery(context, query), // High priority
      offlineLocationsBloc.fetchWithQuery(context, query), // Low priority
    ]))
        .expand((locations) => locations) // Concat lists
        .toList();
    // Sort by levenshtein
    locations.sort((a, b) => a.distance.compareTo(b.distance));
    // Cutoff by limit
    if (locations.length > limit) {
      locations.removeRange(limit, locations.length);
    }
    // Favorites to the top
    locations.sort((a, b) {
      return sortByFavoriteLocations(
        a.location,
        b.location,
        favoriteLocationsBloc.locations,
      );
    });
    return locations.map((location) => location.location).toList();
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
