import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/location/location_search_storage.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_models.dart';

class OfflineRepository implements RequestManager {
  @override
  Future<List<TrufiPlace>> fetchLocations(
    FavoriteLocationsBloc favoriteLocationsBloc,
    LocationSearchBloc locationSearchBloc,
    String query, {
    String correlationId,
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
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return CancelableOperation.fromFuture(() async {
      throw FetchOfflineRequestException(
        Exception("Fetch plan offline is not implemented yet."),
      );
    }());
  }

  @override
  CancelableOperation<Plan> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  ) {
    return CancelableOperation.fromFuture(() async {
      throw FetchOfflineRequestException(
        Exception("Fetch plan as car route offline is not implemented yet."),
      );
    }());
  }

  @override
  CancelableOperation<Ad> fetchAd(
    TrufiLocation to,
    String correlationId,
  ) {
    return CancelableOperation.fromFuture(() async {
      throw FetchOfflineRequestException(
        Exception("Fetch ad offline is not implemented yet."),
      );
    }());
  }
}
