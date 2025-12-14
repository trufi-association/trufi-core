import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'feedback_localizations_de.dart';
import 'feedback_localizations_en.dart';
import 'feedback_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FeedbackLocalizations
/// returned by `FeedbackLocalizations.of(context)`.
///
/// Applications need to include `FeedbackLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/feedback_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FeedbackLocalizations.localizationsDelegates,
///   supportedLocales: FeedbackLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
abstract class FeedbackLocalizations {
  FeedbackLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FeedbackLocalizations? of(BuildContext context) {
    return Localizations.of<FeedbackLocalizations>(context, FeedbackLocalizations);
  }

  static const LocalizationsDelegate<FeedbackLocalizations> delegate =
      _FeedbackLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// Menu item for feedback screen
  String get menuFeedback;

  /// Title on feedback screen
  String get feedbackTitle;

  /// Main content explaining feedback importance
  String get feedbackContent;

  /// Section title for feedback types
  String get feedbackWhatWeWant;

  /// Feedback type: bugs
  String get feedbackBugs;

  /// Feedback type: routes
  String get feedbackRoutes;

  /// Feedback type: suggestions
  String get feedbackSuggestions;

  /// Button to open feedback form
  String get feedbackSend;
}

class _FeedbackLocalizationsDelegate
    extends LocalizationsDelegate<FeedbackLocalizations> {
  const _FeedbackLocalizationsDelegate();

  @override
  Future<FeedbackLocalizations> load(Locale locale) {
    return SynchronousFuture<FeedbackLocalizations>(
      lookupFeedbackLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_FeedbackLocalizationsDelegate old) => false;
}

FeedbackLocalizations lookupFeedbackLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return FeedbackLocalizationsDe();
    case 'en':
      return FeedbackLocalizationsEn();
    case 'es':
      return FeedbackLocalizationsEs();
  }

  throw FlutterError(
    'FeedbackLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
