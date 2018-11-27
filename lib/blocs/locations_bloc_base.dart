import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/location/location_storage.dart';
import 'package:trufi_app/trufi_models.dart';

abstract class LocationsBlocBase implements BlocBase {
  LocationsBlocBase(BuildContext context, this.locationStorage) {
    _addLocationController.listen(_handleAdd);
    _removeLocationController.listen(_handleRemove);
    locationStorage.load(context).then((_) => _notify);
  }

  final LocationStorage locationStorage;

  // AddLocation
  final _addLocationController = BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inAddLocation => _addLocationController.sink;

  // RemoveLocation
  final _removeLocationController = BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inRemoveLocation => _removeLocationController.sink;

  // Locations
  final _locationsController = BehaviorSubject<List<TrufiLocation>>(
    seedValue: [],
  );

  Sink<List<TrufiLocation>> get _inLocations => _locationsController.sink;

  Stream<List<TrufiLocation>> get outLocations => _locationsController.stream;

  // Dispose

  @override
  void dispose() {
    _addLocationController.close();
    _removeLocationController.close();
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

  void _notify() {
    _inLocations.add(locations);
  }

  // Getter

  List<TrufiLocation> get locations => locationStorage.unmodifiableListView;

  // Fetch

  Future<List<TrufiLocation>> fetch(BuildContext context) {
    return locationStorage.fetchLocations(context);
  }

  Future<List<LevenshteinTrufiLocation>> fetchWithQuery(
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
  TrufiLocation a,
  TrufiLocation b,
  List<TrufiLocation> locations,
) {
  bool aIsAvailable = locations.contains(a);
  bool bIsAvailable = locations.contains(b);
  return aIsAvailable == bIsAvailable ? 0 : aIsAvailable ? -1 : 1;
}
