import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../blocs/favorite_location_bloc.dart';
import '../blocs/favorite_locations_bloc.dart';
import '../trufi_models.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    Key key,
    this.location,
    @required this.favoritesStream,
    this.color,
  }) : super(key: key);

  final TrufiLocation location;
  final Stream<List<TrufiLocation>> favoritesStream;
  final Color color;

  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  FavoriteLocationBloc _bloc;

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _createBloc();
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeBloc();
    _createBloc();
  }

  @override
  void dispose() {
    _disposeBloc();
    super.dispose();
  }

  void _createBloc() {
    _bloc = FavoriteLocationBloc(widget.location);
    _subscription = widget.favoritesStream.listen(_bloc.inFavorites.add);
  }

  void _disposeBloc() {
    _subscription.cancel();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    return StreamBuilder(
      stream: _bloc.outIsFavorite,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final bool isFavorite = favoriteLocationsBloc.locations.contains(
          widget.location,
        );
        if (isFavorite == true) {
          return IconButton(
            icon: Icon(Icons.favorite, color: widget.color),
            onPressed: () {
              favoriteLocationsBloc.inRemoveLocation.add(
                widget.location,
              );
            },
          );
        } else {
          return IconButton(
            icon: Icon(Icons.favorite_border, color: widget.color),
            onPressed: () {
              favoriteLocationsBloc.inAddLocation.add(
                widget.location,
              );
            },
          );
        }
      },
    );
  }
}
