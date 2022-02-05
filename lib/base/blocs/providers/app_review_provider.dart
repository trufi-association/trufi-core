import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:trufi_core/base/widgets/alerts/app_review_dialog.dart';

class AppReviewProvider {
  static final AppReviewProvider _singleton = AppReviewProvider._internal();

  factory AppReviewProvider() => _singleton;

  AppReviewProvider._internal() {
    _load();
  }

  Future<void> _load() async {
    currentActionCount = (await _localRepository.getCurrentActionCount()) ?? 0;
  }

  final _localRepository = AppReviewProviderHiveLocalRepository();
  int minimumReviewWorthyActions = 5;
  int currentActionCount = 0;

  void incrementReviewWorthyActions() {
    currentActionCount++;
    _localRepository.saveCurrentActionCount(currentActionCount);
  }

  Future<void> reviewApp(BuildContext context) async {
    if (!kIsWeb) {
      final packageInfo = await PackageInfo.fromPlatform();
      if (await _isAppReviewAppropriate(packageInfo)) {
        AppReviewDialog.showAppReviewDialog(context).then(
          (value) => _markReviewRequestedForCurrentVersion(packageInfo),
        );
      }
    }
  }

  Future<bool> _isAppReviewAppropriate(PackageInfo packageInfo) async {
    if (currentActionCount >= minimumReviewWorthyActions) {
      final currentVersion = packageInfo.version;
      final lastVersion =
          await _localRepository.getLastReviewRequestAppVersion();

      return lastVersion == null || lastVersion != currentVersion;
    }

    return false;
  }

  Future<void> _markReviewRequestedForCurrentVersion(
      PackageInfo packageInfo) async {
    await _localRepository.saveLastReviewRequestAppVersion(packageInfo.version);
  }
}

class AppReviewProviderHiveLocalRepository {
  static const String path = "AppReviewProvider";
  static const String _lastReviewRequestAppVersionKey =
      '_lastReviewRequestAppVersionKey';
  static const String _currentActionCountKey = '_currentActionCountKey';

  late Box _box;
  AppReviewProviderHiveLocalRepository() {
    _box = Hive.box(path);
  }

  Future<String?> getLastReviewRequestAppVersion() async {
    return _box.get(_lastReviewRequestAppVersionKey) as String?;
  }

  Future<void> saveLastReviewRequestAppVersion(String data) async {
    await _box.put(_lastReviewRequestAppVersionKey, data);
  }

  Future<int?> getCurrentActionCount() async {
    return _box.get(_currentActionCountKey) as int?;
  }

  Future<void> saveCurrentActionCount(int data) async {
    await _box.put(_currentActionCountKey, data);
  }
}
