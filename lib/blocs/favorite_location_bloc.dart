import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/trufi_models.dart';

class FavoriteLocationBloc implements BlocBase {
  // IsFavorite
  final BehaviorSubject<bool> _isFavoriteController = BehaviorSubject<bool>();

  Stream<bool> get outIsFavorite => _isFavoriteController.stream;

  // Favorites
  final StreamController<List<TrufiLocation>> _favoritesController =
      StreamController<List<TrufiLocation>>();

  Sink<List<TrufiLocation>> get inFavorites => _favoritesController.sink;

  // Constructor

  FavoriteLocationBloc(TrufiLocation location) {
    _favoritesController.stream
        .map((locations) => locations.any((TrufiLocation l) => l == location))
        .listen((isFavorite) => _isFavoriteController.add(isFavorite));
  }

  // Dispose

  @override
  void dispose() {
    _favoritesController.close();
    _isFavoriteController.close();
  }
}
