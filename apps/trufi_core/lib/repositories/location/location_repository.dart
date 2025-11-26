import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/consts.dart';
import 'package:trufi_core/repositories/location/interfaces/i_location_search_service.dart';
import 'package:trufi_core/repositories/location/interfaces/i_location_service.dart';
import 'package:trufi_core/repositories/location/models/defaults_location.dart';
import 'package:trufi_core/repositories/location/services/storage_location_service.dart';
import 'package:trufi_core/repositories/storage/shared_preferences_storage.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class LocationRepository {
  final ILocationService locationService = 
      StorageLocationService(SharedPreferencesStorage());

  final ILocationSearchService locationSearchService =
      ApiConfig().locationSearchService;

  LocationRepository()
    : myPlaces = ValueNotifier([]),
      myDefaultPlaces = ValueNotifier([]),
      historyPlaces = ValueNotifier([]),
      favoritePlaces = ValueNotifier([]),
      searchResult = ValueNotifier(null),
      isLoading = ValueNotifier(false);

  final ValueNotifier<List<TrufiLocation>> myPlaces;
  final ValueNotifier<List<TrufiLocation>> myDefaultPlaces;
  final ValueNotifier<List<TrufiLocation>> historyPlaces;
  final ValueNotifier<List<TrufiLocation>> favoritePlaces;
  final ValueNotifier<List<TrufiLocation>?> searchResult;
  final ValueNotifier<bool> isLoading;

  CancelableOperation<List<TrufiLocation>>? _fetchLocationOperation;
  int _lastIssuedToken = 0;

  Future<void> fetchLocations(String query, {int limit = 30}) async {
    final normalized = query.trim().toLowerCase();

    // If the query is empty, cancel any running operation,
    // reset state and return early.
    if (normalized.isEmpty) {
      await _fetchLocationOperation?.cancel();
      _fetchLocationOperation = null;
      searchResult.value = null;
      isLoading.value = false;
      return;
    }

    // Increment the request token.
    // Only the result of the request with the latest token
    // will be considered valid (last-write-wins).
    final myToken = ++_lastIssuedToken;
    isLoading.value = true;

    // Cancel any running operation before starting a new one.
    await _fetchLocationOperation?.cancel();
    _fetchLocationOperation = null;

    // Wrap the async fetch in a CancelableOperation.
    // This allows us to cancel/ignore previous requests.
    _fetchLocationOperation =
        CancelableOperation<List<TrufiLocation>>.fromFuture(
          locationSearchService.fetchLocations(query, limit: limit),
          onCancel: () {
            // Here you could add real network cancellation if your
            // HTTP client supports it (e.g. Dio's CancelToken).
          },
        );

    try {
      // Wait for the result of the fetch.
      final result = await _fetchLocationOperation!.value;

      // If this request is no longer the latest (token mismatch),
      // ignore the result and reset state.
      if (myToken != _lastIssuedToken) {
        searchResult.value = null;
        isLoading.value = false;
        return;
      }

      // Otherwise, update the searchResult with the fresh data.
      searchResult.value = result;
      isLoading.value = false;
      return;
    } catch (e) {
      // In case of error, also respect the token check.
      // Only update state if this is still the latest request.
      if (myToken != _lastIssuedToken) {
        searchResult.value = null;
        isLoading.value = false;
        return;
      }

      // If it is the latest request, set searchResult to empty list
      // to indicate an error occurred but the search is complete.
      searchResult.value = <TrufiLocation>[];
      isLoading.value = false;
      return;
    } finally {
      // Clear the reference if this was the latest request,
      // so a new fetch can be scheduled safely.
      if (myToken == _lastIssuedToken) {
        _fetchLocationOperation = null;
      }
    }
  }

  Future<TrufiLocation> reverseGeodecoding(LatLng location) =>
      locationSearchService.reverseGeodecoding(location);

  Future<void> initLoad() async {
    await locationService.loadRepository();
    List<TrufiLocation> myDefaultPlacesTemp = await locationService
        .getMyDefaultPlaces();
    if (myDefaultPlacesTemp.isEmpty) {
      myDefaultPlaces.value = [
        DefaultLocationEnum.home.initLocation,
        DefaultLocationEnum.work.initLocation,
      ];
      await locationService.saveMyDefaultPlaces(myDefaultPlaces.value);
    } else {
      myDefaultPlaces.value = myDefaultPlacesTemp;
    }
    myPlaces.value = await locationService.getMyPlaces();
    favoritePlaces.value = await locationService.getFavoritePlaces();
    historyPlaces.value = await locationService.getHistoryPlaces();
  }

  Future<void> insertMyPlace(TrufiLocation location) async {
    myPlaces.value = [...myPlaces.value, location];
    await locationService.saveMyPlaces(myPlaces.value);
  }

  Future<void> insertHistoryPlace(TrufiLocation location) async {
    historyPlaces.value = [
      ..._deleteAllItem(historyPlaces.value, location),
      location,
    ];
    await locationService.saveHistoryPlaces(historyPlaces.value);
  }

  Future<void> insertFavoritePlace(TrufiLocation location) async {
    favoritePlaces.value = [...favoritePlaces.value, location];
    await locationService.saveFavoritePlaces(favoritePlaces.value);
  }

  Future<void> updateMyPlace(TrufiLocation old, TrufiLocation location) async {
    myPlaces.value = [..._updateItem(myPlaces.value, old, location)];
    await locationService.saveMyPlaces(myPlaces.value);
  }

  Future<void> updateMyDefaultPlace(
    TrufiLocation old,
    TrufiLocation location,
  ) async {
    myDefaultPlaces.value = [
      ..._updateItem(myDefaultPlaces.value, old, location),
    ];
    await locationService.saveMyDefaultPlaces(myDefaultPlaces.value);
  }

  Future<void> updateHistoryPlace(
    TrufiLocation old,
    TrufiLocation location,
  ) async {
    historyPlaces.value = [..._updateItem(historyPlaces.value, old, location)];
    await locationService.saveHistoryPlaces(historyPlaces.value);
  }

  Future<void> updateFavoritePlace(
    TrufiLocation old,
    TrufiLocation location,
  ) async {
    favoritePlaces.value = [
      ..._updateItem(favoritePlaces.value, old, location),
    ];
    await locationService.saveFavoritePlaces(favoritePlaces.value);
  }

  List<TrufiLocation> _updateItem(
    List<TrufiLocation> list,
    TrufiLocation oldLocation,
    TrufiLocation newLocation,
  ) {
    final tempList = [...list];
    final int index = tempList.indexOf(oldLocation);
    if (index != -1) {
      tempList.replaceRange(index, index + 1, [newLocation]);
    }
    return tempList;
  }

  Future<void> deleteMyPlace(TrufiLocation location) async {
    myPlaces.value = [..._deleteItem(myPlaces.value, location)];
    await locationService.saveMyPlaces(myPlaces.value);
  }

  Future<void> deleteHistoryPlace(TrufiLocation location) async {
    historyPlaces.value = [..._deleteItem(historyPlaces.value, location)];
    await locationService.saveHistoryPlaces(historyPlaces.value);
  }

  Future<void> deleteFavoritePlace(TrufiLocation location) async {
    favoritePlaces.value = [..._deleteItem(favoritePlaces.value, location)];
    await locationService.saveFavoritePlaces(favoritePlaces.value);
  }

  List<TrufiLocation> sortedByFavorites(List<TrufiLocation> locations) {
    locations.sort((a, b) {
      return _sortByFavoriteLocations(a, b, favoritePlaces.value);
    });
    return locations;
  }

  int _sortByFavoriteLocations(
    TrufiLocation a,
    TrufiLocation b,
    List<TrufiLocation> favorites,
  ) {
    final bool aIsAvailable = favorites.contains(a);
    final bool bIsAvailable = favorites.contains(b);
    return aIsAvailable == bIsAvailable
        ? 0
        : aIsAvailable
        ? -1
        : 1;
  }

  List<TrufiLocation> _deleteItem(
    List<TrufiLocation> list,
    TrufiLocation location,
  ) {
    final tempList = [...list];
    tempList.remove(location);
    return tempList;
  }

  List<TrufiLocation> _deleteAllItem(
    List<TrufiLocation> list,
    TrufiLocation location,
  ) {
    final tempList = [...list];
    return tempList.where((value) => value != location).toList();
  }
}
