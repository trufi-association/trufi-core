import 'package:meta/meta.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized/synchronized.dart';
// import 'package:trufi_core/blocs/locations/favorite_locations_cubit/favorite_locations_cubit.dart';
import 'package:trufi_core/services/search_location/search_location_manager.dart';

import 'package:async/async.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:equatable/equatable.dart';

import '../location_search_bloc.dart';

part 'search_locations_state.dart';

abstract class PlacesStorage {
  final String id;

  PlacesStorage(this.id);

  Future<void> insert(TrufiLocation location);
  Future<void> delete(TrufiLocation location);
  Future<void> update(TrufiLocation old, TrufiLocation location);
  Future<List<TrufiLocation>> all();
}

class RamPlaceStorage extends PlacesStorage {
  final List<TrufiLocation> _places = [];

  RamPlaceStorage(String id) : super(id);

  @override
  Future<void> delete(TrufiLocation location) async {
    _places.remove(location);
  }

  @override
  Future<void> insert(TrufiLocation location) async {
    _places.add(location);
  }

  @override
  Future<void> update(TrufiLocation old, TrufiLocation location) async {
    _places.remove(location);
    _places.add(location);
  }

  @override
  Future<List<TrufiLocation>> all() async {
    return _places;
  }
}

class SearchLocationsCubit extends Cubit<SearchLocationsState> {
  final PlacesStorage myPlacesStorage = RamPlaceStorage("");
  final PlacesStorage historyPlacesStorage = RamPlaceStorage("");
  final PlacesStorage favoritePlacesStorage = RamPlaceStorage("");

  final SearchLocationManager _offlineRequestManager;
  final _fetchLocationLock = Lock();
  CancelableOperation<List<TrufiPlace>> _fetchLocationOperation;

  SearchLocationsCubit(
    this._offlineRequestManager,
  ) : super(const SearchLocationsState(
            myPlaces: [], favoritePlaces: [], historyPlaces: [])) {
    _initLoad();
  }

  Future<void> _initLoad() async {
    emit(state.copyWith(
      myPlaces: await myPlacesStorage.all(),
      historyPlaces: await historyPlacesStorage.all(),
      favoritePlaces: await favoritePlacesStorage.all(),
    ));
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
    emit(state.copyWith(myPlaces: [...state.myPlaces, location]));
    myPlacesStorage.update(old, location);
  }

  void updateHistoryPlace(TrufiLocation old, TrufiLocation location) {
    emit(state.copyWith(historyPlaces: [...state.historyPlaces, location]));
    historyPlacesStorage.update(old, location);
  }

  void updateFavoritePlace(TrufiLocation old, TrufiLocation location) {
    emit(state.copyWith(favoritePlaces: [...state.favoritePlaces, location]));
    favoritePlacesStorage.update(old, location);
  }

  void deleteMyPlace(TrufiLocation location) {
    state.myPlaces.remove(location);
    emit(state.copyWith(myPlaces: [...state.myPlaces]));
    myPlacesStorage.delete(location);
  }

  void deleteHistoryPlace(TrufiLocation location) {
    state.historyPlaces.remove(location);
    emit(state.copyWith(historyPlaces: [...state.historyPlaces]));
    historyPlacesStorage.delete(location);
  }

  void deleteFavoritePlace(TrufiLocation location) {
    state.favoritePlaces.remove(location);
    emit(state.copyWith(favoritePlaces: []));
    favoritePlacesStorage.delete(location);
  }

  Future<List<TrufiPlace>> getHistoryList({int limit}) async {
    return state.historyPlaces.toList();
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
}
