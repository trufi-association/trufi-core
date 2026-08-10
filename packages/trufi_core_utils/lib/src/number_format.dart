import 'package:intl/intl.dart';

/// A [NumberFormat] that never throws on an unknown locale.
///
/// `NumberFormat(pattern, locale)` throws an [ArgumentError] for locales
/// intl has no number symbols for — which includes exactly the languages
/// cities add through the N-language model (Quechua, Aymara, Guaraní).
/// Falling back to the pattern's default locale keeps the number readable
/// instead of red-screening the widget (#945 fresh-review finding).
NumberFormat safeNumberFormat(String pattern, String locale) {
  try {
    return NumberFormat(pattern, locale);
  } catch (_) {
    return NumberFormat(pattern);
  }
}
