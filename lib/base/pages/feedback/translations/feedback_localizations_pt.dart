


import 'feedback_localizations.dart';

/// The translations for Portuguese (`pt`).
class FeedbackLocalizationPt extends FeedbackLocalization {
  FeedbackLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get menuFeedback => 'Enviar comentários.';

  @override
  String get feedbackTitle => 'Envie-nos um e-mail';

  @override
  String get feedbackContent => 'Você tem sugestões para o nosso aplicativo ou encontrou alguns erros nos dados?\n Gostaríamos muito de ouvir de você!\nCertifique-se de adicionar seu endereço de e-mail ou telefone, para que possamos responder a você.';
}
