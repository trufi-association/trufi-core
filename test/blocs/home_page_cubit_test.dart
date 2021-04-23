import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/models/map_route_state.dart';

import '../mocks/local_repository_mock.dart';

void main() {
  group("HomePageCubit", () {
    final mockLocalRepository = MockLocalRepository();

    setUp(() {
      when(mockLocalRepository.getStateHomePage()).thenAnswer(
        (realInvocation) async => "{}",
      );
    });

    blocTest(
      "should call load by creation and read local db",
      build: () {
        return HomePageCubit(mockLocalRepository);
      },
      verify: (_) => verify(mockLocalRepository.getStateHomePage()),
      expect: () => [const MapRouteState()],
    );
  });
}
