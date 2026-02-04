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
  HomeScreenLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static HomeScreenLocalizations of(BuildContext context) {
    return Localizations.of<HomeScreenLocalizations>(
      context,
      HomeScreenLocalizations,
    )!;
  }

  static const LocalizationsDelegate<HomeScreenLocalizations> delegate =
      _HomeScreenLocalizationsDelegate();

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

  /// Title for trip details screen
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// Label for departure time
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// Label for arrival time
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// Label for total distance
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get totalDistance;

  /// Label for walking distance
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// Section title for trip legs
  ///
  /// In en, this message translates to:
  /// **'Trip Steps'**
  String get tripSteps;

  /// Label before headsign destination
  ///
  /// In en, this message translates to:
  /// **'Towards'**
  String get towards;

  /// Label for intermediate stops
  ///
  /// In en, this message translates to:
  /// **'stops'**
  String get stops;

  /// Bike transport mode
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get bike;

  /// Train transport mode
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get train;

  /// Label for transfers count
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfersLabel;

  /// Label showing the transit agency operating a route
  ///
  /// In en, this message translates to:
  /// **'Operated by {agency}'**
  String operatedBy(String agency);

  /// Button to view fare information
  ///
  /// In en, this message translates to:
  /// **'View fares'**
  String get viewFares;

  /// CO2 emissions in grams
  ///
  /// In en, this message translates to:
  /// **'{grams}g CO₂'**
  String co2Emissions(String grams);

  /// Title for location permission denied dialog
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermissionTitle;

  /// Message when location permission is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it in your device settings to use this feature.'**
  String get locationPermissionDeniedMessage;

  /// Title for location services disabled dialog
  ///
  /// In en, this message translates to:
  /// **'Location Disabled'**
  String get locationDisabledTitle;

  /// Message when location services are disabled
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled on your device. Please enable them to use this feature.'**
  String get locationDisabledMessage;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Open settings button label
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get buttonOpenSettings;

  /// Apply button label
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get buttonApply;

  /// Empty state title when no route is searched
  ///
  /// In en, this message translates to:
  /// **'Search for a route'**
  String get searchForRoute;

  /// Empty state hint when no route is searched
  ///
  /// In en, this message translates to:
  /// **'Enter origin and destination to find routes'**
  String get searchForRouteHint;

  /// Tooltip for share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get tooltipShare;

  /// Tooltip for close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tooltipClose;

  /// Time mode option for leaving immediately
  ///
  /// In en, this message translates to:
  /// **'Leave now'**
  String get leaveNow;

  /// Time mode option for departing at specific time
  ///
  /// In en, this message translates to:
  /// **'Depart at...'**
  String get departAt;

  /// Label showing departure at specific time
  ///
  /// In en, this message translates to:
  /// **'Depart {time}'**
  String departAtTime(String time);

  /// Time mode option for arriving by specific time
  ///
  /// In en, this message translates to:
  /// **'Arrive by...'**
  String get arriveBy;

  /// Label showing arrival by specific time
  ///
  /// In en, this message translates to:
  /// **'Arrive by {time}'**
  String arriveByTime(String time);

  /// Label for today's date
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for tomorrow's date
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Label for tomorrow with time
  ///
  /// In en, this message translates to:
  /// **'Tomorrow {time}'**
  String tomorrowWithTime(String time);

  /// Header for time picker sheet
  ///
  /// In en, this message translates to:
  /// **'When do you want to travel?'**
  String get whenDoYouWantToTravel;

  /// Number of routes found
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 route found} other{{count} routes found}}'**
  String routesFound(int count);

  /// Short name for January
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// Short name for February
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// Short name for March
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// Short name for April
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// Short name for May
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// Short name for June
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// Short name for July
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// Short name for August
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// Short name for September
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// Short name for October
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// Short name for November
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// Short name for December
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// Go button to start navigation
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get buttonGo;

  /// Details button to view trip details
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get buttonDetails;

  /// Try again button after error
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get buttonTryAgain;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get buttonReset;

  /// Title for route settings sheet
  ///
  /// In en, this message translates to:
  /// **'Route Settings'**
  String get routeSettings;

  /// Wheelchair accessibility option
  ///
  /// In en, this message translates to:
  /// **'Wheelchair accessible'**
  String get wheelchairAccessible;

  /// Description when wheelchair mode is on
  ///
  /// In en, this message translates to:
  /// **'Routes avoid stairs and steep slopes'**
  String get wheelchairAccessibleOn;

  /// Description when wheelchair mode is off
  ///
  /// In en, this message translates to:
  /// **'Include all routes'**
  String get wheelchairAccessibleOff;

  /// Walking speed section title
  ///
  /// In en, this message translates to:
  /// **'Walking speed'**
  String get walkingSpeed;

  /// Slow walking speed option
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  /// Normal walking speed option
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get speedNormal;

  /// Fast walking speed option
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  /// Maximum walking distance section title
  ///
  /// In en, this message translates to:
  /// **'Maximum walking distance'**
  String get maxWalkDistance;

  /// No limit option for walking distance
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// Transport modes section title
  ///
  /// In en, this message translates to:
  /// **'Transport modes'**
  String get transportModes;

  /// Transit transport mode
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get modeTransit;

  /// Bicycle transport mode
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get modeBicycle;

  /// Exit navigation button label
  ///
  /// In en, this message translates to:
  /// **'Exit Navigation'**
  String get exitNavigation;

  /// Exit navigation confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Exit Navigation?'**
  String get exitNavigationTitle;

  /// Exit navigation confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop navigating this route?'**
  String get exitNavigationMessage;

  /// Exit button label
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get buttonExit;

  /// Message when navigation is complete
  ///
  /// In en, this message translates to:
  /// **'You have arrived!'**
  String get arrivedMessage;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// Settings button label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get buttonSettings;

  /// Loading message while searching for routes
  ///
  /// In en, this message translates to:
  /// **'Finding routes...'**
  String get findingRoutes;

  /// Badge showing number of additional departure times
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreDepartures(int count);

  /// Header for alternative departure times section
  ///
  /// In en, this message translates to:
  /// **'Other departures'**
  String get otherDepartures;

  /// Label showing departure time
  ///
  /// In en, this message translates to:
  /// **'Departs {time}'**
  String departsAt(String time);
}

class _HomeScreenLocalizationsDelegate
    extends LocalizationsDelegate<HomeScreenLocalizations> {
  const _HomeScreenLocalizationsDelegate();

  @override
  Future<HomeScreenLocalizations> load(Locale locale) {
    return SynchronousFuture<HomeScreenLocalizations>(
      lookupHomeScreenLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_HomeScreenLocalizationsDelegate old) => false;
}

HomeScreenLocalizations lookupHomeScreenLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return HomeScreenLocalizationsDe();
    case 'en':
      return HomeScreenLocalizationsEn();
    case 'es':
      return HomeScreenLocalizationsEs();
  }

  throw FlutterError(
    'HomeScreenLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
