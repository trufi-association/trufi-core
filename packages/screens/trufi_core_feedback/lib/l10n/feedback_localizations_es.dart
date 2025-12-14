import 'feedback_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish (`es`).
class FeedbackLocalizationsEs extends FeedbackLocalizations {
  FeedbackLocalizationsEs([super.locale = 'es']);

  @override
  String get menuFeedback => 'Comentarios';

  @override
  String get feedbackTitle => '¡Nos encantaría saber de ti!';

  @override
  String get feedbackContent => 'Tus comentarios nos ayudan a mejorar la aplicación y proporcionar mejor información de transporte público para todos en la ciudad.';

  @override
  String get feedbackWhatWeWant => 'Qué nos gustaría saber';

  @override
  String get feedbackBugs => 'Errores o problemas que hayas encontrado';

  @override
  String get feedbackRoutes => 'Cambios de rutas o paradas faltantes';

  @override
  String get feedbackSuggestions => 'Ideas para mejorar la aplicación';

  @override
  String get feedbackSend => 'Enviar Comentarios';
}
