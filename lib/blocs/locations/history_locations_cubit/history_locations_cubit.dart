import 'package:meta/meta.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/locations/favorite_locations_cubit/favorite_locations_cubit.dart';
import 'package:trufi_core/repository/location_storage_repository/i_location_storage.dart';

import 'package:trufi_core/trufi_models.dart';
import 'package:equatable/equatable.dart';

part 'history_locations_state.dart';

class HistoryLocationsCubit extends Cubit<HistoryLocationsState> {
  final ILocationStorage locationStorage;
  HistoryLocationsCubit({
    @required this.locationStorage,
  }) : super(const HistoryLocationsState(locations: [])) {
    _initLoad();
  }

  Future<void> _initLoad() async {
    await locationStorage.load();
    emit(HistoryLocationsState(locations: [...locations]));
  }

  void _setLocations(List<TrufiLocation> location) {
    emit(state.copyWith(locations: [...location]));
  }

  void inAddLocation(TrufiLocation location) {
    locationStorage.addLocation(location);
    _setLocations(locations);
  }

  Future<void> inRemoveLocation(TrufiLocation location) async {
    locationStorage.removeLocation(location);
    _setLocations(locations);
  }

  Future<void> inReplaceLocation(Map<String, TrufiLocation> value) async {
    locationStorage.replaceLocation(value);
    _setLocations(locations);
  }

  // Getter

  List<TrufiLocation> get locations => locationStorage.getUnmodifiableListView();

  // Fetch

  Future<List<TrufiLocation>> fetch(FavoriteLocationsCubit favoriteLocation) async {
    return locationStorage.fetchLocations(favoriteLocation);
  }

  Future<List<LevenshteinObject>> fetchWithQuery(
    String query,
  ) async {
    return locationStorage.fetchLocationsWithQuery(query);
  }

  Future<List<TrufiLocation>> fetchWithLimit(
    FavoriteLocationsCubit favoriteLocation,
    int limit,
  ) async {
    return locationStorage.fetchLocationsWithLimit(limit, favoriteLocation);
  }
}
