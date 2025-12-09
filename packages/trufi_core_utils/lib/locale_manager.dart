import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Manages the current locale for the app
class LocaleManager extends ChangeNotifier {
  Locale _currentLocale;

  LocaleManager({required Locale defaultLocale}) : _currentLocale = defaultLocale;

  Locale get currentLocale => _currentLocale;

  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  void setLocaleByCode(String languageCode) {
    setLocale(Locale(languageCode));
  }

  static LocaleManager read(BuildContext context) => context.read<LocaleManager>();
  static LocaleManager watch(BuildContext context) => context.watch<LocaleManager>();
}
