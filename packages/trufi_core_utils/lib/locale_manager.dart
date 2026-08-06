import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the current locale for the app with persistence
class LocaleManager extends ChangeNotifier {
  static const _storageKey = 'trufi_locale';

  Locale _currentLocale;
  final List<Locale> supportedLocales;

  /// Endonyms for languages this app ships, merged over the built-in table.
  ///
  /// Cities localize Trufi into languages Flutter itself doesn't know
  /// (Quechua, Aymara, …); without an entry here the picker would show the
  /// bare code ("QU") instead of the language's own name.
  ///
  /// ```dart
  /// LocaleManager(
  ///   defaultLocale: const Locale('qu'),
  ///   supportedLocales: const [Locale('qu'), Locale('es')],
  ///   languageNames: const {'qu': 'Runasimi'},
  /// )
  /// ```
  final Map<String, String> languageNames;

  LocaleManager({
    required Locale defaultLocale,
    this.supportedLocales = const [Locale('en'), Locale('es'), Locale('de')],
    this.languageNames = const {},
  }) : _currentLocale = defaultLocale {
    _loadSavedLocale();
  }

  Locale get currentLocale => _currentLocale;

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_storageKey);
    // Ignore a stored language the app no longer ships, otherwise the manager
    // and the MaterialApp (which resolves to supportedLocales.first) would
    // disagree and the picker would highlight nothing.
    final isSupported = supportedLocales.any(
      (locale) => locale.languageCode == savedCode,
    );
    if (savedCode != null &&
        isSupported &&
        savedCode != _currentLocale.languageCode) {
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

  /// Returns this manager's display name for [code], preferring the
  /// app-provided [languageNames] over the built-in table.
  String displayName(String code) =>
      languageNames[code] ?? displayNameForCode(code);

  /// Returns a human-readable display name for a language code.
  ///
  /// Covers the languages trufi-core ships plus a few common ones; apps
  /// adding their own should pass [languageNames] so the picker shows the
  /// endonym instead of the raw code.
  static String displayNameForCode(String code) =>
      _endonyms[code] ?? code.toUpperCase();

  /// Endonyms for the language codes shipped by core and current city apps.
  /// Data, not control flow: extend the map when a city adds a language.
  static const Map<String, String> _endonyms = {
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
    'pt': 'Português',
    'it': 'Italiano',
    'ar': 'العربية',
  };

  static LocaleManager read(BuildContext context) =>
      context.read<LocaleManager>();
  static LocaleManager watch(BuildContext context) =>
      context.watch<LocaleManager>();
}
