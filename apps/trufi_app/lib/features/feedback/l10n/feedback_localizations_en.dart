// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feedback_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FeedbackLocalizationsEn extends FeedbackLocalizations {
  FeedbackLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get feedbackTitle => 'Send Feedback';

  @override
  String get feedbackSubtitle => 'Your feedback helps us improve the app';

  @override
  String get feedbackType => 'Feedback Type';

  @override
  String get feedbackTypeGeneral => 'General';

  @override
  String get feedbackTypeBug => 'Bug Report';

  @override
  String get feedbackTypeFeature => 'Feature Request';

  @override
  String get feedbackTypeRoute => 'Route Issue';

  @override
  String get feedbackRating => 'Rate your experience';

  @override
  String get feedbackMessage => 'Your Message';

  @override
  String get feedbackMessageHint => 'Tell us what you think...';

  @override
  String get feedbackSubmit => 'Submit';

  @override
  String get feedbackSuccess => 'Feedback submitted successfully!';

  @override
  String get feedbackRatingPoor => 'Poor';

  @override
  String get feedbackRatingFair => 'Fair';

  @override
  String get feedbackRatingGood => 'Good';

  @override
  String get feedbackRatingVeryGood => 'Very Good';

  @override
  String get feedbackRatingExcellent => 'Excellent!';
}
