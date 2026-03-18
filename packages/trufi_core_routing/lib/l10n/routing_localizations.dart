import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'routing_localizations_de.dart';
import 'routing_localizations_en.dart';
import 'routing_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of RoutingLocalizations
/// returned by `RoutingLocalizations.of(context)`.
///
/// Applications need to include `RoutingLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/routing_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: RoutingLocalizations.localizationsDelegates,
///   supportedLocales: RoutingLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the RoutingLocalizations.supportedLocales
/// property.
abstract class RoutingLocalizations {
  RoutingLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static RoutingLocalizations of(BuildContext context) {
    return Localizations.of<RoutingLocalizations>(
      context,
      RoutingLocalizations,
    )!;
  }

  static const LocalizationsDelegate<RoutingLocalizations> delegate =
      _RoutingLocalizationsDelegate();

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

  /// Title for walking speed preference section
  ///
  /// In en, this message translates to:
  /// **'Walking speed'**
  String get prefsWalkingSpeed;

  /// Label for slow walking speed option
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get prefsSpeedSlow;

  /// Label for normal walking speed option
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get prefsSpeedNormal;

  /// Label for fast walking speed option
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get prefsSpeedFast;

  /// Title for maximum walking distance preference section
  ///
  /// In en, this message translates to:
  /// **'Maximum walking distance'**
  String get prefsMaxWalkDistance;

  /// Label for no walk distance limit option
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get prefsNoLimit;

  /// Title for transport modes preference section
  ///
  /// In en, this message translates to:
  /// **'Transport modes'**
  String get prefsTransportModes;

  /// Label for transit transport mode
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get prefsModeTransit;

  /// Label for walk transport mode
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get prefsModeWalk;

  /// Label for bicycle transport mode
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get prefsModeBicycle;

  /// Label for wheelchair accessibility toggle
  ///
  /// In en, this message translates to:
  /// **'Wheelchair accessible'**
  String get prefsWheelchairAccessible;

  /// Description when wheelchair mode is enabled
  ///
  /// In en, this message translates to:
  /// **'Routes avoid stairs and steep slopes'**
  String get prefsWheelchairOn;

  /// Description when wheelchair mode is disabled
  ///
  /// In en, this message translates to:
  /// **'Include all routes'**
  String get prefsWheelchairOff;
}

class _RoutingLocalizationsDelegate
    extends LocalizationsDelegate<RoutingLocalizations> {
  const _RoutingLocalizationsDelegate();

  @override
  Future<RoutingLocalizations> load(Locale locale) {
    return SynchronousFuture<RoutingLocalizations>(
      lookupRoutingLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_RoutingLocalizationsDelegate old) => false;
}

RoutingLocalizations lookupRoutingLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return RoutingLocalizationsDe();
    case 'en':
      return RoutingLocalizationsEn();
    case 'es':
      return RoutingLocalizationsEs();
  }

  throw FlutterError(
    'RoutingLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
