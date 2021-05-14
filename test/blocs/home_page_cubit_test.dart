import 'dart:convert';

import 'package:latlong/latlong.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/trufi_models.dart';

import '../mocks/local_repository_mock.dart';
import '../mocks/request_manager_mock.dart';

void main() {
  group("HomePageCubit", () {
    final mockLocalRepository = MockLocalRepository();
    final mockRequestManager = MockRequestManager();

    setUp(() {});

    blocTest(
      "should call load by creation and read local db",
      build: () {
        when(mockLocalRepository.getStateHomePage()).thenAnswer(
          (realInvocation) async => "{}",
        );
        return HomePageCubit(mockLocalRepository, mockRequestManager);
      },
      verify: (_) => verify(mockLocalRepository.getStateHomePage()),
      expect: () => [const MapRouteState()],
    );

    blocTest(
      "should reset from and toPlace",
      build: () => HomePageCubit(mockLocalRepository, mockRequestManager),
      act: (HomePageCubit cubit) async {
        await cubit.updateMapRouteState(const MapRouteState(isFetching: true));
        await cubit.reset();
      },
      verify: (_) => verify(mockLocalRepository.deleteStateHomePage()),
      expect: () => [
        const MapRouteState(),
        const MapRouteState(isFetching: true),
        const MapRouteState(),
      ],
    );

    blocTest(
      "updateHomePageStateData should emit new state and call localStorage",
      build: () => HomePageCubit(mockLocalRepository, mockRequestManager),
      verify: (_) => verify(
        mockLocalRepository.saveStateHomePage(
          jsonEncode(const MapRouteState(isFetching: true).toJson()),
        ),
      ),
      act: (HomePageCubit cubit) async =>
          cubit.updateMapRouteState(const MapRouteState(isFetching: true)),
      expect: () => const [MapRouteState(), MapRouteState(isFetching: true)],
    );

    blocTest(
      "setFromPlace should emit new state and call localStorage",
      build: () => HomePageCubit(mockLocalRepository, mockRequestManager),
      act: (HomePageCubit cubit) async => cubit.setFromPlace(
          TrufiLocation(description: "Test", latitude: 1.0, longitude: 0.9)),
      expect: () => [
        const MapRouteState(),
        MapRouteState(
            fromPlace: TrufiLocation(
                description: "Test", latitude: 1.0, longitude: 0.9))
      ],
    );

    blocTest(
      "setToPlace should emit new state and call localStorage",
      build: () => HomePageCubit(mockLocalRepository, mockRequestManager),
      act: (HomePageCubit cubit) async => cubit.setToPlace(
          TrufiLocation(description: "Test", latitude: 1.0, longitude: 0.9)),
      expect: () => [
        const MapRouteState(),
        MapRouteState(
          toPlace:
              TrufiLocation(description: "Test", latitude: 1.0, longitude: 0.9),
        )
      ],
    );

    blocTest(
      "swapLocations should do something",
      build: () => HomePageCubit(mockLocalRepository, mockRequestManager),
      act: (HomePageCubit cubit) async {
        await cubit.updateMapRouteState(MapRouteState(
          toPlace: TrufiLocation(
              longitude: 1.0, latitude: 1.0, description: "Test 1"),
          fromPlace: TrufiLocation(
              longitude: 2.0, latitude: 2.0, description: "Test 2"),
        ));
        await cubit.swapLocations();
      },
      skip: 2,
      expect: () => [
        MapRouteState(
          fromPlace: TrufiLocation(
              longitude: 1.0, latitude: 1.0, description: "Test 1"),
          toPlace: TrufiLocation(
              longitude: 2.0, latitude: 2.0, description: "Test 2"),
        )
      ],
    );

    blocTest(
      "configSuccessAnimation should emit animation true",
      build: () => HomePageCubit(mockLocalRepository, mockRequestManager),
      act: (HomePageCubit cubit) async =>
          cubit.configSuccessAnimation(show: true),
      expect: () => [
        const MapRouteState(),
        const MapRouteState(showSuccessAnimation: true)
      ],
    );

    blocTest(
      "setTappingPlace for define fromPlace ",
      build: () => HomePageCubit(mockLocalRepository, mockRequestManager),
      act: (HomePageCubit cubit) async {
        await cubit.setTappingPlace(LatLng(1.0, 1.0));
      },
      skip: 1,
      expect: () => [
        MapRouteState(
          fromPlace: TrufiLocation(
              longitude: 1.0, latitude: 1.0, description: "Map Marker"),
        )
      ],
    );
    blocTest(
      "setTappingPlace for define toPlace ",
      build: () => HomePageCubit(mockLocalRepository, mockRequestManager),
      act: (HomePageCubit cubit) async {
        await cubit.setTappingPlace(LatLng(1.0, 1.0));
        await cubit.setTappingPlace(LatLng(2.0, 2.0));
      },
      skip: 2,
      expect: () => [
        MapRouteState(
          fromPlace: TrufiLocation(
              longitude: 1.0, latitude: 1.0, description: "Map Marker"),
          toPlace: TrufiLocation(
              longitude: 2.0, latitude: 2.0, description: "Map Marker"),
        )
      ],
    );
  });
}
