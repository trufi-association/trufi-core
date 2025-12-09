import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'settings_localizations_de.dart';
import 'settings_localizations_en.dart';
import 'settings_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SettingsLocalizations
/// returned by `SettingsLocalizations.of(context)`.
///
/// Applications need to include `SettingsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/settings_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SettingsLocalizations.localizationsDelegates,
///   supportedLocales: SettingsLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the SettingsLocalizations.supportedLocales
/// property.
abstract class SettingsLocalizations {
  SettingsLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SettingsLocalizations of(BuildContext context) {
    return Localizations.of<SettingsLocalizations>(context, SettingsLocalizations)!;
  }

  static const LocalizationsDelegate<SettingsLocalizations> delegate = _SettingsLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es')
  ];

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language selection instruction
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language:'**
  String get settingsSelectLanguage;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsThemeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsThemeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystem;

  /// Demo section title
  ///
  /// In en, this message translates to:
  /// **'Translation Demo'**
  String get settingsTranslationDemo;

  /// Demo section description
  ///
  /// In en, this message translates to:
  /// **'Change the language above to see these translations update dynamically:'**
  String get settingsTranslationDemoDesc;

  /// Registered modules section
  ///
  /// In en, this message translates to:
  /// **'Registered Modules'**
  String get settingsRegisteredModules;
}

class _SettingsLocalizationsDelegate extends LocalizationsDelegate<SettingsLocalizations> {
  const _SettingsLocalizationsDelegate();

  @override
  Future<SettingsLocalizations> load(Locale locale) {
    return SynchronousFuture<SettingsLocalizations>(lookupSettingsLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SettingsLocalizationsDelegate old) => false;
}

SettingsLocalizations lookupSettingsLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return SettingsLocalizationsDe();
    case 'en': return SettingsLocalizationsEn();
    case 'es': return SettingsLocalizationsEs();
  }

  throw FlutterError(
    'SettingsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
