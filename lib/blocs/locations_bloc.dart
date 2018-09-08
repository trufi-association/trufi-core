import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/location/location_storage.dart';

class LocationsBloc implements BlocBase {
  LocationsBloc(String fileName) {
    _addLocationController.listen(_handleAdd);
    _removeLocationController.listen(_handleRemove);
    _init(fileName);
  }

  LocationStorage _locations;

  void _init(String fileName) async {
    File file = await localFile(fileName);
    List<TrufiLocation> locations = await readStorage(file);
    _locations = LocationStorage(file, locations);
    _notify();
  }

  // AddLocation
  BehaviorSubject<TrufiLocation> _addLocationController =
      new BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inAddLocation => _addLocationController.sink;

  // RemoveLocation
  BehaviorSubject<TrufiLocation> _removeLocationController =
      new BehaviorSubject<TrufiLocation>();

  Sink<TrufiLocation> get inRemoveLocation => _removeLocationController.sink;

  // Locations
  BehaviorSubject<List<TrufiLocation>> _locationsController =
      new BehaviorSubject<List<TrufiLocation>>(seedValue: []);

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
    _locations.add(value);
    _notify();
  }

  void _handleRemove(TrufiLocation value) {
    _locations.remove(value);
    _notify();
  }

  void _notify() {
    _inLocations.add(locations);
  }

  // Getter

  List<TrufiLocation> get locations => _locations.unmodifiableListView;

  // Fetch

  Future<List<TrufiLocation>> fetch(BuildContext context) =>
      _locations.fetchLocations(context);

  Future<List<TrufiLocation>> fetchWithLimit(BuildContext context, int limit) =>
      _locations.fetchLocationsWithLimit(context, limit);
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
