import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationState extends Equatable {
  final LatLng? currentLocation;

  const LocationState({this.currentLocation});

  @override
  List<Object?> get props => [currentLocation];

  @override
  String toString() => "LocationState {currentLocation: $currentLocation";

  LocationState copyWith({
    LatLng? currentLocation,
    StreamSubscription<Position>? locationStreamSubscription,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}
