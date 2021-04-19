import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/location/location_search_storage.dart';

import '../../blocs/favorite_locations_bloc.dart';
import '../../blocs/location_search_bloc.dart';
import '../../blocs/request_manager_bloc.dart';
import '../../trufi_models.dart';

class OfflineRequestManager implements RequestManager {
  @override
  Future<List<TrufiPlace>> fetchLocations(
    FavoriteLocationsBloc favoriteLocationsBloc,
    LocationSearchBloc locationSearchBloc,
    TrufiPreferencesBloc preferencesBloc,
    String query, {
    int limit = 30,
  }) async {
    final LocationSearchStorage storage = locationSearchBloc.storage;

    final queryPlaces = await storage.fetchPlacesWithQuery(query);
    final queryStreets = await storage.fetchStreetsWithQuery(query);

    // Combine Places and Street sort by distance
    final List<LevenshteinObject<TrufiPlace>> sortedLevenshteinObjects = [
      ...queryPlaces, // High priority
      ...queryStreets // Low priority
    ]..sort((a, b) => a.distance.compareTo(b.distance));

    // Remove levenshteinObject
    final List<TrufiPlace> trufiPlaces = sortedLevenshteinObjects
        .take(limit)
        .map((LevenshteinObject<TrufiPlace> l) => l.object)
        .toList();

    // sort with street priority
    mergeSort(trufiPlaces, compare: (a, b) => (a is TrufiStreet) ? -1 : 1);

    // Favorites to the top
    mergeSort(trufiPlaces, compare: (a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });

    return trufiPlaces;
  }

  @override
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

  @override
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

  @override
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
