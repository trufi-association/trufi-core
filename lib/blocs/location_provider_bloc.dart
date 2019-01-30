import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/composite_subscription.dart';

class LocationProviderBloc implements BlocBase {
  static LocationProviderBloc of(BuildContext context) {
    return BlocProvider.of<LocationProviderBloc>(context);
  }

  LocationProviderBloc() {
    _locationProvider = LocationProvider(
      onLocationChanged: _inLocationUpdate.add,
    );
  }

  LocationProvider _locationProvider;

  final _locationUpdateController = BehaviorSubject<LatLng>();

  Sink<LatLng> get _inLocationUpdate => _locationUpdateController.sink;

  Stream<LatLng> get outLocationUpdate => _locationUpdateController.stream;

  // Dispose

  @override
  void dispose() {
    _locationProvider.dispose();
    _locationUpdateController.close();
  }

  // Methods

  void start() async {
    _locationProvider.start();
  }

  void stop() async {
    _locationProvider.stop();
  }

  // Getter

  Future<LatLng> get lastLocation async {
    LatLng lastLocation;
    try {
      GeolocationStatus status = await _locationProvider.status;
      if (status == GeolocationStatus.granted) {
        lastLocation = await _locationProvider.lastLocation;
        if (lastLocation == null) {
          print("Location provider: No last location");
        }
      } else {
        print("Location provider: Permission not granted");
      }
    } catch (e) {
      print("Location provider: ${e.toString()}");
    }
    return lastLocation;
  }

  Future<GeolocationStatus> get status async => _locationProvider.status;
}

class LocationProvider {
  LocationProvider({
    this.onLocationChanged,
  });

  final ValueChanged<LatLng> onLocationChanged;

  final CompositeSubscription _subscriptions = CompositeSubscription();
  final Geolocator _geolocator = Geolocator();
  final LocationOptions _locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  start() async {
    _subscriptions.cancel();
    _subscriptions.add(
      (_geolocator.getPositionStream(_locationOptions)).listen(
        (position) => _handleOnLocationChanged(position),
      ),
    );
  }

  stop() async {
    _subscriptions.cancel();
  }

  void _handleOnLocationChanged(Position value) {
    if (onLocationChanged != null) {
      onLocationChanged(LatLng(value.latitude, value.longitude));
    }
  }

  // Dispose

  dispose() {
    _subscriptions.cancel();
  }

  // Getter

  Future<LatLng> get lastLocation async {
    Position position = await _geolocator.getLastKnownPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position != null
        ? LatLng(position.latitude, position.longitude)
        : null;
  }

  Future<GeolocationStatus> get status async {
    return _geolocator.checkGeolocationPermissionStatus();
  }
}
