import 'package:flutter/material.dart';

/// Locale configuration
class TrufiLocaleConfig {
  final List<Locale> supportedLocales;
  final int defaultLocaleIndex;

  const TrufiLocaleConfig({
    this.supportedLocales = const [Locale('en'), Locale('es'), Locale('de')],
    this.defaultLocaleIndex = 0,
  });

  Locale get defaultLocale => supportedLocales[defaultLocaleIndex];
}
