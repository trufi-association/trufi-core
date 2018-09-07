import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_storage.dart';

class FavoriteLocationsBloc implements BlocBase {
  FavoriteLocationsBloc() {
    _addFavoriteController.listen(_handleAddFavorite);
    _removeFavoriteController.listen(_handleRemoveFavorite);
    _init();
  }

  LocationStorage _favorites;

  void _init() async {
    File file = await localFile("location_search_favorites.json");
    List<TrufiLocation> locations = await readStorage(file);
    _favorites = LocationStorage(file, locations);
    _notify();
  }

  // AddFavorite
  BehaviorSubject<TrufiLocation> _addFavoriteController =
      new BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inAddFavorite => _addFavoriteController.sink;

  // RemoveFavorite
  BehaviorSubject<TrufiLocation> _removeFavoriteController =
      new BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inRemoveFavorite => _removeFavoriteController.sink;

  // Favorites
  BehaviorSubject<List<TrufiLocation>> _favoritesController =
      new BehaviorSubject<List<TrufiLocation>>(seedValue: []);

  Sink<List<TrufiLocation>> get _inFavorites => _favoritesController.sink;

  Stream<List<TrufiLocation>> get outFavorites => _favoritesController.stream;

  // Dispose

  @override
  void dispose() {
    _addFavoriteController.close();
    _removeFavoriteController.close();
    _favoritesController.close();
  }

  // Handle

  void _handleAddFavorite(TrufiLocation value) {
    _favorites.add(value);
    _notify();
  }

  void _handleRemoveFavorite(TrufiLocation value) {
    _favorites.remove(value);
    _notify();
  }

  void _notify() {
    _inFavorites.add(favorites);
  }

  // Getter

  List<TrufiLocation> get favorites => _favorites.unmodifiableListView;
}

int sortByFavorite(
  TrufiLocation a,
  TrufiLocation b,
  List<TrufiLocation> favorites,
) {
  bool aIsFavorite = favorites.contains(a);
  bool bIsFavorite = favorites.contains(b);
  return aIsFavorite == bIsFavorite ? 0 : aIsFavorite ? -1 : 1;
}
