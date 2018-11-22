import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/important_locations_bloc.dart';
import 'package:trufi_app/blocs/offline_locations_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class OfflineLocationSearchBloc implements BlocBase {
  static OfflineLocationSearchBloc of(BuildContext context) {
    return BlocProvider.of<OfflineLocationSearchBloc>(context);
  }

  Future<List<TrufiLocation>> fetchWithQuery(
    BuildContext context,
    String query,
  ) async {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    final offlineLocationsBloc = OfflineLocationsBloc.of(context);
    final placeLocationsBloc = ImportantLocationsBloc.of(context);
    // Search in places and locations
    final locations = (await Future.wait([
      placeLocationsBloc.fetchWithQuery(context, query), // High priority
      offlineLocationsBloc.fetchWithQuery(context, query), // Low priority
    ]))
        .expand((locations) => locations)
        .toList();
    // Sort by favorites
    locations.sort((a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
  }

  // Dispose

  @override
  void dispose() {}
}
