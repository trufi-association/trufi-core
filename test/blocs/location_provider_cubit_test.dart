import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/blocs/location_provider_cubit.dart';
import 'package:trufi_core/models/location_state.dart';

import '../mocks/geolocator_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("LocationProviderCubit", () {
    LocationProviderCubit subject;

    setUp(() {
      GeolocatorPlatform.instance = MockGeolocatorPlatform();
      subject = LocationProviderCubit();
    });

    for (final testCase in [
      LocationPermission.denied,
      LocationPermission.deniedForever,
    ]) {
      test("getCurrentLocation should return null for $testCase", () async {
        when(Geolocator.checkPermission())
            .thenAnswer((realInvocation) async => testCase);

        expect(await subject.getCurrentLocation(), null);
      });
    }

    for (final testCase in [
      LocationPermission.always,
      LocationPermission.whileInUse,
    ]) {
      test("getCurrentLocation should return currentLocation if $testCase",
          () async {
        when(Geolocator.checkPermission())
            .thenAnswer((realInvocation) async => testCase);

        when(
          Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
        ).thenAnswer(
          (realInvocation) async => Position(
              heading: 0.0,
              latitude: 88,
              longitude: 88,
              speed: 0,
              accuracy: 0,
              altitude: 0,
              timestamp: DateTime(2021),
              speedAccuracy: 0.0),
        );

        expect(await subject.getCurrentLocation(), LatLng(88.0, 88.0));
      });
    }

    blocTest(
      "start without permission should not start",
      build: () {
        GeolocatorPlatform.instance = MockGeolocatorPlatform();
        when(Geolocator.checkPermission()).thenAnswer(
          (realInvocation) async => LocationPermission.denied,
        );

        when(
          Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.high, distanceFilter: 10),
        ).thenAnswer(
          (_) => Stream<Position>.periodic(const Duration(milliseconds: 1),
              (int count) {
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

    blocTest(
      "start should emit [LocationState, LocationState]",
      build: () {
        GeolocatorPlatform.instance = MockGeolocatorPlatform();
        when(Geolocator.checkPermission()).thenAnswer(
          (realInvocation) async => LocationPermission.always,
        );

        when(
          Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.high, distanceFilter: 10),
        ).thenAnswer(
          (_) => Stream<Position>.periodic(const Duration(milliseconds: 1),
              (int count) {
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
      expect: () => [isA<LocationState>(), isA<LocationState>()],
    );
  });
}
