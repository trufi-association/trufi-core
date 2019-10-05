import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:package_info/package_info.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';

class AppReviewBloc extends BlocBase {
  static AppReviewBloc of(BuildContext context) {
    return BlocProvider.of<AppReviewBloc>(context);
  }

  AppReviewBloc(this.preferencesBloc);

  final PreferencesBloc preferencesBloc;

  @override
  void dispose() {
  }

  void incrementReviewWorthyActions() {
    if (this.preferencesBloc.reviewWorthyActionCount != null) {
      this.preferencesBloc.reviewWorthyActionCount =
        this.preferencesBloc.reviewWorthyActionCount + 1;
    } else {
      this.preferencesBloc.reviewWorthyActionCount = 1;
    }
  }

  Future<bool> isAppReviewAppropriate() async {
    final config = GlobalConfiguration();
    final minActionCount = config.getInt("minimumReviewWorthyActionCount");
    final currentActionCount = this.preferencesBloc.reviewWorthyActionCount;

    if (currentActionCount != null && currentActionCount >= minActionCount) {
      final currentVersion = (await PackageInfo.fromPlatform()).version;
      final lastVersion = this.preferencesBloc.lastReviewRequestAppVersion;

      return lastVersion == null || lastVersion != currentVersion;
    }

    return false;
  }

  void markReviewRequestedForCurrentVersion() async {
    final currentVersion = (await PackageInfo.fromPlatform()).version;
    this.preferencesBloc.lastReviewRequestAppVersion = currentVersion;
    this.preferencesBloc.reviewWorthyActionCount = null;
  }
}