


import 'feedback_localizations.dart';

/// The translations for German (`de`).
class FeedbackLocalizationDe extends FeedbackLocalization {
  FeedbackLocalizationDe([String locale = 'de']) : super(locale);

  @override
  String get menuFeedback => 'Feedback';

  @override
  String get feedbackTitle => 'E-Mail senden';

  @override
  String get feedbackContent => 'Haben Sie Vorschläge für unsere App oder haben Sie Fehler in den Daten gefunden? Wir würden gerne von Ihnen hören! Bitte geben Sie Ihre E-Mail-Adresse oder Ihre Telefonnummer an, damit wir Ihnen antworten können.';
}
