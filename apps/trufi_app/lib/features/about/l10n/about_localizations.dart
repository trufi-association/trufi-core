import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'about_localizations_de.dart';
import 'about_localizations_en.dart';
import 'about_localizations_es.dart';

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
  AboutLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AboutLocalizations of(BuildContext context) {
    return Localizations.of<AboutLocalizations>(context, AboutLocalizations)!;
  }

  static const LocalizationsDelegate<AboutLocalizations> delegate = _AboutLocalizationsDelegate();

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

  /// About screen title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// App description
  ///
  /// In en, this message translates to:
  /// **'Trufi App is a POC demonstrating the v5 architecture with dynamic screens, translations, and GoRouter.'**
  String get aboutDescription;

  /// Architecture section title
  ///
  /// In en, this message translates to:
  /// **'Architecture Details'**
  String get aboutArchitectureDetails;

  /// Pattern label
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get aboutPattern;

  /// Navigation label
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get aboutNavigation;

  /// Translations label
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get aboutTranslations;

  /// State label
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get aboutState;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features Implemented'**
  String get aboutFeaturesImplemented;

  /// Reference issue section
  ///
  /// In en, this message translates to:
  /// **'Reference Issue'**
  String get aboutReferenceIssue;
}

class _AboutLocalizationsDelegate extends LocalizationsDelegate<AboutLocalizations> {
  const _AboutLocalizationsDelegate();

  @override
  Future<AboutLocalizations> load(Locale locale) {
    return SynchronousFuture<AboutLocalizations>(lookupAboutLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AboutLocalizationsDelegate old) => false;
}

AboutLocalizations lookupAboutLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AboutLocalizationsDe();
    case 'en': return AboutLocalizationsEn();
    case 'es': return AboutLocalizationsEs();
  }

  throw FlutterError(
    'AboutLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
