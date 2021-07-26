import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/blocs/gps_location/location_state.dart';

class LocationProviderCubit extends Cubit<LocationState> {
  StreamSubscription<Position> _locationStreamSubscription;
  LocationProviderCubit() : super(const LocationState());

  Future<void> start() async {
    final LocationPermission status = await Geolocator.checkPermission();
    if (!(status == LocationPermission.always ||
        status == LocationPermission.whileInUse)) {
      return;
    }
    _locationStreamSubscription ??= Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ).listen((position) {
      emit(state.copyWith(
        currentLocation: LatLng(
          position.latitude,
          position.longitude,
        ),
      ));
    });
  }

  void stop() {
    if (_locationStreamSubscription != null) {
      _locationStreamSubscription.cancel();
      _locationStreamSubscription = null;
    }
  }
}
