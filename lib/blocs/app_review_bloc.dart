import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../blocs/bloc_provider.dart';
import '../blocs/preferences_bloc.dart';
import '../trufi_configuration.dart';

class AppReviewBloc extends BlocBase {
  static AppReviewBloc of(BuildContext context) {
    return BlocProvider.of<AppReviewBloc>(context);
  }

  AppReviewBloc(this.preferencesBloc);

  final PreferencesBloc preferencesBloc;

  @override
  void dispose() {}

  void incrementReviewWorthyActions() {
    if (preferencesBloc.reviewWorthyActionCount != null) {
      preferencesBloc.reviewWorthyActionCount =
          preferencesBloc.reviewWorthyActionCount + 1;
    } else {
      preferencesBloc.reviewWorthyActionCount = 1;
    }
  }

  Future<bool> isAppReviewAppropriate() async {
    final minActionCount = TrufiConfiguration().minimumReviewWorthyActionCount;
    final currentActionCount = preferencesBloc.reviewWorthyActionCount;

    if (currentActionCount != null && currentActionCount >= minActionCount) {
      final currentVersion = (await PackageInfo.fromPlatform()).version;
      final lastVersion = preferencesBloc.lastReviewRequestAppVersion;

      return lastVersion == null || lastVersion != currentVersion;
    }

    return false;
  }

  Future<void> markReviewRequestedForCurrentVersion() async {
    final currentVersion = (await PackageInfo.fromPlatform()).version;
    preferencesBloc.lastReviewRequestAppVersion = currentVersion;
    preferencesBloc.reviewWorthyActionCount = null;
  }
}
