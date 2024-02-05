import 'feedback_localizations.dart';

/// The translations for Portuguese (`pt`).
class FeedbackLocalizationPt extends FeedbackLocalization {
  FeedbackLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get menuFeedback => 'Enviar feedback';

  @override
  String get feedbackTitle => 'Envie-nos um comentário';

  @override
  String get feedbackContent => 'Você tem sugestões para nosso aplicativo ou encontrou algum erro nos dados? Gostaríamos muito de te ouvir! Por favor, certifique-se de adicionar seu endereço de e-mail ou telefone, para que possamos entrar em contato.';
}
