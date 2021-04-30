import 'package:flutter/material.dart';
import 'package:trufi_core/repository/location_storage_repository/shared_preferences_location_storage.dart';

import '../blocs/bloc_provider.dart';
import '../blocs/locations_bloc_base.dart';
import '../trufi_models.dart';

class FavoriteLocationsBloc extends LocationsBlocBase {
  static FavoriteLocationsBloc of(BuildContext context) {
    return TrufiBlocProvider.of<FavoriteLocationsBloc>(context);
  }

  FavoriteLocationsBloc(
  ) : super(
          SharedPreferencesLocationStorage("favorite_locations"),
        );
}

int sortByFavoriteLocations(
    dynamic a, dynamic b, List<TrufiLocation> favorites) {
  return sortByLocations(a, b, favorites);
}
