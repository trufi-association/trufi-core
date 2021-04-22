import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/blocs/app_review_bloc.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/trufi_configuration.dart';

void main() {
  group("AppReviewCubit", () {
    setUp(() {
      TrufiConfiguration().minimumReviewWorthyActionCount = 2;
    });

    blocTest(
      "emits [] when nothing is added",
      build: () => AppReviewCubit(MockRepository()),
      expect: () => [],
    );

    blocTest(
      "emits [2] when incrementReviewWorthyActions is added",
      build: () => AppReviewCubit(MockRepository()),
      act: (AppReviewCubit cubit) => cubit.incrementReviewWorthyActions(),
      expect: () => [2],
    );

    group("isAppReviewAppropriate", () {
      final mockPackageInfo = MockPackageInfo();
      final localRepository = MockRepository();

      setUp(() {
        TestWidgetsFlutterBinding.ensureInitialized();
      });

      test("should return false if version are identical", () async {
        final subject = AppReviewCubit(localRepository)
          ..incrementReviewWorthyActions()
          ..incrementReviewWorthyActions();

        when(mockPackageInfo.version).thenReturn("1.0.5");
        when(localRepository.getLastReviewRequestAppVersionKey())
            .thenAnswer((_) => Future.value("1.0.5"));

        expect(await subject.isAppReviewAppropriate(mockPackageInfo), false);
      });

      test("should return true if versions are not identical", () async {
        final subject = AppReviewCubit(localRepository)
          ..incrementReviewWorthyActions()
          ..incrementReviewWorthyActions();

        when(mockPackageInfo.version).thenReturn("1.0.5");
        when(localRepository.getLastReviewRequestAppVersionKey())
            .thenAnswer((_) => Future.value("1.0.6"));

        expect(await subject.isAppReviewAppropriate(mockPackageInfo), true);
      });

      test(
          "should return false if the minimum amount of relevant clicks are not there",
          () async {
        final subject = AppReviewCubit(localRepository)
          ..incrementReviewWorthyActions();

        when(mockPackageInfo.version).thenReturn("1.0.5");
        when(localRepository.getLastReviewRequestAppVersionKey())
            .thenAnswer((_) => Future.value("1.0.6"));

        expect(await subject.isAppReviewAppropriate(mockPackageInfo), true);
      });

      test("should call localRepository", () async {
        await AppReviewCubit(localRepository)
            .markReviewRequestedForCurrentVersion(mockPackageInfo);

        verify(localRepository.saveLastReviewRequestAppVersion("1.0.5"));
        verify(localRepository.saveReviewWorthyActionCount(0));
      });
    });
  });
}

class MockRepository extends Mock implements LocalRepository {}

class MockPackageInfo extends Mock implements PackageInfo {}
