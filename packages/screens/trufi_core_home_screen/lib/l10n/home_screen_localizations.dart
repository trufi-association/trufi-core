import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'home_screen_localizations_de.dart';
import 'home_screen_localizations_en.dart';
import 'home_screen_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of HomeScreenLocalizations
/// returned by `HomeScreenLocalizations.of(context)`.
///
/// Applications need to include `HomeScreenLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/home_screen_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
///   supportedLocales: HomeScreenLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the HomeScreenLocalizations.supportedLocales
/// property.
abstract class HomeScreenLocalizations {
  HomeScreenLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static HomeScreenLocalizations of(BuildContext context) {
    return Localizations.of<HomeScreenLocalizations>(context, HomeScreenLocalizations)!;
  }

  static const LocalizationsDelegate<HomeScreenLocalizations> delegate = _HomeScreenLocalizationsDelegate();

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

  /// Menu item title for home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// Hint text for origin field
  ///
  /// In en, this message translates to:
  /// **'Select origin'**
  String get searchOrigin;

  /// Hint text for destination field
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get searchDestination;

  /// Message shown when no locations are selected
  ///
  /// In en, this message translates to:
  /// **'Select origin and destination to find routes'**
  String get selectLocations;

  /// Message shown when no routes are available
  ///
  /// In en, this message translates to:
  /// **'No routes found'**
  String get noRoutesFound;

  /// Error message when routes fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading routes'**
  String get errorNoRoutes;

  /// Duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// Duration in hours and minutes
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}min'**
  String durationHoursMinutes(int hours, int minutes);

  /// Distance in meters
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String distanceMeters(int meters);

  /// Distance in kilometers
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKilometers(String km);

  /// Walking transport mode
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get walk;

  /// Number of transfers
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transfers} =1{1 transfer} other{{count} transfers}}'**
  String transfers(int count);

  /// Departure time label
  ///
  /// In en, this message translates to:
  /// **'Departure at {time}'**
  String departureAt(String time);

  /// Arrival time label
  ///
  /// In en, this message translates to:
  /// **'Arrival at {time}'**
  String arrivalAt(String time);

  /// Label for using current location
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// Label for choosing location on map
  ///
  /// In en, this message translates to:
  /// **'Choose on Map'**
  String get chooseOnMap;

  /// Button text to confirm selected location
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// Label for a location selected on map
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// Option to set location as origin
  ///
  /// In en, this message translates to:
  /// **'Set as Origin'**
  String get setAsOrigin;

  /// Option to set location as destination
  ///
  /// In en, this message translates to:
  /// **'Set as Destination'**
  String get setAsDestination;

  /// Tooltip for share route button
  ///
  /// In en, this message translates to:
  /// **'Share route'**
  String get shareRoute;

  /// Title for shared route text
  ///
  /// In en, this message translates to:
  /// **'{appName} - Shared route'**
  String shareRouteTitle(String appName);

  /// Origin label in shared route
  ///
  /// In en, this message translates to:
  /// **'Origin: {location}'**
  String shareRouteOrigin(String location);

  /// Destination label in shared route
  ///
  /// In en, this message translates to:
  /// **'Destination: {location}'**
  String shareRouteDestination(String location);

  /// Date label in shared route
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String shareRouteDate(String date);

  /// Times label in shared route
  ///
  /// In en, this message translates to:
  /// **'Departure: {departure} → Arrival: {arrival}'**
  String shareRouteTimes(String departure, String arrival);

  /// Duration label in shared route
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String shareRouteDuration(String duration);

  /// Route summary label in shared route
  ///
  /// In en, this message translates to:
  /// **'Route: {summary}'**
  String shareRouteItinerary(String summary);

  /// Label before deep link URL
  ///
  /// In en, this message translates to:
  /// **'Open in app:'**
  String get shareRouteOpenInApp;
}

class _HomeScreenLocalizationsDelegate extends LocalizationsDelegate<HomeScreenLocalizations> {
  const _HomeScreenLocalizationsDelegate();

  @override
  Future<HomeScreenLocalizations> load(Locale locale) {
    return SynchronousFuture<HomeScreenLocalizations>(lookupHomeScreenLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_HomeScreenLocalizationsDelegate old) => false;
}

HomeScreenLocalizations lookupHomeScreenLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return HomeScreenLocalizationsDe();
    case 'en': return HomeScreenLocalizationsEn();
    case 'es': return HomeScreenLocalizationsEs();
  }

  throw FlutterError(
    'HomeScreenLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
