// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feedback_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FeedbackLocalizationsEs extends FeedbackLocalizations {
  FeedbackLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get feedbackTitle => 'Enviar Comentarios';

  @override
  String get feedbackSubtitle => 'Tus comentarios nos ayudan a mejorar la app';

  @override
  String get feedbackType => 'Tipo de Comentario';

  @override
  String get feedbackTypeGeneral => 'General';

  @override
  String get feedbackTypeBug => 'Reporte de Error';

  @override
  String get feedbackTypeFeature => 'Solicitud de Función';

  @override
  String get feedbackTypeRoute => 'Problema de Ruta';

  @override
  String get feedbackRating => 'Califica tu experiencia';

  @override
  String get feedbackMessage => 'Tu Mensaje';

  @override
  String get feedbackMessageHint => 'Cuéntanos qué piensas...';

  @override
  String get feedbackSubmit => 'Enviar';

  @override
  String get feedbackSuccess => '¡Comentarios enviados exitosamente!';

  @override
  String get feedbackRatingPoor => 'Malo';

  @override
  String get feedbackRatingFair => 'Regular';

  @override
  String get feedbackRatingGood => 'Bueno';

  @override
  String get feedbackRatingVeryGood => 'Muy Bueno';

  @override
  String get feedbackRatingExcellent => '¡Excelente!';
}
