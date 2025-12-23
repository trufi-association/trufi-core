// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feedback_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FeedbackLocalizationsEn extends FeedbackLocalizations {
  FeedbackLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuFeedback => 'Feedback';

  @override
  String get feedbackTitle => 'We\'d love to hear from you!';

  @override
  String get feedbackContent =>
      'Your feedback helps us improve the app and provide better public transportation information for everyone in the city.';

  @override
  String get feedbackWhatWeWant => 'What we\'d love to hear about';

  @override
  String get feedbackBugs => 'Bugs or issues you\'ve encountered';

  @override
  String get feedbackRoutes => 'Route changes or missing stops';

  @override
  String get feedbackSuggestions => 'Ideas to improve the app';

  @override
  String get feedbackSend => 'Send Feedback';
}
