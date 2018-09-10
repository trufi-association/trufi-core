import 'dart:async';

import 'package:trufi_app/blocs/locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class FavoriteLocationsBloc extends LocationsBloc {
  FavoriteLocationsBloc() : super("location_search_favorites.json");
}

int sortByFavoriteLocations(
  TrufiLocation a,
  TrufiLocation b,
  List<TrufiLocation> favorites,
) {
  return sortByLocations(a, b, favorites);
}
