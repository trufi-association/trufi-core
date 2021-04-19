import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/bloc_provider.dart';
import '../blocs/locations_bloc_base.dart';
import '../location/location_storage.dart';
import '../trufi_configuration.dart';
import '../trufi_models.dart';

class SavedPlacesBloc extends LocationsBlocBase {
  static SavedPlacesBloc of(BuildContext context) {
    return TrufiBlocProvider.of<SavedPlacesBloc>(context);
  }

  SavedPlacesBloc(
    BuildContext context,
  ) : super(
    context,
    SharedPreferencesLocationStorage("saved_places"),
  ){
    initSavedPage();
  }

  Future<void> initSavedPage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.get('saved_places_initialized') == null) {
      final LatLng _center = TrufiConfiguration().map.center;
      inAddLocation.add(TrufiLocation(
          description: 'Home',
          latitude: _center.latitude,
          longitude: _center.longitude,
          type: 'saved_place:home'));
      inAddLocation.add(TrufiLocation(
          description: 'Work',
          latitude: _center.latitude,
          longitude: _center.longitude,
          type: 'saved_place:work'));
    }
    preferences.setBool('saved_places_initialized', true);
  }
}