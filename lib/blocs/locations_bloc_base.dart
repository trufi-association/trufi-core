import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs/bloc_provider.dart';
import '../location/location_storage.dart';
import '../trufi_models.dart';

abstract class LocationsBlocBase implements BlocBase {
  LocationsBlocBase(BuildContext context, this.locationStorage) {
    _addLocationController.listen(_handleAdd);
    _removeLocationController.listen(_handleRemove);
    _replaceLocationController.listen(_handleReplace);
    locationStorage.load(context).then((_) => _notify);
  }

  final LocationStorage locationStorage;

  // AddLocation
  final _addLocationController = BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inAddLocation => _addLocationController.sink;

  // RemoveLocation
  final _removeLocationController = BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inRemoveLocation => _removeLocationController.sink;

  // ReplaceLocation
  final _replaceLocationController =
      BehaviorSubject<Map<String, TrufiLocation>>();

  Sink<Map<String, TrufiLocation>> get inReplaceLocation =>
      _replaceLocationController.sink;

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
    locationStorage.add(value);
    _notify();
  }

  void _handleRemove(TrufiLocation value) {
    locationStorage.remove(value);
    _notify();
  }

  void _handleReplace(Map<String, TrufiLocation> value) {
    locationStorage.replace(value);
    _notify();
  }

  void _notify() {
    _inLocations.add(locations);
  }

  // Getter

  List<TrufiLocation> get locations => locationStorage.unmodifiableListView;

  // Fetch

  Future<List<TrufiLocation>> fetch(BuildContext context) {
    return locationStorage.fetchLocations(context);
  }

  Future<List<LevenshteinObject>> fetchWithQuery(
    BuildContext context,
    String query,
  ) {
    return locationStorage.fetchLocationsWithQuery(context, query);
  }

  Future<List<TrufiLocation>> fetchWithLimit(
    BuildContext context,
    int limit,
  ) {
    return locationStorage.fetchLocationsWithLimit(context, limit);
  }
}

int sortByLocations(
  dynamic a,
  dynamic b,
  List<TrufiLocation> locations,
) {
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
