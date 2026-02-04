// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CoreLocalizationsEn extends CoreLocalizations {
  CoreLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Trufi App';

  @override
  String get appLoading => 'Loading...';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navFeedback => 'Feedback';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAbout => 'About';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorInitialization => 'Failed to initialize app';

  @override
  String get actionRetry => 'Retry';

  @override
  String get errorPageNotFound => 'Page not found';

  @override
  String get actionGoHome => 'Go Home';

  @override
  String get titleError => 'Error';

  @override
  String unreadCount(int count) {
    return '$count unread';
  }

  @override
  String get markAllAsRead => 'Mark all as read';
}
