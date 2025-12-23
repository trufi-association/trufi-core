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
///
/// Applications need to include `FaresLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/fares_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FaresLocalizations.localizationsDelegates,
///   supportedLocales: FaresLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FaresLocalizations.supportedLocales
/// property.
abstract class FaresLocalizations {
  FaresLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FaresLocalizations of(BuildContext context) {
    return Localizations.of<FaresLocalizations>(context, FaresLocalizations)!;
  }

  static const LocalizationsDelegate<FaresLocalizations> delegate =
      _FaresLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
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
  ///
  /// In en, this message translates to:
  /// **'Fares'**
  String get menuFares;

  /// Title on fares screen
  ///
  /// In en, this message translates to:
  /// **'Fare Information'**
  String get faresTitle;

  /// Subtitle explaining the fares screen
  ///
  /// In en, this message translates to:
  /// **'Current prices for public transportation'**
  String get faresSubtitle;

  /// Label for regular fare
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get faresRegular;

  /// Label for student fare
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get faresStudent;

  /// Label for senior/elderly fare
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get faresSenior;

  /// Shows when fare info was last updated
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String faresLastUpdated(String date);

  /// Button to open external fare information
  ///
  /// In en, this message translates to:
  /// **'More Information'**
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
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FaresLocalizationsDe();
    case 'en':
      return FaresLocalizationsEn();
    case 'es':
      return FaresLocalizationsEs();
  }

  throw FlutterError(
    'FaresLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
