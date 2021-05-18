import 'package:meta/meta.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:trufi_core/models/enums/defaults_location.dart';
import 'package:trufi_core/repository/places_store_repository/places_storage.dart';
import 'package:trufi_core/repository/places_store_repository/shared_preferences_place_storage.dart';
import 'package:trufi_core/services/search_location/search_location_manager.dart';

import 'package:async/async.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:equatable/equatable.dart';

import '../location_search_bloc.dart';

part 'search_locations_state.dart';

class SearchLocationsCubit extends Cubit<SearchLocationsState> {
  final PlacesStorage myPlacesStorage =
      SharedPreferencesPlaceStorage("myPlacesStorage");
  final PlacesStorage myDefaultPlacesStorage =
      SharedPreferencesPlaceStorage("myDefaultPlacesStorage");
  final PlacesStorage historyPlacesStorage =
      SharedPreferencesPlaceStorage("historyPlacesStorage");
  final PlacesStorage favoritePlacesStorage =
      SharedPreferencesPlaceStorage("favoritePlacesStorage");

  final SearchLocationManager _searchLocationManager;
  final _fetchLocationLock = Lock();
  CancelableOperation<List<TrufiPlace>> _fetchLocationOperation;

  SearchLocationsCubit(
    this._searchLocationManager,
  ) : super(const SearchLocationsState(
            myPlaces: [],
            myDefaultPlaces: [],
            favoritePlaces: [],
            historyPlaces: [])) {
    _initLoad();
  }

  Future<void> _initLoad() async {
    emit(state.copyWith(
      myPlaces: await myPlacesStorage.all(),
      myDefaultPlaces: await _initDefaultPlaces(),
      historyPlaces: await historyPlacesStorage.all(),
      favoritePlaces: await favoritePlacesStorage.all(),
    ));
  }

  Future<List<TrufiLocation>> _initDefaultPlaces() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.get('saved_places_initialized') == null) {
      myDefaultPlacesStorage.insert(DefaultLocation.defaultHome.initLocation);
      myDefaultPlacesStorage.insert(DefaultLocation.defaultWork.initLocation);
    }
    preferences.setBool('saved_places_initialized', true);
    return myDefaultPlacesStorage.all();
  }

  void insertMyPlace(TrufiLocation location) {
    emit(state.copyWith(myPlaces: [...state.myPlaces, location]));
    myPlacesStorage.insert(location);
  }

  void insertHistoryPlace(TrufiLocation location) {
    emit(state.copyWith(historyPlaces: [
      ..._deleteAllItem(state.historyPlaces, location),
      location,
    ]));
    historyPlacesStorage.replace(location);
  }

  void insertFavoritePlace(TrufiLocation location) {
    emit(state.copyWith(favoritePlaces: [...state.favoritePlaces, location]));
    favoritePlacesStorage.insert(location);
  }

  void updateMyPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(myPlaces: [..._updateItem(state.myPlaces, old, location)]),
    );
    myPlacesStorage.update(old, location);
  }

  void updateMyDefaultPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(myDefaultPlaces: [
        ..._updateItem(state.myDefaultPlaces, old, location)
      ]),
    );
    myDefaultPlacesStorage.update(old, location);
  }

  void updateHistoryPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(
          historyPlaces: [..._updateItem(state.historyPlaces, old, location)]),
    );
    historyPlacesStorage.update(old, location);
  }

  void updateFavoritePlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(favoritePlaces: [
        ..._updateItem(
          state.favoritePlaces,
          old,
          location,
        )
      ]),
    );
    favoritePlacesStorage.update(old, location);
  }

  void deleteMyPlace(TrufiLocation location) {
    emit(state.copyWith(
      myPlaces: _deleteItem(state.myPlaces, location),
    ));
    myPlacesStorage.delete(location);
  }

  void deleteHistoryPlace(TrufiLocation location) {
    emit(state.copyWith(
      historyPlaces: _deleteItem(state.historyPlaces, location),
    ));
    historyPlacesStorage.delete(location);
  }

  void deleteFavoritePlace(TrufiLocation location) {
    emit(state.copyWith(
      favoritePlaces: _deleteItem(state.favoritePlaces, location),
    ));
    favoritePlacesStorage.delete(location);
  }

  List<TrufiPlace> getHistoryList() {
    return state.historyPlaces.reversed.toList();
  }

  Future<List<TrufiPlace>> fetchLocations(
    LocationSearchBloc locationSearchBloc,
    String query, {
    String correlationId,
    int limit = 30,
  }) async {
    // Cancel running operation
    if (_fetchLocationOperation != null) {
      _fetchLocationOperation.cancel();
      _fetchLocationOperation = null;
    }

    // Allow only one running request
    return (_fetchLocationLock.locked)
        ? Future.value()
        : _fetchLocationLock.synchronized(() async {
            _fetchLocationOperation =
                CancelableOperation<List<TrufiPlace>>.fromFuture(
              _searchLocationManager.fetchLocations(
                locationSearchBloc,
                query,
                limit: limit,
                correlationId: correlationId,
              ),
            );
            return _fetchLocationOperation.valueOrCancellation(null);
          });
  }

  List<TrufiPlace> sortedByFavorites(
    List<TrufiPlace> locations,
  ) {
    locations.sort((a, b) {
      return _sortByFavoriteLocations(a, b, state.favoritePlaces);
    });
    return locations;
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

  int _sortByFavoriteLocations(
    TrufiPlace a,
    TrufiPlace b,
    List<TrufiLocation> favorites,
  ) {
    return _sortByLocations(a, b, favorites);
  }

  int _sortByLocations(
      TrufiPlace a, TrufiPlace b, List<TrufiLocation> locations) {
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
