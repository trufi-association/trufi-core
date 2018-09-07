import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/location/location_search_favorites.dart';
import 'package:trufi_app/trufi_models.dart';

class FavoritesBloc implements BlocBase {
  // AddFavorite
  BehaviorSubject<TrufiLocation> _addFavoriteController =
      new BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inAddFavorite => _addFavoriteController.sink;

  // RemoveFavorite
  BehaviorSubject<TrufiLocation> _removeFavoriteController =
      new BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inRemoveFavorite =>
      _removeFavoriteController.sink;

  // Favorites
  BehaviorSubject<List<TrufiLocation>> _favoritesController =
      new BehaviorSubject<List<TrufiLocation>>(seedValue: []);

  Sink<List<TrufiLocation>> get _inFavorites => _favoritesController.sink;

  Stream<List<TrufiLocation>> get outFavorites => _favoritesController.stream;

  // Constructor

  FavoritesBloc() {
    Favorites.init();
    _addFavoriteController.listen(_handleAddFavorite);
    _removeFavoriteController.listen(_handleRemoveFavorite);
  }

  // Dispose

  @override
  void dispose() {
    _addFavoriteController.close();
    _removeFavoriteController.close();
    _favoritesController.close();
  }

  // Handle

  void _handleAddFavorite(TrufiLocation value) {
    Favorites.instance.add(value);
    _notify();
  }

  void _handleRemoveFavorite(TrufiLocation value) {
    Favorites.instance.remove(value);
    _notify();
  }

  void _notify() {
    _inFavorites
        .add(UnmodifiableListView(Favorites.instance.unmodifiableListView));
  }
}
