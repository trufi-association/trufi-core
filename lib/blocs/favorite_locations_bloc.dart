import 'dart:async';

import 'package:trufi_app/blocs/locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class FavoriteLocationsBloc extends LocationsBloc {
  FavoriteLocationsBloc() : super("location_search_favorites.json");

  Sink<TrufiLocation> get inAddFavorite => inAddLocation;

  Sink<TrufiLocation> get inRemoveFavorite => inRemoveLocation;

  Stream<List<TrufiLocation>> get outFavorites => outLocations;

  List<TrufiLocation> get favorites => locations;
}

int sortByFavoriteLocations(
  TrufiLocation a,
  TrufiLocation b,
  List<TrufiLocation> favorites,
) {
  return sortByLocations(a, b, favorites);
}
