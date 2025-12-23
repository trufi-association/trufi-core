// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feedback_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FeedbackLocalizationsDe extends FeedbackLocalizations {
  FeedbackLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menuFeedback => 'Feedback';

  @override
  String get feedbackTitle => 'Wir freuen uns über Ihr Feedback!';

  @override
  String get feedbackContent =>
      'Ihr Feedback hilft uns, die App zu verbessern und bessere Informationen zum öffentlichen Nahverkehr für alle in der Stadt bereitzustellen.';

  @override
  String get feedbackWhatWeWant => 'Worüber wir gerne hören würden';

  @override
  String get feedbackBugs => 'Fehler oder Probleme, die Sie gefunden haben';

  @override
  String get feedbackRoutes => 'Routenänderungen oder fehlende Haltestellen';

  @override
  String get feedbackSuggestions => 'Ideen zur Verbesserung der App';

  @override
  String get feedbackSend => 'Feedback senden';
}
