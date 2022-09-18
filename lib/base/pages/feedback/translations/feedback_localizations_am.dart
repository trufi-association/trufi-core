import 'feedback_localizations.dart';

/// The translations for Amharic (`am`).
class FeedbackLocalizationAm extends FeedbackLocalization {
  FeedbackLocalizationAm([String locale = 'am']) : super(locale);

  @override
  String get menuFeedback => 'ግብረ - መልስ ላክ';

  @override
  String get feedbackTitle => 'ኢሜል ይላኩልን';

  @override
  String get feedbackContent => 'ለመተግበሪያችን ጥቆማዎች አለዎት ወይም መተግበሪያ ውስጥ አንዳንድ ስህተቶች ከአገኙ? እኛ ከእርስዎ መስማት ደስ ይለናል! እኛ መልስ እንድንሰጥዎ የኢሜል አድራሻዎን ወይንም ስልክዎን ማከልዎን ያረጋግጡ ፡፡';
}
