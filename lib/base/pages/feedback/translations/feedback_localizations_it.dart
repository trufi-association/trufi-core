


import 'feedback_localizations.dart';

/// The translations for Italian (`it`).
class FeedbackLocalizationIt extends FeedbackLocalization {
  FeedbackLocalizationIt([String locale = 'it']) : super(locale);

  @override
  String get menuFeedback => 'Invia Feedback';

  @override
  String get feedbackTitle => 'Inviaci un\'E-mail';

  @override
  String get feedbackContent => 'Hai suggerimenti per la nostra app o hai trovato errori nei dati? Ci piacerebbe avere tue notizie! Ricordati di inserire il tuo indirizzo e-mail o telefono, così potremo risponderti.';
}
