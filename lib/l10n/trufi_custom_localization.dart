import 'dart:ui';

/// Custom Translation for Corporate Identity topics
/// Necessary to overwrite existing translations
///
/// If you need more dynamic translations feel free to create an issue in Trufi Core
/// https://github.com/trufi-association/trufi-core/issues
abstract class TrufiCustomLocalization {
  /// Getter method to receive the Translation to the corresponding element
  ///
  /// [customTranslationMap] - Custom Translation Map by the host should
  /// have the format 'de', 'en' or 'de_DE', 'en_US'
  /// [locale] - The current Locale of the app
  /// [defaultTranslation] - Translation if no custom Translation can be found
  String get(
    Map<Locale, String> customTranslationMap,
    Locale locale,
    String defaultTranslation,
  ) {
    if (customTranslationMap == null || customTranslationMap.isEmpty)
      return defaultTranslation;

    if (customTranslationMap.containsKey(locale))
      return customTranslationMap[locale];

    final fallBackLocale = Locale(locale.languageCode);
    if (customTranslationMap.containsKey(fallBackLocale))
      return customTranslationMap[fallBackLocale];

    return defaultTranslation;
  }

  /// The [title] of the application
  ///
  /// Default Translation to "Trufi App"
  Map<Locale, String> title;

  /// The [tagline] is a Short Marketing text of your application
  ///
  /// Default Translation to "Public transportation in Cochabamba"
  Map<Locale, String> tagline;

  /// A sentence that describes the application's purpose
  ///
  /// In en_US, this message translates to:
  /// **'The best way to travel with trufis, micros and busses through Cochabamba.'**
  Map<Locale, String> description;
}
