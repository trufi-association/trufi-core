import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/composite_subscription.dart';

class LocationProvider {
  final Function(LatLng) onLocationChanged;
  final Function(String) onLocationError;

  LocationProvider({this.onLocationChanged, this.onLocationError});

  CompositeSubscription _subscriptions = CompositeSubscription();
  Location _location = Location();

  bool permission = false;
  LatLng location = LatLng(-17.4603761, -66.1860606);
  String error;

  init() async {
    try {
      permission = await _location.hasPermission();
      location = createLatLng(await _location.getLocation());
      error = null;
      _onLocationChanged(location);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied - please ask the user to enable it';
      }
      _onLocationError(error);
    }
    _subscriptions.add(
      _location.onLocationChanged().listen(
        (Map<String, double> result) {
          _onLocationChanged(createLatLng(result));
        },
      ),
    );
  }

  _onLocationChanged(LatLng value) {
    if (onLocationChanged != null) {
      onLocationChanged(value);
    }
  }

  _onLocationError(String error) {
    if (onLocationError != null) {
      onLocationError(error);
    }
  }

  LatLng createLatLng(Map<String, double> value) {
    return LatLng(value['latitude'], value['longitude']);
  }

  dispose() {
    _subscriptions.cancel();
  }
}
