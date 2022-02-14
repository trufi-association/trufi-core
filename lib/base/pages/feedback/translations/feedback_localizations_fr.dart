


import 'feedback_localizations.dart';

/// The translations for French (`fr`).
class FeedbackLocalizationFr extends FeedbackLocalization {
  FeedbackLocalizationFr([String locale = 'fr']) : super(locale);

  @override
  String get menuFeedback => 'Envoyer un commentaire';

  @override
  String get feedbackTitle => 'Envoyez-nous un e-mail';

  @override
  String get feedbackContent => 'Avez-vous des suggestions pour notre application ou avez-vous trouvé des erreurs dans les données? Nous aimerions le savoir! Assurez-vous d\'ajouter votre adresse électronique ou votre numéro de téléphone pour que nous puissions vous répondre.';
}
