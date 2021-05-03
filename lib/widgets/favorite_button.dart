import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import '../trufi_models.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    Key key,
    this.location,
    this.color,
  }) : super(key: key);

  final TrufiLocation location;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final searchLocationsCubit = context.watch<SearchLocationsCubit>();
    final bool isFavorite = searchLocationsCubit.state.favoritePlaces.contains(
      location,
    );
    if (isFavorite == true) {
      return IconButton(
        icon: Icon(Icons.favorite, color: color),
        onPressed: () {
          searchLocationsCubit.deleteFavoritePlace(
            location,
          );
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.favorite_border, color: color),
        onPressed: () {
          searchLocationsCubit.insertFavoritePlace(
            location,
          );
        },
      );
    }
  }
}
