import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import '../../models/search_location.dart';
import '../../services/search_location_service.dart';
import '../repository/search_locations_repository.dart';
import '../repository/search_locations_repository_impl.dart';

part 'search_locations_state.dart';

/// Cubit for managing location search and saved places.
///
/// Uses [SearchLocationService] for search operations and reverse geocoding,
/// and [SearchLocationsRepository] for persisting saved places.
///
/// If [localRepository] is not provided, uses [SearchLocationsRepositoryImpl] by default.
class SearchLocationsCubit extends Cubit<SearchLocationsState> {
  final SearchLocationsRepository _localRepository;
  final SearchLocationService searchLocationService;
  Timer _debounceTimer = Timer(const Duration(milliseconds: 300), () {});

  SearchLocationsCubit({
    required this.searchLocationService,
    SearchLocationsRepository? localRepository,
  })  : _localRepository = localRepository ?? SearchLocationsRepositoryImpl(),
        super(const SearchLocationsState()) {
    _initLoad();
  }

  Future<void> _initLoad() async {
    await _localRepository.loadRepository();
    List<TrufiLocation> myDefaultPlaces =
        await _localRepository.getMyDefaultPlaces();
    if (myDefaultPlaces.isEmpty) {
      myDefaultPlaces = [
        DefaultLocation.defaultHome.initLocation,
        DefaultLocation.defaultWork.initLocation,
      ];
    }
    emit(state.copyWith(
      myPlaces: await _localRepository.getMyPlaces(),
      myDefaultPlaces: myDefaultPlaces,
      favoritePlaces: await _localRepository.getFavoritePlaces(),
      historyPlaces: await _localRepository.getHistoryPlaces(),
    ));
    await _localRepository.saveMyDefaultPlaces(state.myDefaultPlaces);
  }

  // ============ Search Operations ============

  /// Search for locations matching the query.
  ///
  /// Results are debounced to avoid excessive API calls.
  Future<void> search(String query) async {
    _debounceTimer.cancel();
    emit(state.copyWith(isLoading: true));

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (query.isNotEmpty) {
        try {
          final results = await searchLocationService.search(query);
          emit(state.copyWith(
            searchResult: results,
            isLoading: false,
          ));
        } on SearchLocationException {
          emit(state.copyWith(searchResult: [], isLoading: false));
        }
      } else {
        emit(state.copyWith(searchResult: [], isLoading: false));
      }
    });
  }

  /// Reverse geocode: find location name from coordinates.
  Future<SearchLocation?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    return searchLocationService.reverse(latitude, longitude);
  }

  /// Clear search results.
  void clearSearchResults() {
    emit(state.copyWith(searchResult: []));
  }

  // ============ My Places Operations ============

  void insertMyPlace(TrufiLocation location) {
    emit(state.copyWith(myPlaces: [...state.myPlaces, location]));
    _localRepository.saveMyPlaces(state.myPlaces);
  }

  void updateMyPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(myPlaces: [..._updateItem(state.myPlaces, old, location)]),
    );
    _localRepository.saveMyPlaces(state.myPlaces);
  }

  void deleteMyPlace(TrufiLocation location) {
    emit(state.copyWith(
      myPlaces: _deleteItem(state.myPlaces, location),
    ));
    _localRepository.saveMyPlaces(state.myPlaces);
  }

  // ============ My Default Places Operations ============

  void updateMyDefaultPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(myDefaultPlaces: [
        ..._updateItem(state.myDefaultPlaces, old, location)
      ]),
    );
    _localRepository.saveMyDefaultPlaces(state.myDefaultPlaces);
  }

  // ============ History Operations ============

  void insertHistoryPlace(TrufiLocation location) {
    emit(state.copyWith(historyPlaces: [
      ..._deleteAllItem(state.historyPlaces, location),
      location,
    ]));
    _localRepository.saveHistoryPlaces(state.historyPlaces);
  }

  void updateHistoryPlace(TrufiLocation old, TrufiLocation location) {
    emit(
      state.copyWith(
          historyPlaces: [..._updateItem(state.historyPlaces, old, location)]),
    );
    _localRepository.saveHistoryPlaces(state.historyPlaces);
  }

  void deleteHistoryPlace(TrufiLocation location) {
    emit(state.copyWith(
      historyPlaces: _deleteItem(state.historyPlaces, location),
    ));
    _localRepository.saveHistoryPlaces(state.historyPlaces);
  }

  List<TrufiLocation> getHistoryList() {
    return state.historyPlaces.reversed.toList();
  }

  // ============ Favorite Operations ============

  void insertFavoritePlace(TrufiLocation location) {
    emit(state.copyWith(favoritePlaces: [...state.favoritePlaces, location]));
    _localRepository.saveFavoritePlaces(state.favoritePlaces);
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
    _localRepository.saveFavoritePlaces(state.favoritePlaces);
  }

  void deleteFavoritePlace(TrufiLocation location) {
    emit(state.copyWith(
      favoritePlaces: _deleteItem(state.favoritePlaces, location),
    ));
    _localRepository.saveFavoritePlaces(state.favoritePlaces);
  }

  bool isFavorite(TrufiLocation location) {
    return state.favoritePlaces.contains(location);
  }

  // ============ Utility Methods ============

  /// Sort locations by favorites first.
  List<SearchLocation> sortedByFavorites(List<SearchLocation> locations) {
    final favoriteCoords = state.favoritePlaces
        .map((f) => '${f.latitude},${f.longitude}')
        .toSet();

    locations.sort((a, b) {
      final aIsFavorite =
          favoriteCoords.contains('${a.latitude},${a.longitude}');
      final bIsFavorite =
          favoriteCoords.contains('${b.latitude},${b.longitude}');
      return aIsFavorite == bIsFavorite
          ? 0
          : aIsFavorite
              ? -1
              : 1;
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

  @override
  Future<void> close() async {
    _debounceTimer.cancel();
    searchLocationService.dispose();
    await _localRepository.dispose();
    return super.close();
  }
}
