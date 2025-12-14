import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fares_localizations_de.dart';
import 'fares_localizations_en.dart';
import 'fares_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FaresLocalizations
/// returned by `FaresLocalizations.of(context)`.
abstract class FaresLocalizations {
  FaresLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FaresLocalizations? of(BuildContext context) {
    return Localizations.of<FaresLocalizations>(context, FaresLocalizations);
  }

  static const LocalizationsDelegate<FaresLocalizations> delegate =
      _FaresLocalizationsDelegate();

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

  /// Menu item for fares screen
  String get menuFares;

  /// Title on fares screen
  String get faresTitle;

  /// Subtitle explaining the fares screen
  String get faresSubtitle;

  /// Label for regular fare
  String get faresRegular;

  /// Label for student fare
  String get faresStudent;

  /// Label for senior/elderly fare
  String get faresSenior;

  /// Shows when fare info was last updated
  String faresLastUpdated(String date);

  /// Button to open external fare information
  String get faresMoreInfo;
}

class _FaresLocalizationsDelegate
    extends LocalizationsDelegate<FaresLocalizations> {
  const _FaresLocalizationsDelegate();

  @override
  Future<FaresLocalizations> load(Locale locale) {
    return SynchronousFuture<FaresLocalizations>(
      lookupFaresLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_FaresLocalizationsDelegate old) => false;
}

FaresLocalizations lookupFaresLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return FaresLocalizationsDe();
    case 'en':
      return FaresLocalizationsEn();
    case 'es':
      return FaresLocalizationsEs();
  }

  throw FlutterError(
    'FaresLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
