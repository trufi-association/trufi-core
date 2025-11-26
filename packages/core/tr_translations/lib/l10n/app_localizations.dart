import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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

  /// No description provided for @instruction_distance_meters.
  ///
  /// In en, this message translates to:
  /// **'{distance} m'**
  String instruction_distance_meters(String distance);

  /// No description provided for @instruction_distance_km.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String instruction_distance_km(String distance);

  /// No description provided for @selected_on_map.
  ///
  /// In en, this message translates to:
  /// **'Selected on the map'**
  String get selected_on_map;

  /// No description provided for @default_location_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get default_location_home;

  /// No description provided for @default_location_work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get default_location_work;

  /// No description provided for @default_location_add.
  ///
  /// In en, this message translates to:
  /// **'Set {location} location'**
  String default_location_add(String location);

  /// No description provided for @default_location_setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set location'**
  String get default_location_setLocation;

  /// No description provided for @yourPlaces_menu.
  ///
  /// In en, this message translates to:
  /// **'Your Places'**
  String get yourPlaces_menu;

  /// No description provided for @feedback_menu.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedback_menu;

  /// No description provided for @feedback_title.
  ///
  /// In en, this message translates to:
  /// **'Please e-mail us'**
  String get feedback_title;

  /// No description provided for @feedback_content.
  ///
  /// In en, this message translates to:
  /// **'Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you.'**
  String get feedback_content;

  /// No description provided for @aboutUs_menu.
  ///
  /// In en, this message translates to:
  /// **'About this service'**
  String get aboutUs_menu;

  /// No description provided for @aboutUs_version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutUs_version(String version);

  /// No description provided for @aboutUs_licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutUs_licenses;

  /// No description provided for @aboutUs_openSource.
  ///
  /// In en, this message translates to:
  /// **'This app is released as open source on GitHub. Feel free to contribute to the code, or bring an app to your own city.'**
  String get aboutUs_openSource;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
