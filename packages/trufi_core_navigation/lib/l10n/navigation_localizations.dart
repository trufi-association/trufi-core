import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'navigation_localizations_de.dart';
import 'navigation_localizations_en.dart';
import 'navigation_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NavigationLocalizations
/// returned by `NavigationLocalizations.of(context)`.
///
/// Applications need to include `NavigationLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/navigation_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NavigationLocalizations.localizationsDelegates,
///   supportedLocales: NavigationLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the NavigationLocalizations.supportedLocales
/// property.
abstract class NavigationLocalizations {
  NavigationLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NavigationLocalizations of(BuildContext context) {
    return Localizations.of<NavigationLocalizations>(
      context,
      NavigationLocalizations,
    )!;
  }

  static const LocalizationsDelegate<NavigationLocalizations> delegate =
      _NavigationLocalizationsDelegate();

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

  /// Button and title for exiting navigation
  ///
  /// In en, this message translates to:
  /// **'Exit Navigation'**
  String get navExitNavigation;

  /// Title of exit navigation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Exit Navigation?'**
  String get navExitConfirmTitle;

  /// Message in exit navigation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop navigating this route?'**
  String get navExitConfirmMessage;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get navCancel;

  /// Exit button label
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get navExit;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get navClose;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get navRetry;

  /// Settings button label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Message when user arrives at destination
  ///
  /// In en, this message translates to:
  /// **'You have arrived!'**
  String get navArrived;

  /// Warning when user is off the planned route
  ///
  /// In en, this message translates to:
  /// **'You appear to be off the route'**
  String get navOffRoute;

  /// Warning when GPS signal is weak
  ///
  /// In en, this message translates to:
  /// **'GPS signal is weak'**
  String get navWeakGps;

  /// Prefix for next instruction
  ///
  /// In en, this message translates to:
  /// **'Next: '**
  String get navNext;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get navError;

  /// Message while navigation is starting
  ///
  /// In en, this message translates to:
  /// **'Starting navigation...'**
  String get navStarting;

  /// Message while obtaining user location
  ///
  /// In en, this message translates to:
  /// **'Getting your location'**
  String get navGettingLocation;

  /// Error when location tracking fails to start
  ///
  /// In en, this message translates to:
  /// **'Could not start location tracking'**
  String get navCouldNotStartTracking;

  /// Short arrival notification
  ///
  /// In en, this message translates to:
  /// **'You have arrived'**
  String get navArrivedShort;

  /// Label for one remaining stop
  ///
  /// In en, this message translates to:
  /// **'1 stop'**
  String get navOneStop;

  /// Label for multiple remaining stops
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String navStops(int count);

  /// Instruction to exit at a specific stop
  ///
  /// In en, this message translates to:
  /// **'Exit at {stopName}'**
  String navExitAt(String stopName);

  /// Label for the final destination
  ///
  /// In en, this message translates to:
  /// **'Final destination'**
  String get navFinalDestination;

  /// Error when location permission is denied
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get navPermissionDenied;

  /// Error when location permission is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Please enable in settings.'**
  String get navPermissionPermanentlyDenied;

  /// Error when location services are disabled
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them.'**
  String get navLocationDisabled;

  /// Label for the route origin point
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get navOrigin;

  /// Label for a transfer point between routes
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get navTransfer;

  /// Label for the route destination point
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get navDestination;
}

class _NavigationLocalizationsDelegate
    extends LocalizationsDelegate<NavigationLocalizations> {
  const _NavigationLocalizationsDelegate();

  @override
  Future<NavigationLocalizations> load(Locale locale) {
    return SynchronousFuture<NavigationLocalizations>(
      lookupNavigationLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_NavigationLocalizationsDelegate old) => false;
}

NavigationLocalizations lookupNavigationLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return NavigationLocalizationsDe();
    case 'en':
      return NavigationLocalizationsEn();
    case 'es':
      return NavigationLocalizationsEs();
  }

  throw FlutterError(
    'NavigationLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
