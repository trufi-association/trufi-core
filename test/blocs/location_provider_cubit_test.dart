import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/blocs/gps_location/location_provider_cubit.dart';
import 'package:trufi_core/blocs/gps_location/location_state.dart';

import '../mocks/geolocator_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("LocationProviderCubit", () {
    for (final testCase in [
      LocationPermission.denied,
      LocationPermission.deniedForever,
    ]) {
      blocTest(
        "start without permission should not start $testCase",
        build: () {
          GeolocatorPlatform.instance = MockGeolocatorPlatform();
          when(Geolocator.checkPermission()).thenAnswer(
            (realInvocation) async => testCase,
          );

          when(
            Geolocator.getPositionStream(
                desiredAccuracy: LocationAccuracy.high, distanceFilter: 10),
          ).thenAnswer(
            (_) => Stream<Position>.periodic(const Duration(milliseconds: 1), (int count) {
              return Position(
                heading: 0.0,
                latitude: 88,
                longitude: 88,
                speed: 0,
                accuracy: 0,
                altitude: 0,
                timestamp: DateTime.now(),
                speedAccuracy: 0.0,
              );
            }),
          );

          return LocationProviderCubit();
        },
        act: (LocationProviderCubit cubit) => cubit.start(),
        expect: () => [],
      );
    }

    for (final testCase in [
      LocationPermission.always,
      LocationPermission.whileInUse,
    ]) {
      blocTest(
        "start should emit [LocationState, LocationState] with $testCase",
        build: () {
          GeolocatorPlatform.instance = MockGeolocatorPlatform();
          when(Geolocator.checkPermission()).thenAnswer(
            (realInvocation) async => testCase,
          );

          when(
            Geolocator.getPositionStream(
                desiredAccuracy: LocationAccuracy.high, distanceFilter: 10),
          ).thenAnswer(
            (_) => Stream<Position>.periodic(const Duration(milliseconds: 1), (int count) {
              return Position(
                heading: 0.0,
                latitude: 88,
                longitude: 88,
                speed: 0,
                accuracy: 0,
                altitude: 0,
                timestamp: DateTime.now(),
                speedAccuracy: 0.0,
              );
            }),
          );

          return LocationProviderCubit();
        },
        wait: const Duration(milliseconds: 1),
        act: (LocationProviderCubit cubit) => cubit.start(),
        expect: () => [LocationState(currentLocation: LatLng(88, 88))],
      );
    }
  });
}
