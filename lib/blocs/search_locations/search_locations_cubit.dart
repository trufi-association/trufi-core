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
  final PlacesStorage myPlacesStorage = SharedPreferencesPlaceStorage("myPlacesStorage");
  final PlacesStorage myDefaultPlacesStorage =
      SharedPreferencesPlaceStorage("myDefaultPlacesStorage");
  final PlacesStorage historyPlacesStorage = SharedPreferencesPlaceStorage("historyPlacesStorage");
  final PlacesStorage favoritePlacesStorage =
      SharedPreferencesPlaceStorage("favoritePlacesStorage");

  final SearchLocationManager _offlineRequestManager;
  final _fetchLocationLock = Lock();
  CancelableOperation<List<TrufiPlace>> _fetchLocationOperation;

  SearchLocationsCubit(
    this._offlineRequestManager,
  ) : super(const SearchLocationsState(
            myPlaces: [], myDefaultPlaces: [], favoritePlaces: [], historyPlaces: [])) {
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
    emit(state.copyWith(historyPlaces: [...state.historyPlaces, location]));
    historyPlacesStorage.insert(location);
  }

  void insertFavoritePlace(TrufiLocation location) {
    emit(state.copyWith(favoritePlaces: [...state.favoritePlaces, location]));
    favoritePlacesStorage.insert(location);
  }

  void updateMyPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(
          myPlaces: [..._updateItem(state.myPlaces, old,location)]),
    );
    myPlacesStorage.update(old, location);
  }

  void updateMyDefaultPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(myDefaultPlaces: [..._updateItem(state.myDefaultPlaces, old, location)]),
    );
    myDefaultPlacesStorage.update(old, location);
  }

  void updateHistoryPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(historyPlaces: [
        ..._updateItem(state.historyPlaces, old,location)
      ]),
    );
    historyPlacesStorage.update(old, location);
  }

  void updateFavoritePlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(favoritePlaces: [
        ..._updateItem(state.favoritePlaces, old,location)
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

  Future<List<TrufiPlace>> getHistoryListWithLimit({int limit}) async {
    return state.historyPlaces.reversed.take(limit).toList();
  }

  Future<List<TrufiPlace>> fetchLocations(
    // FavoriteLocationsCubit favoriteLocationsCubit,
    LocationSearchBloc locationSearchBloc,
    String query, {
    String correlationId,
    int limit = 30,
  }) {
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
              // FIXME: For now we search locations always offline
              _offlineRequestManager.fetchLocations(locationSearchBloc, query,
                  limit: limit, correlationId: correlationId),
            );
            return _fetchLocationOperation.valueOrCancellation(null);
          });
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
}
