// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feedback_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FeedbackLocalizationsDe extends FeedbackLocalizations {
  FeedbackLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get feedbackTitle => 'Feedback senden';

  @override
  String get feedbackSubtitle => 'Ihr Feedback hilft uns, die App zu verbessern';

  @override
  String get feedbackType => 'Feedback-Typ';

  @override
  String get feedbackTypeGeneral => 'Allgemein';

  @override
  String get feedbackTypeBug => 'Fehlerbericht';

  @override
  String get feedbackTypeFeature => 'Funktionsanfrage';

  @override
  String get feedbackTypeRoute => 'Routenproblem';

  @override
  String get feedbackRating => 'Bewerten Sie Ihre Erfahrung';

  @override
  String get feedbackMessage => 'Ihre Nachricht';

  @override
  String get feedbackMessageHint => 'Sagen Sie uns, was Sie denken...';

  @override
  String get feedbackSubmit => 'Absenden';

  @override
  String get feedbackSuccess => 'Feedback erfolgreich gesendet!';

  @override
  String get feedbackRatingPoor => 'Schlecht';

  @override
  String get feedbackRatingFair => 'Mäßiswg';

  @override
  String get feedbackRatingGood => 'Gut';

  @override
  String get feedbackRatingVeryGood => 'Sehr gut';

  @override
  String get feedbackRatingExcellent => 'Ausgezeichnet!';
}
