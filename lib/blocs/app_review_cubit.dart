import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/repository/local_repository.dart';

class AppReviewCubit extends Cubit<int> {
  LocalRepository localRepository;
  int minimumReviewWorthyActions;

  AppReviewCubit(this.minimumReviewWorthyActions, this.localRepository)
      : super(1);

  void incrementReviewWorthyActions() {
    emit(state + 1);
  }

  Future<bool> isAppReviewAppropriate(PackageInfo packageInfo) async {
    final currentActionCount = state;

    if (currentActionCount >= minimumReviewWorthyActions) {
      final currentVersion = packageInfo.version;

      final lastVersion =
          await localRepository.getLastReviewRequestAppVersionKey();

      return lastVersion == null || lastVersion != currentVersion;
    }

    return false;
  }

  Future<void> markReviewRequestedForCurrentVersion(
      PackageInfo packageInfo) async {
    await localRepository.saveLastReviewRequestAppVersion(packageInfo.version);
    await localRepository.saveReviewWorthyActionCount(0);
  }
}
