import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

class LocationState extends Equatable {
  final LatLng currentLocation;
  final StreamSubscription<Position> locationStreamSubscription;

  const LocationState({this.currentLocation, this.locationStreamSubscription});

  @override
  List<Object> get props => [currentLocation, locationStreamSubscription];

  @override
  String toString() =>
      "LocationState {currentLocation: $currentLocation, locationStreamSubscription: $locationStreamSubscription}";

  LocationState copyWith(
      {LatLng currentLocation,
      StreamSubscription<Position> locationStreamSubscription}) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      locationStreamSubscription:
          locationStreamSubscription ?? this.locationStreamSubscription,
    );
  }
}
