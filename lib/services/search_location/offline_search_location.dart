import 'dart:async';

import 'package:collection/collection.dart';
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/blocs/locations/favorite_locations_cubit/favorite_locations_cubit.dart';
import 'package:trufi_core/location/location_search_storage.dart';
import 'package:trufi_core/repository/location_storage_repository/location_storage.dart';
import 'package:trufi_core/trufi_models.dart';

import 'search_location_manager.dart';

class OfflineSearchLocation implements SearchLocationManager {
  @override
  Future<List<TrufiPlace>> fetchLocations(
    FavoriteLocationsCubit favoriteLocationsCubit,
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
      return sortByFavoriteLocations(a, b, favoriteLocationsCubit.locations);
    });

    return trufiPlaces;
  }
}
