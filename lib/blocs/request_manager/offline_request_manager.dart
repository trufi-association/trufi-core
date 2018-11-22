import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trufi_app/blocs/favorite_locations_bloc.dart';
import 'package:trufi_app/blocs/important_locations_bloc.dart';
import 'package:trufi_app/blocs/locations_bloc.dart';
import 'package:trufi_app/blocs/offline_locations_bloc.dart';
import 'package:trufi_app/blocs/request_manager_bloc.dart';
import 'package:trufi_app/trufi_models.dart';

class OfflineRequestManager implements RequestManager {
  Future<List<TrufiLocation>> fetchLocations(
    BuildContext context,
    String query,
  ) async {
    final favoriteLocationsBloc = FavoriteLocationsBloc.of(context);
    final offlineLocationsBloc = OfflineLocationsBloc.of(context);
    final placeLocationsBloc = ImportantLocationsBloc.of(context);
    // Search in places and locations
    final results = (await Future.wait([
      placeLocationsBloc.fetchWithQuery(context, query), // High priority
      offlineLocationsBloc.fetchWithQuery(context, query), // Low priority
    ]));
    // Sort results by importance and concat them
    final locations = results.expand(
      (locations) {
        locations.sort(sortByImportance);
        return locations;
      },
    ).toList();
    // Sort by favorites
    locations.sort((a, b) {
      return sortByFavoriteLocations(a, b, favoriteLocationsBloc.locations);
    });
    return locations;
  }

  Future<Plan> fetchPlan(
    BuildContext context,
    TrufiLocation from,
    TrufiLocation to,
  ) async {
    throw FetchOfflineRequestException(
      Exception("Fetch plan offline is not implemented yet."),
    );
  }
}
