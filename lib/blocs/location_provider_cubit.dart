import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/models/location_state.dart';

class LocationProviderCubit extends Cubit<LocationState> {
  LocationProviderCubit() : super(const LocationState());

  Future<void> start() async {
    final LocationPermission status = await Geolocator.checkPermission();
    if (!(status == LocationPermission.always ||
        status == LocationPermission.whileInUse)) {
      return;
    }

    emit(state.copyWith(
      locationStreamSubscription: Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.high, distanceFilter: 10)
          .listen((position) {
        emit(state.copyWith(
          currentLocation: LatLng(position.latitude, position.longitude),
        ));
      }),
    ));
  }

  void stop() {
    if (state.locationStreamSubscription != null) {
      state.locationStreamSubscription.cancel();
    }
  }

  // Getter

  Future<LatLng> getCurrentLocation() async {
    final LocationPermission status = await Geolocator.checkPermission();

    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      return position != null
          ? LatLng(position.latitude, position.longitude)
          : null;
    }

    return null;
  }
}
