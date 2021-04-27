import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/models/preferences.dart';

import '../mocks/local_repository_mock.dart';
import '../mocks/uuid_mock.dart';

void main() {
  group("PreferencesCubit", () {
    MockLocalRepository mockLocalRepository;
    MockUuid mockUuid;

    setUp(() {
      mockLocalRepository = MockLocalRepository();
      mockUuid = MockUuid();
      when(mockUuid.v4()).thenReturn("5");
    });

    blocTest(
      "updateMapType emits [Preference, Preference] one updated with mapType",
      build: () => PreferencesCubit(mockLocalRepository, mockUuid),
      act: (PreferencesCubit cubit) => cubit..updateMapType("TestMapTyle"),
      expect: () => [
        const Preference("en", "", "TestMapTyle", loadOnline: true),
        const Preference("en", "5", "streets", loadOnline: true),
      ],
    );

    blocTest(
      "updateOnline should emit online true && call LocalRepository setOnline",
      build: () => PreferencesCubit(mockLocalRepository, mockUuid),
      act: (PreferencesCubit cubit) => cubit.updateOnline(),
      verify: (_) =>
          verify(mockLocalRepository.saveUseOnline(loadOnline: false)),
      expect: () => [
        const Preference("en", "", "streets", loadOnline: false),
        const Preference("en", "5", "streets", loadOnline: true),
      ],
    );

    blocTest(
      "updateLanguage should emit online true && call LocalRepository saveLanguageCode",
      build: () => PreferencesCubit(mockLocalRepository, mockUuid),
      act: (PreferencesCubit cubit) => cubit.updateLanguage("de"),
      verify: (_) => verify(mockLocalRepository.saveLanguageCode("de")),
      expect: () => [
        const Preference("de", "", "streets", loadOnline: true),
        const Preference("en", "5", "streets", loadOnline: true),
      ],
    );
  });
}
