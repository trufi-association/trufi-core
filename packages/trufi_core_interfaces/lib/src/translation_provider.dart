/// Base interface for all translation providers
abstract class TranslationProvider {
  String get locale;

  // Common method to check if a key exists
  bool hasTranslation(String key);
}
