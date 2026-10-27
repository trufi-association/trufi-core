import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'trufi_base_localizations_de.dart';
import 'trufi_base_localizations_en.dart';
import 'trufi_base_localizations_es.dart';
import 'trufi_base_localizations_fr.dart';
import 'trufi_base_localizations_it.dart';
import 'trufi_base_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of TrufiBaseLocalization
/// returned by `TrufiBaseLocalization.of(context)`.
///
/// Applications need to include `TrufiBaseLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/trufi_base_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: TrufiBaseLocalization.localizationsDelegates,
///   supportedLocales: TrufiBaseLocalization.supportedLocales,
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
/// be consistent with the languages listed in the TrufiBaseLocalization.supportedLocales
/// property.
abstract class TrufiBaseLocalization {
  TrufiBaseLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static TrufiBaseLocalization? of(BuildContext context) {
    return Localizations.of<TrufiBaseLocalization>(context, TrufiBaseLocalization);
  }

  static const LocalizationsDelegate<TrufiBaseLocalization> delegate = _TrufiBaseLocalizationDelegate();

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
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

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

  /// General Confirm location label
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get commonConfirmLocation;

  /// Destination field label
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get commonDestination;

  /// General Edit label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Message when an error has occured
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// General from station  label
  ///
  /// In en, this message translates to:
  /// **'from station'**
  String get commonFromStation;

  /// General from stop  label
  ///
  /// In en, this message translates to:
  /// **'from stop'**
  String get commonFromStop;

  /// General Leave when it suits you label
  ///
  /// In en, this message translates to:
  /// **'Leave when it suits you'**
  String get commonItineraryNoTransitLegs;

  /// General Leaves at  label
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get commonLeavesAt;

  /// General Loading label
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Message when internet connection is lost
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get commonNoInternet;

  /// Message that is displayed when no results were found for the search term that was provided
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get commonNoResults;

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

  /// General Remove label
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// General Save label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// General Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get commonTomorrow;

  /// Message when an unknown error has occured
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get commonUnknownError;

  /// General Unkown place label
  ///
  /// In en, this message translates to:
  /// **'Unkown place'**
  String get commonUnkownPlace;

  /// General wait label
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get commonWait;

  /// General Walk label
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get commonWalk;

  /// Search option that allows to use the current user location
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get commonYourLocation;

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

  /// Message when internet connection is lost
  ///
  /// In en, this message translates to:
  /// **'No connect with server.'**
  String get errorNoConnectServer;

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

  /// Follow us on (socialMedia)
  ///
  /// In en, this message translates to:
  /// **'Follow us on {value}'**
  String followOnSocialMedia(Object value);

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

  /// Itinerary leg duration in hours
  ///
  /// In en, this message translates to:
  /// **'{value} h'**
  String instructionDurationHours(Object value);

  /// Number of transfers of an itinerary, shown next to its distance in the results list (trufi-arequipa#29)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Direct} =1{1 transfer} other{{count} transfers}}'**
  String itineraryTransfers(int count);

  /// Itinerary leg duration
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String instructionDurationMinutes(Object value);

  /// Vehicle name (Bike)
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get instructionVehicleBike;

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

  /// Vehicle name (Carpool)
  ///
  /// In en, this message translates to:
  /// **'Carpool'**
  String get instructionVehicleCarpool;

  /// Vehicle name (Commuter train)
  ///
  /// In en, this message translates to:
  /// **'Commuter train'**
  String get instructionVehicleCommuterTrain;

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

  /// Vehicle name (Metro)
  ///
  /// In en, this message translates to:
  /// **'Metro'**
  String get instructionVehicleMetro;

  /// Vehicle name (Microbus)
  ///
  /// In en, this message translates to:
  /// **'Microbus'**
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

  /// No description provided for @instructionVehicleWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get instructionVehicleWalk;

  /// Menu item that shows the map/planned trip
  ///
  /// In en, this message translates to:
  /// **'Route planner'**
  String get menuConnections;

  /// No description provided for @menuSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get menuSocialMedia;

  /// Menu item that shows the bus list page
  ///
  /// In en, this message translates to:
  /// **'Show routes'**
  String get menuTransportList;

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

  /// No description provided for @notShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Do not show again'**
  String get notShowAgain;

  /// Website menu item
  ///
  /// In en, this message translates to:
  /// **'Read our blog'**
  String get readOurBlog;

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

  /// Text with URL that is used when sharing the app.
  ///
  /// In en, this message translates to:
  /// **'Download {appTitle}, the public transport app for {cityName}, at {url}'**
  String shareAppText(Object url, Object appTitle, Object cityName);

  /// General Show on map tilers label
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get commonShowMap;

  /// General Map Settings label
  ///
  /// In en, this message translates to:
  /// **'Map Settings'**
  String get commonMapSettings;

  /// Label for the Map types
  ///
  /// In en, this message translates to:
  /// **'Map Type'**
  String get mapTypeLabel;

  /// No description provided for @selectYourPointInterest.
  ///
  /// In en, this message translates to:
  /// **'Points of Interest'**
  String get selectYourPointInterest;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeModeSystem;
}

class _TrufiBaseLocalizationDelegate extends LocalizationsDelegate<TrufiBaseLocalization> {
  const _TrufiBaseLocalizationDelegate();

  @override
  Future<TrufiBaseLocalization> load(Locale locale) {
    return SynchronousFuture<TrufiBaseLocalization>(lookupTrufiBaseLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_TrufiBaseLocalizationDelegate old) => false;
}

TrufiBaseLocalization lookupTrufiBaseLocalization(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return TrufiBaseLocalizationDe();
    case 'en': return TrufiBaseLocalizationEn();
    case 'es': return TrufiBaseLocalizationEs();
    case 'fr': return TrufiBaseLocalizationFr();
    case 'it': return TrufiBaseLocalizationIt();
    case 'pt': return TrufiBaseLocalizationPt();
  }

  throw FlutterError(
    'TrufiBaseLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
