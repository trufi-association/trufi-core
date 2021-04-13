
import 'dart:async';

// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'trufi_localization_de.dart';
import 'trufi_localization_ee.dart';
import 'trufi_localization_en.dart';
import 'trufi_localization_es.dart';
import 'trufi_localization_fr.dart';
import 'trufi_localization_it.dart';
import 'trufi_localization_pt.dart';
import 'trufi_localization_qu.dart';

/// Callers can lookup localized strings with an instance of TrufiLocalization returned
/// by `TrufiLocalization.of(context)`.
///
/// Applications need to include `TrufiLocalization.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'l10n/trufi_localization.dart';
///
/// return MaterialApp(
///   localizationsDelegates: TrufiLocalization.localizationsDelegates,
///   supportedLocales: TrufiLocalization.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
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
/// be consistent with the languages listed in the TrufiLocalization.supportedLocales
/// property.
abstract class TrufiLocalization {
  TrufiLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  // ignore: unused_field
  final String localeName;

  static TrufiLocalization of(BuildContext context) {
    return Localizations.of<TrufiLocalization>(context, TrufiLocalization);
  }

  static const LocalizationsDelegate<TrufiLocalization> delegate = _TrufiLocalizationDelegate();

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
    Locale('ee'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('qu')
  ];

  /// Text displayed on the about page
  ///
  /// In en, this message translates to:
  /// **'We are a Bolivian and international team of people that love and support public transport. We have developed this app to make it easy for people to use the transport system in Cochabamba and the surrounding area.'**
  String get aboutContent;

  /// Button label to show licenses
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutLicenses;

  /// A note about open source
  ///
  /// In en, this message translates to:
  /// **'This app is released as open source on GitHub. Feel free to contribute or bring it to your own city.'**
  String get aboutOpenSource;

  /// Text of dialog that explains that access to location services was denied
  ///
  /// In en, this message translates to:
  /// **'Please make sure your device has GPS and the Location settings are activated.'**
  String get alertLocationServicesDeniedMessage;

  /// Title of dialog that explains that access to location services was denied
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get alertLocationServicesDeniedTitle;

  /// Accept button of the App Review Dialog used on Android
  ///
  /// In en, this message translates to:
  /// **'Write review'**
  String get appReviewDialogButtonAccept;

  /// Decline button of the App Review Dialog used on Android
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get appReviewDialogButtonDecline;

  /// Content of the App Review Dialog used on Android
  ///
  /// In en, this message translates to:
  /// **'Support us with a review on the Google Play Store.'**
  String get appReviewDialogContent;

  /// Title of the App Review Dialog used on Android
  ///
  /// In en, this message translates to:
  /// **'Enjoying Trufi?'**
  String get appReviewDialogTitle;

  /// Page subtitle when choosing a location on the map
  ///
  /// In en, this message translates to:
  /// **'Pan & zoom map under pin'**
  String get chooseLocationPageSubtitle;

  /// Page title when choosing a location on the map
  ///
  /// In en, this message translates to:
  /// **'Choose a point'**
  String get chooseLocationPageTitle;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Destination field label
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get commonDestination;

  /// Message when an error has occured
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// Message when data could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get commonFailLoading;

  /// Go offline button label
  ///
  /// In en, this message translates to:
  /// **'Go offline'**
  String get commonGoOffline;

  /// Go online button label
  ///
  /// In en, this message translates to:
  /// **'Go online'**
  String get commonGoOnline;

  /// Message when internet connection is lost
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get commonNoInternet;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOK;

  /// Origin field label
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get commonOrigin;

  /// General Save label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Message when an unknown error has occured
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get commonUnknownError;

  /// A sentence that describes the application's purpose
  ///
  /// In en, this message translates to:
  /// **'The best way to travel with trufis, micros and buses through {cityName}.'**
  String description(Object cityName);

  /// Donate menu item
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// Message that is displayed when a trip could not be planned, because the specified destination is ambiguous
  ///
  /// In en, this message translates to:
  /// **'The trip planner is unsure of the location you want to go to. Please select from the following options, or be more specific.'**
  String get errorAmbiguousDestination;

