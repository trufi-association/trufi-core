import 'package:meta/meta.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core/blocs/locations/favorite_locations_cubit/favorite_locations_cubit.dart';
import 'package:trufi_core/repository/location_storage_repository/i_location_storage.dart';

import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:equatable/equatable.dart';


part 'saved_places_locations_state.dart';

class SavedPLacesLocationsCubit extends Cubit<SavedPlacesLocationsState> {
  final ILocationStorage locationStorage;

  SavedPLacesLocationsCubit({
    @required this.locationStorage,
  }) : super(const SavedPlacesLocationsState(locations: [])) {
    _initSavedPage();
  }

  Future<void> _initSavedPage() async {
    await locationStorage.load();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.get('saved_places_initialized') == null) {
      final LatLng _center = TrufiConfiguration().map.center;
      locationStorage.addLocation(TrufiLocation(
          description: 'Home',
          latitude: _center.latitude,
          longitude: _center.longitude,
          type: 'saved_place:home'));
      locationStorage.addLocation(TrufiLocation(
          description: 'Work',
          latitude: _center.latitude,
          longitude: _center.longitude,
          type: 'saved_place:work'));
    }
    emit(SavedPlacesLocationsState(locations: [...locations]));
    preferences.setBool('saved_places_initialized', true);
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
