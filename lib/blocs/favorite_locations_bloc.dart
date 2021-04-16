import 'package:flutter/material.dart';

import '../blocs/bloc_provider.dart';
import '../blocs/locations_bloc_base.dart';
import '../location/location_storage.dart';
import '../trufi_models.dart';

class FavoriteLocationsBloc extends LocationsBlocBase {
  static FavoriteLocationsBloc of(BuildContext context) {
    return BlocProvider.of<FavoriteLocationsBloc>(context);
  }

  FavoriteLocationsBloc(
    BuildContext context,
  ) : super(
          context,
          SharedPreferencesLocationStorage("favorite_locations"),
        );
}

int sortByFavoriteLocations(
    dynamic a, dynamic b, List<TrufiLocation> favorites) {
  return sortByLocations(a, b, favorites);
}
