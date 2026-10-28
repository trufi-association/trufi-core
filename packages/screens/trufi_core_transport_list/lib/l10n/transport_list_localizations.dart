import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'transport_list_localizations_de.dart';
import 'transport_list_localizations_en.dart';
import 'transport_list_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of TransportListLocalizations
/// returned by `TransportListLocalizations.of(context)`.
///
/// Applications need to include `TransportListLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/transport_list_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: TransportListLocalizations.localizationsDelegates,
///   supportedLocales: TransportListLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the TransportListLocalizations.supportedLocales
/// property.
abstract class TransportListLocalizations {
  TransportListLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static TransportListLocalizations of(BuildContext context) {
    return Localizations.of<TransportListLocalizations>(
      context,
      TransportListLocalizations,
    )!;
  }

  static const LocalizationsDelegate<TransportListLocalizations> delegate =
      _TransportListLocalizationsDelegate();

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

  /// No description provided for @menuTransportList.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get menuTransportList;

  /// No description provided for @searchRoutes.
  ///
  /// In en, this message translates to:
  /// **'Search routes'**
  String get searchRoutes;

  /// No description provided for @noRoutesFound.
  ///
  /// In en, this message translates to:
  /// **'No routes found'**
  String get noRoutesFound;

  /// No description provided for @shareRoute.
  ///
  /// In en, this message translates to:
  /// **'Share route'**
  String get shareRoute;

  /// No description provided for @stops.
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String stops(int count);

  /// Error title when route cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Route not found'**
  String get routeNotFound;

  /// Error message when route fails to load
  ///
  /// In en, this message translates to:
  /// **'The route could not be loaded'**
  String get routeLoadError;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// Go back button label
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get buttonGoBack;

  /// No description provided for @routeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{route} other{routes}}'**
  String routeCount(int count);

  /// No description provided for @labelDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get labelDistance;

  /// No description provided for @labelStops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get labelStops;

  /// No description provided for @labelMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get labelMode;

  /// No description provided for @noStopsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stops available'**
  String get noStopsAvailable;

  /// No description provided for @loadingRoute.
  ///
  /// In en, this message translates to:
  /// **'Loading route...'**
  String get loadingRoute;

  /// Group header for routes whose agency is unknown
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get otherAgencies;

  /// Snackbar message shown when sharing a route link
  ///
  /// In en, this message translates to:
  /// **'Share: {uri}'**
  String shareRouteMessage(String uri);

  /// Fallback transport mode label when a route has no mode name
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get defaultModeBus;

  /// App bar title of the map settings screen
  ///
  /// In en, this message translates to:
  /// **'Map Settings'**
  String get mapSettingsTitle;

  /// Section title for choosing the map type
  ///
  /// In en, this message translates to:
  /// **'Map Type'**
  String get mapTypeLabel;

  /// Button label to apply map settings changes
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get applyChanges;

  /// Badge label for the first stop of a route
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get stopStart;

  /// Badge label for the last stop of a route
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get stopEnd;

  /// Explanation shown when a route has no stop data
  ///
  /// In en, this message translates to:
  /// **'Stop information is not available for this route'**
  String get stopInfoNotAvailable;

  /// No description provided for @errorLoadingRoutes.
  ///
  /// In en, this message translates to:
  /// **'Could not load routes'**
  String get errorLoadingRoutes;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Subtitle of the operator QR dialog explaining what scanning does
  ///
  /// In en, this message translates to:
  /// **'Scan to open this operator\'s routes'**
  String get qrShareSubtitle;

  /// Button that copies the QR code image to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy QR'**
  String get copyQrImage;

  /// Snackbar shown when copying the QR image to the clipboard fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t copy the QR'**
  String get copyQrImageFailed;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Tram'**
  String get modeTram;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Subway'**
  String get modeSubway;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Rail'**
  String get modeRail;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get modeBus;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Ferry'**
  String get modeFerry;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Cable Tram'**
  String get modeCableTram;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Aerial Lift'**
  String get modeAerialLift;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Funicular'**
  String get modeFunicular;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Trolleybus'**
  String get modeTrolleybus;

  /// GTFS route type shown as the transport mode
  ///
  /// In en, this message translates to:
  /// **'Monorail'**
  String get modeMonorail;

  /// Distance in kilometers; {value} is already formatted with the locale's decimal separator.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKilometers(String value);

  /// Distance in meters; {value} is a whole number formatted for the locale.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String distanceMeters(String value);

  /// Short confirmation shown after a place or stop name was copied to the clipboard (long-press on the name, or the copy button)
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedToClipboard;

  /// Drawer entry and title of the nearby lines screen (lines passing within walking distance)
  ///
  /// In en, this message translates to:
  /// **'Nearby lines'**
  String get menuNearbyLines;

