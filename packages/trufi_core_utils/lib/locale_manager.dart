import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the current locale for the app with persistence
class LocaleManager extends ChangeNotifier {
  static const _storageKey = 'trufi_locale';

  Locale _currentLocale;

  LocaleManager({required Locale defaultLocale}) : _currentLocale = defaultLocale {
    _loadSavedLocale();
  }

  Locale get currentLocale => _currentLocale;

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_storageKey);
    if (savedCode != null && savedCode != _currentLocale.languageCode) {
      _currentLocale = Locale(savedCode);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _persistLocale(locale.languageCode);
      notifyListeners();
    }
  }

  Future<void> _persistLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, code);
  }

  void setLocaleByCode(String languageCode) {
    setLocale(Locale(languageCode));
  }

  static LocaleManager read(BuildContext context) => context.read<LocaleManager>();
  static LocaleManager watch(BuildContext context) => context.watch<LocaleManager>();
}
