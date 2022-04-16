


import 'feedback_localizations.dart';

/// The translations for English (`en`).
class FeedbackLocalizationEn extends FeedbackLocalization {
  FeedbackLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get menuFeedback => 'Send Feedback';

  @override
  String get feedbackTitle => 'Please e-mail us';

  @override
  String get feedbackContent => 'Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you.';
}
