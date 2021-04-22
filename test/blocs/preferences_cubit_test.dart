import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/models/preferences.dart';

import '../mocks/local_repository_mock.dart';

void main() {
  group("PreferencesCubit", () {
    blocTest(
      "should add another Preference to the state",
      build: () => PreferencesCubit(MockLocalRepository()),
      act: (PreferencesCubit cubit) => cubit.updateMapType("TestMapTyle"),
      expect: () => [
        const Preference("en", "", "TestMapTyle", loadOnline: true),
        const Preference("en", "", "streets", loadOnline: true),
      ],
    );
  });
}
