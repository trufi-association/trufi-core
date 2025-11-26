import 'package:flutter/material.dart';
import 'package:trufi_core/localization/app_localization.dart';

/// A delegate for localizing the application.
/// It handles loading and providing localized strings based on the current locale.
class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalization> load(Locale locale) async {
    final appLocalization = AppLocalization(locale);
    await appLocalization.loadLanguage();
    return appLocalization;
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}
