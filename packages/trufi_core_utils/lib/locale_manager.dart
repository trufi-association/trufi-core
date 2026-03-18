import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the current locale for the app with persistence
class LocaleManager extends ChangeNotifier {
  static const _storageKey = 'trufi_locale';

  Locale _currentLocale;
  final List<Locale> supportedLocales;

  LocaleManager({
    required Locale defaultLocale,
    this.supportedLocales = const [Locale('en'), Locale('es'), Locale('de')],
  }) : _currentLocale = defaultLocale {
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

  /// Returns a human-readable display name for a language code.
  static String displayNameForCode(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'de': return 'Deutsch';
      case 'fr': return 'Français';
      case 'pt': return 'Português';
      case 'it': return 'Italiano';
      default: return code.toUpperCase();
    }
  }

  static LocaleManager read(BuildContext context) =>
      context.read<LocaleManager>();
  static LocaleManager watch(BuildContext context) =>
      context.watch<LocaleManager>();
}
