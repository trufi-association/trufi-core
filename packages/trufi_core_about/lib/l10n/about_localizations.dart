import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'about_localizations_de.dart';
import 'about_localizations_en.dart';
import 'about_localizations_es.dart';
import 'about_localizations_fr.dart';
import 'about_localizations_it.dart';
import 'about_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AboutLocalizations
/// returned by `AboutLocalizations.of(context)`.
///
/// Applications need to include `AboutLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/about_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AboutLocalizations.localizationsDelegates,
///   supportedLocales: AboutLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AboutLocalizations.supportedLocales
/// property.
abstract class AboutLocalizations {
  AboutLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AboutLocalizations? of(BuildContext context) {
    return Localizations.of<AboutLocalizations>(context, AboutLocalizations);
  }

  static const LocalizationsDelegate<AboutLocalizations> delegate =
      _AboutLocalizationsDelegate();

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
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @aboutCollapseContent.
  ///
  /// In en, this message translates to:
  /// **'Trufi Association is an international NGO that promotes easier access to public transport. Our apps help everyone find the best way to get from point A to point B within their cities.\n\nIn many cities there are no official maps, routes, apps or timetables. So we compile the available information, and sometimes even map routes from scratch working with local people who know the city.  An easy-to-use transportation system contributes to greater sustainability, cleaner air and a better quality of life.'**
  String get aboutCollapseContent;

  /// No description provided for @aboutCollapseContentFoot.
  ///
  /// In en, this message translates to:
  /// **'We need mappers, developers, planners, testers, and many other hands.'**
  String get aboutCollapseContentFoot;

  /// No description provided for @aboutCollapseTitle.
  ///
  /// In en, this message translates to:
  /// **'More About Trufi Association'**
  String get aboutCollapseTitle;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'Need to get somewhere and don\'t know which Trufi or bus to take?\nThe {appName} makes it easy!\n\nTrufi Association is a team from Bolivia and around the world. We love La Llajta and public transportation, so we developed this application to make public transit more accessible. Our goal is to provide you with a practical tool that allows you to move around safely.\n\nWe strive to constantly improve the {appName} to always provide you with accurate and useful information. We know that the transportation system in {city} is constantly changing for various reasons, so it\'s possible that some routes may not be completely up to date.\n\nTo make the {appName} an effective tool, we rely on your collaboration. If you know of changes to some routes or stops, we ask you to share this information with us. Your contribution not only helps keep the app up to date, but also benefits other users who rely on the {appName}.\n\nThank you for using the {appName} to get around {city}. We hope you enjoy your time with us!'**
  String aboutContent(String appName, String city);

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutOpenSource.
  ///
  /// In en, this message translates to:
  /// **'This app is released as open source on GitHub. We welcome contributions to the code or development of an app for your own city.'**
  String get aboutOpenSource;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get menuAbout;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Public transport in {city}'**
  String tagline(String city);

  /// No description provided for @trufiWebsite.
  ///
  /// In en, this message translates to:
  /// **'Trufi Association Website'**
  String get trufiWebsite;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @volunteerTrufi.
  ///
  /// In en, this message translates to:
  /// **'Volunteer For Trufi'**
  String get volunteerTrufi;
}

class _AboutLocalizationsDelegate
    extends LocalizationsDelegate<AboutLocalizations> {
  const _AboutLocalizationsDelegate();

  @override
  Future<AboutLocalizations> load(Locale locale) {
    return SynchronousFuture<AboutLocalizations>(
      lookupAboutLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AboutLocalizationsDelegate old) => false;
}

AboutLocalizations lookupAboutLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AboutLocalizationsDe();
    case 'en':
      return AboutLocalizationsEn();
    case 'es':
      return AboutLocalizationsEs();
    case 'fr':
      return AboutLocalizationsFr();
    case 'it':
      return AboutLocalizationsIt();
    case 'pt':
      return AboutLocalizationsPt();
  }

  throw FlutterError(
    'AboutLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
