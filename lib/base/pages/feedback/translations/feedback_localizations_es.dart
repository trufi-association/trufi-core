


import 'feedback_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class FeedbackLocalizationEs extends FeedbackLocalization {
  FeedbackLocalizationEs([String locale = 'es']) : super(locale);

  @override
  String get menuFeedback => 'Enviar comentarios';

  @override
  String get feedbackTitle => 'Envíanos un correo electrónico';

  @override
  String get feedbackContent => '¿Tiene sugerencias para nuestra aplicación o ha encontrado algunos errores en los datos? Nos encantaría saberlo! Asegúrese de agregar su dirección de correo electrónico o teléfono para que podamos responderlo.';
}
