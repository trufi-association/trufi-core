import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'about_localizations_de.dart';
import 'about_localizations_en.dart';
import 'about_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AboutLocalization
/// returned by `AboutLocalization.of(context)`.
///
/// Applications need to include `AboutLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/about_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AboutLocalization.localizationsDelegates,
///   supportedLocales: AboutLocalization.supportedLocales,
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
/// be consistent with the languages listed in the AboutLocalization.supportedLocales
/// property.
abstract class AboutLocalization {
  AboutLocalization(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AboutLocalization? of(BuildContext context) {
    return Localizations.of<AboutLocalization>(context, AboutLocalization);
  }

  static const LocalizationsDelegate<AboutLocalization> delegate =
      _AboutLocalizationDelegate();

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

  /// A short marketing sentence that describes the app
  ///
  /// In en, this message translates to:
  /// **'Trufi Association is an international NGO that promotes easier access to public transport. Our apps help everyone find the best way to get from point A to point B within their cities.\n\nIn many cities there are no official maps, routes, apps or timetables. So we compile the available information, and sometimes even map routes from scratch working with local people who know the city.  An easy-to-use transportation system contributes to greater sustainability, cleaner air and a better quality of life.'**
  String get aboutCollapseContent;

  /// Call to action for volunteers
  ///
  /// In en, this message translates to:
  /// **'We need mappers, developers, planners, testers, and many other hands.'**
  String get aboutCollapseContentFoot;

  /// Title for expandable section about Trufi
  ///
  /// In en, this message translates to:
  /// **'More About Trufi Association'**
  String get aboutCollapseTitle;

  /// Text displayed on the about page
  ///
  /// In en, this message translates to:
  /// **'Need to go somewhere and don\'t know which trufi or bus to take?\nThe {appName} makes it easy!\n\nTrufi Association is a team from Bolivia and beyond. We love La Llajta and public transportation, that\'s why we developed this application to make transportation easy. Our goal is to provide you with a practical tool that allows you to navigate with confidence.\n\nWe are committed to the continuous improvement of {appName} to offer you more and more accurate and useful information. We know that the transportation system in {city} undergoes changes due to different reasons, so it is possible that some routes are not completely up to date.\n\nTo make {appName} an effective tool, we rely on the collaboration of our users. If you are aware of changes in some routes or stops, we encourage you to share this information with us. Your contribution will not only help keep the app up to date, but will also benefit other users who rely on {appName}.\n\nThank you for choosing {appName} to move around {city}, we hope you enjoy your experience with us!'**
  String aboutContent(String appName, String city);

  /// Button label to show licenses
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutLicenses;

  /// A note about open source
  ///
  /// In en, this message translates to:
  /// **'This app is released as open source on GitHub. Feel free to contribute to the code, or bring an app to your own city.'**
  String get aboutOpenSource;

  /// Menu item that shows the about page
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get menuAbout;

  /// A short marketing sentence that describes the app
  ///
  /// In en, this message translates to:
  /// **'Public transportation in {city}'**
  String tagline(String city);

  /// Link text to Trufi website
  ///
  /// In en, this message translates to:
  /// **'Trufi Association Website'**
  String get trufiWebsite;

  /// The application's version
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Link text to volunteer page
  ///
  /// In en, this message translates to:
  /// **'Volunteer For Trufi'**
  String get volunteerTrufi;
}

class _AboutLocalizationDelegate
    extends LocalizationsDelegate<AboutLocalization> {
  const _AboutLocalizationDelegate();

  @override
  Future<AboutLocalization> load(Locale locale) {
    return SynchronousFuture<AboutLocalization>(
      lookupAboutLocalization(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AboutLocalizationDelegate old) => false;
}

AboutLocalization lookupAboutLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AboutLocalizationDe();
    case 'en':
      return AboutLocalizationEn();
    case 'es':
      return AboutLocalizationEs();
  }

  throw FlutterError(
    'AboutLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
