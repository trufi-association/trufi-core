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
    return BlocProvider.of<SavedPlacesBloc>(context);
  }

  SavedPlacesBloc(
    BuildContext context,
  ) : super(
    context,
    SharedPreferencesLocationStorage("saved_places"),
  ){
    initSavedPage();
  }

  void initSavedPage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.get('saved_places_initialized') == null) {
      LatLng _center = TrufiConfiguration().map.center;
      this.inAddLocation.add(TrufiLocation(
          description: 'Home',
          latitude: _center.latitude,
          longitude: _center.longitude,
          type: 'saved_place:home'));
      this.inAddLocation.add(TrufiLocation(
          description: 'Work',
          latitude: _center.latitude,
          longitude: _center.longitude,
          type: 'saved_place:work'));
    }
    preferences.setBool('saved_places_initialized', true);
  }
}