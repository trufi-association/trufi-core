import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/composite_subscription.dart';

class LocationProviderBloc implements BlocBase {
  LocationProviderBloc() {
    _locationProvider = LocationProvider(onLocationChanged: (location) {
      _inLocationUpdate.add(location);
    })
      ..init();
  }

  LocationProvider _locationProvider;

  BehaviorSubject<LatLng> _locationUpdateController =
      new BehaviorSubject<LatLng>();

  Sink<LatLng> get _inLocationUpdate => _locationUpdateController.sink;

  Stream<LatLng> get outLocationUpdate => _locationUpdateController.stream;

  // Dispose

  @override
  void dispose() {
    _locationProvider.dispose();
    _locationUpdateController.close();
  }

  // Getter

  bool get hasPermission => _locationProvider.hasPermission;

  LatLng get lastLocation => _locationProvider.lastLocation;

  Exception get error => _locationProvider.error;
}

class PermissionDeniedException implements Exception {
  PermissionDeniedException(this._innerException);

  final Exception _innerException;

  @override
  String toString() {
    return "PermissionDeniedException: ${_innerException.toString()}";
  }
}

class PermissionDeniedNeverAskException implements Exception {
  PermissionDeniedNeverAskException(this._innerException);

  final Exception _innerException;

  @override
  String toString() {
    return "PermissionDeniedNeverAskException: ${_innerException.toString()}";
  }
}

class LocationProvider {
  LocationProvider({
    this.onLocationChanged,
    this.onError,
  });

  final ValueChanged<LatLng> onLocationChanged;
  final ValueChanged<Exception> onError;

  final CompositeSubscription _subscriptions = CompositeSubscription();
  final Location _locationManager = Location();

  bool _hasPermission = false;
  LatLng _location = LatLng(-17.4603761, -66.1860606);
  Exception _error;

  init() async {
    try {
      _hasPermission = await _locationManager.hasPermission();
      _handleOnLocationChanged(
        _createLatLng(
          await _locationManager.getLocation(),
        ),
      );
    } on PlatformException catch (e) {
      Exception error = e;
      if (e.code == 'PERMISSION_DENIED') {
        error = PermissionDeniedException(e);
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = PermissionDeniedNeverAskException(e);
      }
      _handleOnError(error);
    }
    _subscriptions.add(
      _locationManager.onLocationChanged().listen(
        (Map<String, double> result) {
          _handleOnLocationChanged(_createLatLng(result));
        },
      ),
    );
  }

  void _handleOnLocationChanged(LatLng value) {
    _location = value;
    _error = null;
    if (onLocationChanged != null && value != null) {
      onLocationChanged(value);
    }
  }

  void _handleOnError(Exception value) {
    _error = value;
    if (onError != null && value != null) {
      onError(value);
    }
  }

  // Dispose

  dispose() {
    _subscriptions.cancel();
  }

  // Getter

  bool get hasPermission => _hasPermission;

  LatLng get lastLocation => _location;

  Exception get error => _error;
}

LatLng _createLatLng(Map<String, double> value) {
  return LatLng(value['latitude'], value['longitude']);
}
