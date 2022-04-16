import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    Key? key,
    required this.location,
  }) : super(key: key);

  final TrufiLocation location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    final bool isFavorite = searchLocationsCubit.state.favoritePlaces.contains(
      location,
    );
    if (isFavorite == true) {
      return IconButton(
        icon: Icon(Icons.favorite, color: theme.colorScheme.secondary),
        onPressed: () {
          searchLocationsCubit.deleteFavoritePlace(
            location,
          );
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.favorite_border, color: theme.colorScheme.secondary),
        onPressed: () {
          searchLocationsCubit.insertFavoritePlace(
            location,
          );
        },
      );
    }
  }
}
