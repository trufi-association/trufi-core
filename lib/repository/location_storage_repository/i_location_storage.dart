import 'dart:collection';

import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/trufi_models.dart';

abstract class ILocationStorage {

  Future<bool> load();

  Future<bool> save();

  UnmodifiableListView<TrufiLocation> getUnmodifiableListView();

  Future<List<TrufiLocation>> fetchLocations(
    FavoriteLocationsBloc favoriteLocationsBloc,
  );

  Future<List<TrufiLocation>> fetchLocationsWithLimit(
    int limit,
    FavoriteLocationsBloc favoriteLocationsBloc,
  );

  Future<List<LevenshteinObject>> fetchLocationsWithQuery(
    String query,
  );

  void addLocation(TrufiLocation location);

  void removeLocation(TrufiLocation location);

  void replaceLocation(Map<String, TrufiLocation> data);

  bool containsLocation(TrufiLocation location);
}
