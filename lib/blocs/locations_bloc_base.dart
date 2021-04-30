import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/repository/location_storage_repository/i_location_storage.dart';

import '../blocs/bloc_provider.dart';
import '../trufi_models.dart';

abstract class LocationsBlocBase implements BlocBase {
  LocationsBlocBase(this.locationStorage) {
    _addLocationController.listen(_handleAdd);
    _removeLocationController.listen(_handleRemove);
    _replaceLocationController.listen(_handleReplace);
    locationStorage.load().then((_) => _notify);
  }

  final ILocationStorage locationStorage;

  // AddLocation
  final _addLocationController = BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inAddLocation => _addLocationController.sink;

  // RemoveLocation
  final _removeLocationController = BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inRemoveLocation => _removeLocationController.sink;

  // ReplaceLocation
  final _replaceLocationController = BehaviorSubject<Map<String, TrufiLocation>>();

  Sink<Map<String, TrufiLocation>> get inReplaceLocation => _replaceLocationController.sink;

  // Locations
  final _locationsController = BehaviorSubject<List<TrufiLocation>>();

  Sink<List<TrufiLocation>> get _inLocations => _locationsController.sink;

  Stream<List<TrufiLocation>> get outLocations => _locationsController.stream;

  // Dispose

  @override
  void dispose() {
    _addLocationController.close();
    _removeLocationController.close();
    _replaceLocationController.close();
    _locationsController.close();
  }

  // Handle

  void _handleAdd(TrufiLocation value) {
    locationStorage.addLocation(value);
    _notify();
  }

  void _handleRemove(TrufiLocation value) {
    locationStorage.removeLocation(value);
    _notify();
  }

  void _handleReplace(Map<String, TrufiLocation> value) {
    locationStorage.replaceLocation(value);
    _notify();
  }

  void _notify() {
    _inLocations.add(locations);
  }

  // Getter

  List<TrufiLocation> get locations => locationStorage.getUnmodifiableListView();

  // Fetch

  Future<List<TrufiLocation>> fetch(BuildContext context) async {
    return locationStorage.fetchLocations(FavoriteLocationsBloc.of(context));
  }

  Future<List<LevenshteinObject>> fetchWithQuery(
    BuildContext context,
    String query,
  ) async {
    return locationStorage.fetchLocationsWithQuery(query);
  }

  Future<List<TrufiLocation>> fetchWithLimit(
    BuildContext context,
    int limit,
  ) async  {
    return locationStorage.fetchLocationsWithLimit(limit,FavoriteLocationsBloc.of(context));
  }
}

int sortByLocations(dynamic a, dynamic b, List<TrufiLocation> locations) {
  final bool aIsAvailable = (a is TrufiLocation)
      ? locations.contains(a)
      // TODO: Fix Linting problem with tests
      // ignore: avoid_bool_literals_in_conditional_expressions
      : (a is TrufiStreet)
          ? a.junctions.fold<bool>(
              false,
              (result, j) => result |= locations.contains(j.location),
            )
          : false;
  final bool bIsAvailable = (b is TrufiLocation)
      ? locations.contains(b)
      // TODO: Fix Linting problem with tests
      // ignore: avoid_bool_literals_in_conditional_expressions
      : (b is TrufiStreet)
          ? b.junctions.fold<bool>(
              false,
              (result, j) => result |= locations.contains(j.location),
            )
          : false;
  return aIsAvailable == bIsAvailable
      ? 0
      : aIsAvailable
          ? -1
          : 1;
}
