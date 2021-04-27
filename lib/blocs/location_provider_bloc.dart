import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../blocs/bloc_provider.dart';
import '../composite_subscription.dart';

class LocationProviderBloc implements BlocBase {
  static LocationProviderBloc of(BuildContext context) {
    return TrufiBlocProvider.of<LocationProviderBloc>(context);
  }

  LocationProviderBloc() {
    _locationProvider = LocationProvider(
      onLocationChanged: _inLocationUpdate.add,
    );
  }

  LocationProvider _locationProvider;

  final _locationUpdateController = rx.BehaviorSubject<LatLng>();

  Sink<LatLng> get _inLocationUpdate => _locationUpdateController.sink;

  Stream<LatLng> get outLocationUpdate => _locationUpdateController.stream;

  // Dispose

  @override
  void dispose() {
    _locationProvider.dispose();
    _locationUpdateController.close();
  }

  // Methods

  Future<void> start() async {
    _locationProvider.start();
  }

  Future<void> stop() async {
    _locationProvider.stop();
  }

  // Getter

  Future<LatLng> get currentLocation async {
    LatLng location;
    try {
      final LocationPermission status = await Geolocator.checkPermission();
      if (status == LocationPermission.always ||
          status == LocationPermission.whileInUse) {
        location = await _locationProvider.currentLocation;
        if (location == null) {
          // TODO: Replace by a Exception / Error
          // ignore: avoid_print
          print("Location provider: No current location");
        }
      } else {
        // TODO: Replace by a Exception / Error
        // ignore: avoid_print
        print("Location provider: Permission not granted");
      }
    } catch (e) {
      // TODO: Replace by a Exception / Error
      // ignore: avoid_print
      print("Location provider: ${e.toString()}");
    }
    return location;
  }

  Future<LocationPermission> get status async => _locationProvider.status;
}

class LocationProvider {
  LocationProvider({
    this.onLocationChanged,
  });

  final ValueChanged<LatLng> onLocationChanged;

  final CompositeSubscription _subscriptions = CompositeSubscription();

  Future<void> start() async {
    // Check permission status
    final LocationPermission status = await Geolocator.checkPermission();
    if (!(status == LocationPermission.always ||
        status == LocationPermission.whileInUse)) {
      return;
    }

    // Subscribe to location updates
    _subscriptions.cancel();
    _subscriptions.add(
      (Geolocator.getPositionStream(
        desiredAccuracy: LocationAccuracy.high,
        distanceFilter: 10,
      )).listen(
        (position) => _handleOnLocationChanged(position),
      ),
    );
  }

  void stop() {
    _subscriptions.cancel();
  }

  void _handleOnLocationChanged(Position value) {
    if (onLocationChanged != null) {
      onLocationChanged(LatLng(value.latitude, value.longitude));
    }
  }

  // Dispose

  void dispose() {
    _subscriptions.cancel();
  }

  // Getter

  Future<LatLng> get currentLocation async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position != null
        ? LatLng(position.latitude, position.longitude)
        : null;
  }

  Future<LocationPermission> get status async {
    return Geolocator.checkPermission();
  }
}
