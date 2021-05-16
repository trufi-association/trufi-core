class LanguageConfiguration {
  LanguageConfiguration(
    this.languageCode,
    this.countryCode,
    this.displayName, {
    this.isDefault = false,
  });

  final String languageCode;
  final String countryCode;
  final String displayName;
  final bool isDefault;
}