  /// Message that is displayed when a trip could not be planned, because the specified origin is ambiguous
  ///
  /// In en, this message translates to:
  /// **'The trip planner is unsure of the location you want to start from. Please select from the following options, or be more specific.'**
  String get errorAmbiguousOrigin;

  /// Message that is displayed when a trip could not be planned, because the specified origin and destination are ambiguous
  ///
  /// In en, this message translates to:
  /// **'Both origin and destination are ambiguous. Please select from the following options, or be more specific.'**
  String get errorAmbiguousOriginDestination;

  /// Message that is displayed when a trip could not be planned, because both origin and destination are not wheelchair accessible
  ///
  /// In en, this message translates to:
  /// **'Both origin and destination are not wheelchair accessible'**
  String get errorNoBarrierFree;

  /// Message that is displayed when a trip could not be planned, because there were no valid transit times available for the requested time
  ///
  /// In en, this message translates to:
  /// **'No transit times available. The date may be past or too far in the future or there may not be transit service for your trip at the time you chose.'**
  String get errorNoTransitTimes;

  /// Message that is displayed when a trip could not be planned, because it would be outside of map data boundaries
  ///
  /// In en, this message translates to:
  /// **'Trip is not possible. You might be trying to plan a trip outside the map data boundary.'**
  String get errorOutOfBoundary;

  /// Message that is displayed when a trip could not be planned, because the start or end point is not safely accessible
  ///
  /// In en, this message translates to:
  /// **'Trip is not possible. Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway).'**
  String get errorPathNotFound;

  /// Message that is displayed when a trip could not be planned, because the request had errors
  ///
  /// In en, this message translates to:
  /// **'The request has errors that the server is not willing or able to process.'**
  String get errorServerCanNotHandleRequest;

  /// Message that is displayed when a trip could not be planned, because the server is taking too long to respond
  ///
  /// In en, this message translates to:
  /// **'The trip planner is taking way too long to process your request. Please try again later.'**
  String get errorServerTimeout;

  /// Message that is displayed when the trip planning server was not available
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry. The trip planner is temporarily unavailable. Please try again later.'**
  String get errorServerUnavailable;

  /// Message that is displayed when a trip could not be planned, because origin and destination are too close to each other
  ///
  /// In en, this message translates to:
  /// **'Origin is within a trivial distance of the destination.'**
  String get errorTrivialDistance;

  /// Message that is displayed when a trip could not be planned, because the destination was not found
  ///
  /// In en, this message translates to:
  /// **'Destination is unknown. Can you be a bit more descriptive?'**
  String get errorUnknownDestination;

  /// Message that is displayed when a trip could not be planned, because the origin was not found
  ///
  /// In en, this message translates to:
  /// **'Origin is unknown. Can you be a bit more descriptive?'**
  String get errorUnknownOrigin;

  /// Message that is displayed when a trip could not be planned, because both origin and destination were not found
  ///
  /// In en, this message translates to:
  /// **'Both origin and destination are unknown. Can you be a bit more descriptive?'**
  String get errorUnknownOriginDestination;

  /// Text displayed on the feedback page
  ///
  /// In en, this message translates to:
  /// **'Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you.'**
  String get feedbackContent;

  /// Title displayed on the feedback page
  ///
  /// In en, this message translates to:
  /// **'Please e-mail us'**
  String get feedbackTitle;

  /// Facebook menu item
  ///
  /// In en, this message translates to:
  /// **'Follow us on Facebook'**
  String get followOnFacebook;

  /// Instagram menu item
  ///
  /// In en, this message translates to:
  /// **'Follow us on Instagram'**
  String get followOnInstagram;

  /// Twitter menu item
  ///
  /// In en, this message translates to:
  /// **'Follow us on Twitter'**
  String get followOnTwitter;

  /// Itinerary leg distance (km)
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String instructionDistanceKm(Object value);

  /// Itinerary leg distance (m)
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String instructionDistanceMeters(Object value);

  /// Itinerary leg duration
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String instructionDurationMinutes(Object value);

