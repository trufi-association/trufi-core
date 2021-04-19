import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/repository/shared_preferences_repository.dart';
import 'package:trufi_core/trufi_configuration.dart';

class AppReviewBloc extends Cubit<int> {
  SharedPreferencesRepository sharedPreferencesRepository;

  AppReviewBloc(this.sharedPreferencesRepository) : super(1);

  void incrementReviewWorthyActions() {
    emit(state + 1);
  }

  Future<bool> isAppReviewAppropriate() async {
    final minActionCount = TrufiConfiguration().minimumReviewWorthyActionCount;
    final currentActionCount = state;

    if (currentActionCount >= minActionCount) {
      final currentVersion = (await PackageInfo.fromPlatform()).version;

      final lastVersion =
      await sharedPreferencesRepository.getLastReviewRequestAppVersionKey();

      return lastVersion == null || lastVersion != currentVersion;
    }

    return false;
  }

  Future<void> markReviewRequestedForCurrentVersion() async {
    final currentVersion = (await PackageInfo.fromPlatform()).version;
    sharedPreferencesRepository.saveLastReviewRequestAppVersion(currentVersion);
    sharedPreferencesRepository.saveReviewWorthyActionCount(0);
  }
}
