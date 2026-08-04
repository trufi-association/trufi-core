import 'package:flutter/material.dart';

/// Locale configuration
class TrufiLocaleConfig {
  final List<Locale> supportedLocales;
  final int defaultLocaleIndex;

  /// Endonyms for languages beyond the ones trufi-core knows, so the language
  /// picker shows e.g. "Runasimi" instead of the bare code "QU".
  final Map<String, String> languageNames;

  const TrufiLocaleConfig({
    this.supportedLocales = const [Locale('en'), Locale('es'), Locale('de')],
    this.defaultLocaleIndex = 0,
    this.languageNames = const {},
  });

  Locale get defaultLocale => supportedLocales[defaultLocaleIndex];
}
