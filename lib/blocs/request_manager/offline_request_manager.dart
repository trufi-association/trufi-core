import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../blocs/favorite_locations_bloc.dart';
import '../../blocs/location_search_bloc.dart';
import '../../blocs/request_manager_bloc.dart';
import '../../trufi_models.dart';

class OfflineRequestManager implements RequestManager {
  Future<List<dynamic>> fetchLocations(
    BuildContext context,
    String query,
    int limit,
  ) async {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    final locationSearchBloc = LocationSearchBloc.of(context);
    // Search in places and streets
    final levenshteinObjects = (await Future.wait([
      locationSearchBloc.fetchPlacesWithQuery(context, query), // High priority
      locationSearchBloc.fetchStreetsWithQuery(context, query), // Low priority
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
    // sort with street priority
    mergeSort(objects, compare: (a, b) => (a is TrufiStreet) ? -1 : 1);
    // Favorites to the top
    mergeSort(objects, compare: (a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    // Return result
    return objects;
  }

  CancelableOperation<Plan> fetchTransitPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return CancelableOperation.fromFuture(() async {
      throw FetchOfflineRequestException(
        Exception("Fetch plan offline is not implemented yet."),
      );
    }());
  }

  CancelableOperation<Plan> fetchCarPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) {
    return CancelableOperation.fromFuture(() async {
      throw FetchOfflineRequestException(
        Exception("Fetch plan as car route offline is not implemented yet."),
      );
    }());
  }

  CancelableOperation<Ad> fetchAd(
    BuildContext context,
    TrufiLocation to,
  ) {
    return CancelableOperation.fromFuture(() async {
      throw FetchOfflineRequestException(
        Exception("Fetch ad offline is not implemented yet."),
      );
    }());
  }
}
