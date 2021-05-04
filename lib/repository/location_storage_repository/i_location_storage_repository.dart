import 'dart:collection';

// import 'package:trufi_core/blocs/locations/favorite_locations_cubit/favorite_locations_cubit.dart';
import 'package:trufi_core/trufi_models.dart';

abstract class ILocationStorageRepository {

  Future<bool> load();

  Future<bool> save();

  UnmodifiableListView<TrufiLocation> getUnmodifiableListView();

  Future<List<TrufiLocation>> fetchLocations(
    // FavoriteLocationsCubit favoriteLocationsCubit,
  );

  Future<List<TrufiLocation>> fetchLocationsWithLimit(
    int limit,
    // FavoriteLocationsCubit favoriteLocationsCubit,
  );

  Future<List<LevenshteinObject>> fetchLocationsWithQuery(
    String query,
  );

  void addLocation(TrufiLocation location);

  void removeLocation(TrufiLocation location);

  void replaceLocation(Map<String, TrufiLocation> data);

  bool containsLocation(TrufiLocation location);
}
