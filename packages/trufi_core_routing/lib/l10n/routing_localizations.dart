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

  /// Service-hours indicator label when the route is currently running. {time} is the closing time, e.g. '22:00'.
  ///
  /// In en, this message translates to:
  /// **'Active · closes at {time}'**
  String serviceActiveClosesAt(String time);

  /// Service-hours indicator label when the route runs today but the current time is before its start. {time} is the opening time.
  ///
  /// In en, this message translates to:
  /// **'Closed · opens at {time}'**
  String serviceClosedOpensAt(String time);

  /// Service-hours indicator label when the next service is on a different weekday. {day} is the localized day name (e.g. 'tomorrow', 'Mon'), {time} is the opening time.
  ///
  /// In en, this message translates to:
  /// **'Closed · opens {day} at {time}'**
  String serviceClosedOpensDayAt(String day, String time);

  /// Fallback service-hours label and per-day cell when the route doesn't operate that day.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get serviceClosed;

  /// Used inside serviceClosedOpensDayAt when the next service is on the next calendar day.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get serviceTomorrow;

  /// Description of the offline Trufi Planner engine in selectors
  ///
  /// In en, this message translates to:
  /// **'Finds routes using the data saved on your device.'**
  String get trufiPlannerLocalDescription;

  /// Description of the server-backed Trufi Planner engine in selectors
  ///
  /// In en, this message translates to:
  /// **'Finds routes through our own service. Needs a connection.'**
  String get trufiPlannerRemoteDescription;

  /// Title of the Trufi Planner info card in routing preferences
  ///
  /// In en, this message translates to:
  /// **'About Trufi Planner'**
  String get trufiPlannerInfoTitle;

  /// First line of the Trufi Planner info card
  ///
  /// In en, this message translates to:
  /// **'Trufi Planner is our own routing engine (not OTP).'**
  String get trufiPlannerInfoIntro;

  /// Info card body for the offline variant
  ///
  /// In en, this message translates to:
  /// **'On mobile it runs 100% offline, using the GTFS data bundled with the app — results may differ from online engines.'**
  String get trufiPlannerInfoLocalBody;

  /// Info card body for the server-backed variant
  ///
  /// In en, this message translates to:
  /// **'This web version queries our server; results may differ from OTP because it uses a different algorithm and data.'**
  String get trufiPlannerInfoRemoteBody;

  /// Description shown for OpenTripPlanner engines in the routing settings.
  ///
  /// In en, this message translates to:
  /// **'Finds routes through an online service. May have more up-to-date information.'**
  String get otpOnlineDescription;
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
