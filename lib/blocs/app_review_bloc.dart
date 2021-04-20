import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/trufi_configuration.dart';

class AppReviewBloc extends Cubit<int> {
  LocalRepository localRepository;

  AppReviewBloc(this.localRepository) : super(1);

  void incrementReviewWorthyActions() {
    emit(state + 1);
  }

  Future<bool> isAppReviewAppropriate() async {
    final minActionCount = TrufiConfiguration().minimumReviewWorthyActionCount;
    final currentActionCount = state;

    if (currentActionCount >= minActionCount) {
      final currentVersion = (await PackageInfo.fromPlatform()).version;

      final lastVersion =
          await localRepository.getLastReviewRequestAppVersionKey();

      return lastVersion == null || lastVersion != currentVersion;
    }

    return false;
  }

  Future<void> markReviewRequestedForCurrentVersion() async {
    final currentVersion = (await PackageInfo.fromPlatform()).version;
    localRepository.saveLastReviewRequestAppVersion(currentVersion);
    localRepository.saveReviewWorthyActionCount(0);
  }
}