  /// Junction name of two streets
  ///
  /// In en, this message translates to:
  /// **'{street1} and {street2}'**
  String instructionJunction(Object street1, Object street2);

  /// Itinerary instruction (vehicle)
  ///
  /// In en, this message translates to:
  /// **'Ride {vehicle} for {duration} ({distance}) to\\n{location}'**
  String instructionRide(Object vehicle, Object distance, Object duration, Object location);

  /// Vehicle name (Bus)
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get instructionVehicleBus;

  /// Vehicle name (Car)
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get instructionVehicleCar;

  /// Vehicle name (Gondola)
  ///
  /// In en, this message translates to:
  /// **'Gondola'**
  String get instructionVehicleGondola;

  /// Vehicle name (Light Rail Train)
  ///
  /// In en, this message translates to:
  /// **'Light Rail Train'**
  String get instructionVehicleLightRail;

  /// Vehicle name (Micro)
  ///
  /// In en, this message translates to:
  /// **'Micro'**
  String get instructionVehicleMicro;

  /// Vehicle name (Minibus)
  ///
  /// In en, this message translates to:
  /// **'Minibus'**
  String get instructionVehicleMinibus;

  /// Vehicle name (Trufi)
  ///
  /// In en, this message translates to:
  /// **'Trufi'**
  String get instructionVehicleTrufi;

  /// Itinerary instruction (walking)
  ///
  /// In en, this message translates to:
  /// **'Walk {duration} ({distance}) to\\n{location}'**
  String instructionWalk(Object distance, Object duration, Object location);

  /// Label for the Map types
  ///
  /// In en, this message translates to:
  /// **'Map Type'**
  String get mapTypeLabel;

  /// Label for the Satellite Map type
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get mapTypeSatelliteCaption;

  /// Label for the Streets Map type
  ///
  /// In en, this message translates to:
  /// **'Streets'**
  String get mapTypeStreetsCaption;

  /// Label for the Terrain Map type
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get mapTypeTerrainCaption;

  /// Menu item that shows the about page
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// Menu item that triggers a native widget to rate the app
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get menuAppReview;

  /// Menu item that shows the map/planned trip
  ///
  /// In en, this message translates to:
  /// **'Show routes'**
  String get menuConnections;

  /// Menu item that shows the feedback page
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get menuFeedback;

  /// Menu item that shows the state of online/offline routing
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get menuOnline;

  /// Menu item that triggers a native widget to rate the app
  ///
  /// In en, this message translates to:
  /// **'Share the app'**
  String get menuShareApp;

  /// Menu item that shows the team page
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get menuTeam;

  /// A menu item that shows the saved places
  ///
  /// In en, this message translates to:
  /// **'Your places'**
  String get menuYourPlaces;

  /// Message when no route could be found after a route search
  ///
  /// In en, this message translates to:
  /// **'Sorry, we could not find a route. What do you want to do?'**
  String get noRouteError;

  /// Button label to try another destination when no route could be found
  ///
  /// In en, this message translates to:
  /// **'Try another destination'**
  String get noRouteErrorActionCancel;

  /// Button label to report a missing route when no route could be found
  ///
  /// In en, this message translates to:
  /// **'Report a missing route'**
  String get noRouteErrorActionReportMissingRoute;

  /// Button label to show the car route when no route could be found
  ///
  /// In en, this message translates to:
  /// **'Show route by car'**
  String get noRouteErrorActionShowCarRoute;

  /// Website menu item
  ///
  /// In en, this message translates to:
  /// **'Read our blog'**
  String get readOurBlog;

  /// No description provided for @savedPlacesEnterNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get savedPlacesEnterNameTitle;

  /// No description provided for @savedPlacesRemoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove place'**
  String get savedPlacesRemoveLabel;

  /// No description provided for @savedPlacesSelectIconTitle.
  ///
  /// In en, this message translates to:
  /// **'Select symbol'**
  String get savedPlacesSelectIconTitle;

  /// No description provided for @savedPlacesSetIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Change symbol'**
  String get savedPlacesSetIconLabel;

  /// No description provided for @savedPlacesSetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get savedPlacesSetNameLabel;