  /// Anchor row label when the search is centred on the device position
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get nearbyAnchorYourLocation;

  /// Anchor row label when the search is centred on a pin the user placed on the map
  ///
  /// In en, this message translates to:
  /// **'Pinned location'**
  String get nearbyAnchorPinned;

  /// Anchor row label when no fix and no pin exist and the app's default center is used
  ///
  /// In en, this message translates to:
  /// **'City center (location unavailable)'**
  String get nearbyAnchorDefault;

  /// Anchor row label when the search covers every corner of a street picked in the location search (lines along the street)
  ///
  /// In en, this message translates to:
  /// **'Along {street}'**
  String nearbyAnchorAlongStreet(String street);

  /// Button that re-centres the search on the device position
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get nearbyUseMyLocation;

  /// Hint under the anchor row and in the empty state explaining how to move the search point
  ///
  /// In en, this message translates to:
  /// **'Long-press the map to move the pin'**
  String get nearbyMovePinHint;

  /// Radius filter chip: distance bracket in meters and how many lines fall inside it
  ///
  /// In en, this message translates to:
  /// **'{meters} m ({count})'**
  String nearbyRadiusChip(int meters, int count);

  /// Count pill at the top of the nearby lines sheet: how many lines fall within the selected radius
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line} other{{count} lines}} within {meters} m'**
  String nearbyLinesInRadius(int count, int meters);

  /// Row title when the line is reached at a stop; {distance} is already formatted (e.g. '75 m')
  ///
  /// In en, this message translates to:
  /// **'At {distance}'**
  String nearbyAtDistance(String distance);

  /// Row title when the line's route runs closer than any of its stops; {distance} is already formatted
  ///
  /// In en, this message translates to:
  /// **'Passes by at {distance}'**
  String nearbyPassesAtDistance(String distance);

  /// Row subtitle: name of the nearest stop of the line
  ///
  /// In en, this message translates to:
  /// **'Stop {name}'**
  String nearbyStopName(String name);

  /// Row subtitle: destination (headsign) of the line
  ///
  /// In en, this message translates to:
  /// **'To {headsign}'**
  String nearbyTowards(String headsign);

  /// Banner over the list naming the line whose route is highlighted on the map
  ///
  /// In en, this message translates to:
  /// **'Highlighted: {name}'**
  String nearbySelectedLine(String name);

  /// Empty state when no line passes within the widest search radius
  ///
  /// In en, this message translates to:
  /// **'No lines pass within {meters} m'**
  String nearbyEmptyTitle(int meters);

  /// Empty state when lines exist farther away but none inside the selected radius
  ///
  /// In en, this message translates to:
  /// **'No lines within {meters} m. Try a larger radius.'**
  String nearbyEmptyInRadius(int meters);

  /// Shown when the app has no local GTFS feed to search
  ///
  /// In en, this message translates to:
  /// **'Nearby lines need the offline GTFS planner'**
  String get nearbyUnavailableTitle;

  /// Developer-facing hint under the unavailable title
  ///
  /// In en, this message translates to:
  /// **'Add a local TrufiPlannerProvider with a bundled GTFS feed to the routing engines.'**
  String get nearbyUnavailableHint;

  /// Shown while the bundled GTFS feed is being read
  ///
  /// In en, this message translates to:
  /// **'Loading offline data…'**
  String get nearbyLoadingData;

  /// Footer note of the nearby lines sheet
  ///
  /// In en, this message translates to:
  /// **'Based on GTFS routes and schedules'**
  String get nearbyFooterNote;

  /// Tooltip of the chevron that opens the route detail of a nearby line
  ///
  /// In en, this message translates to:
  /// **'Line details'**
  String get nearbyOpenDetails;

  /// Tooltip of the button that removes the highlighted route from the map
  ///
  /// In en, this message translates to:
  /// **'Clear highlight'**
  String get nearbyClearSelection;

  /// Tooltip of the close button of the nearby lines screen
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get nearbyClose;
}

class _TransportListLocalizationsDelegate
    extends LocalizationsDelegate<TransportListLocalizations> {
  const _TransportListLocalizationsDelegate();

  @override
  Future<TransportListLocalizations> load(Locale locale) {
    return SynchronousFuture<TransportListLocalizations>(
      lookupTransportListLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_TransportListLocalizationsDelegate old) => false;
}

TransportListLocalizations lookupTransportListLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return TransportListLocalizationsDe();
    case 'en':
      return TransportListLocalizationsEn();
    case 'es':
      return TransportListLocalizationsEs();
  }

  throw FlutterError(
    'TransportListLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