  /// No description provided for @savedPlacesSetPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit position'**
  String get savedPlacesSetPositionLabel;

  /// Message that is displayed when the response of the trip planning request could not be received
  ///
  /// In en, this message translates to:
  /// **'Failed to load plan.'**
  String get searchFailLoadingPlan;

  /// Placeholder text for the destination field (in search state)
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get searchHintDestination;

  /// Placeholder text for the origin field (in search state)
  ///
  /// In en, this message translates to:
  /// **'Choose starting point'**
  String get searchHintOrigin;

  /// Search option that allows to choose a point on the map
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get searchItemChooseOnMap;

  /// Message that is displayed when no results were found for the search term that was provided
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchItemNoResults;

  /// Search option that allows to use the current user location
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get searchItemYourLocation;

  /// Location name displayed in search fields that represents a location choosen on the map
  ///
  /// In en, this message translates to:
  /// **'Map Marker'**
  String get searchMapMarker;

  /// Placeholder text for the destination field (in map-visible state)
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get searchPleaseSelectDestination;

  /// Placeholder text for the origin field (in map-visible state)
  ///
  /// In en, this message translates to:
  /// **'Select origin'**
  String get searchPleaseSelectOrigin;

  /// Search section title for locations marked as favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get searchTitleFavorites;

  /// Search section title for common places
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get searchTitlePlaces;

  /// Search section title for recent location
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchTitleRecent;

  /// Search section title for results found for the provided search term
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchTitleResults;

  /// Text with URL that is used when sharing the app.
  ///
  /// In en, this message translates to:
  /// **'Download {appTitle}, the public transport app for {cityName}, at {url}'**
  String shareAppText(Object url);

  /// A short marketing sentence that describes the app
  ///
  /// In en, this message translates to:
  /// **'Public transportation in {city}'**
  String tagline(Object city);

  /// Text displayed on the team page, followed by a email link
  ///
  /// In en, this message translates to:
  /// **'We are an international team called Trufi Association that has created this app with the help of many volunteers! Do you want to improve the Trufi App and be part of our team? Please contact us via:'**
  String get teamContent;

  /// List of representatives
  ///
  /// In en, this message translates to:
  /// **'Representatives: {representatives}'**
  String teamSectionRepresentatives(Object representatives);

  /// List of route contributors
  ///
  /// In en, this message translates to:
  /// **'Routes: {routeContributors} and all users that uploaded routes to OpenStreetMap, such as {osmContributors}.\\nContact us if you want to join the OpenStreetMap community!'**
  String teamSectionRoutes(Object osmContributors, Object routeContributors);

  /// List of team members
  ///
  /// In en, this message translates to:
  /// **'Team: {teamMembers}'**
  String teamSectionTeam(Object teamMembers);

  /// List of translators
  ///
  /// In en, this message translates to:
  /// **'Translations: {translators}'**
  String teamSectionTranslations(Object translators);

  /// The application's name
  ///
  /// In en, this message translates to:
  /// **'Trufi App'**
  String get title;

  /// The application's version
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(Object version);
}

class _TrufiLocalizationDelegate extends LocalizationsDelegate<TrufiLocalization> {
  const _TrufiLocalizationDelegate();

  @override
  Future<TrufiLocalization> load(Locale locale) {
    return SynchronousFuture<TrufiLocalization>(_lookupTrufiLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'ee', 'en', 'es', 'fr', 'it', 'pt', 'qu'].contains(locale.languageCode);

  @override
  bool shouldReload(_TrufiLocalizationDelegate old) => false;
}

TrufiLocalization _lookupTrufiLocalization(Locale locale) {
  


// Lookup logic when only language code is specified.
switch (locale.languageCode) {
  case 'de': return TrufiLocalizationDe();
    case 'ee': return TrufiLocalizationEe();
    case 'en': return TrufiLocalizationEn();
    case 'es': return TrufiLocalizationEs();
    case 'fr': return TrufiLocalizationFr();
    case 'it': return TrufiLocalizationIt();
    case 'pt': return TrufiLocalizationPt();
    case 'qu': return TrufiLocalizationQu();
}


  throw FlutterError(
    'TrufiLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
