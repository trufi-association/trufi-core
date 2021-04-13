
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

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Trufi App'**
  String get title;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Public transportation in {city}'**
  String tagline(Object city);

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'The best way to travel with trufis, micros and buses through {cityName}.'**
  String description(Object cityName);

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(Object version);

  /// No description provided for @alertLocationServicesDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get alertLocationServicesDeniedTitle;

  /// No description provided for @alertLocationServicesDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please make sure your device has GPS and the Location settings are activated.'**
  String get alertLocationServicesDeniedMessage;

  /// No description provided for @commonOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOK;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonGoOffline.
  ///
  /// In en, this message translates to:
  /// **'Go offline'**
  String get commonGoOffline;

  /// No description provided for @commonGoOnline.
  ///
  /// In en, this message translates to:
  /// **'Go online'**
  String get commonGoOnline;

  /// No description provided for @commonDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get commonDestination;

  /// No description provided for @commonOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get commonOrigin;

  /// No description provided for @commonNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get commonNoInternet;

  /// No description provided for @commonFailLoading.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get commonFailLoading;

  /// No description provided for @commonUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get commonUnknownError;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @noRouteError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we could not find a route. What do you want to do?'**
  String get noRouteError;

  /// No description provided for @noRouteErrorActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Try another destination'**
  String get noRouteErrorActionCancel;

  /// No description provided for @noRouteErrorActionReportMissingRoute.
  ///
  /// In en, this message translates to:
  /// **'Report a missing route'**
  String get noRouteErrorActionReportMissingRoute;

  /// No description provided for @noRouteErrorActionShowCarRoute.
  ///
  /// In en, this message translates to:
  /// **'Show route by car'**
  String get noRouteErrorActionShowCarRoute;

  /// No description provided for @errorServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry. The trip planner is temporarily unavailable. Please try again later.'**
  String get errorServerUnavailable;

  /// No description provided for @errorOutOfBoundary.
  ///
  /// In en, this message translates to:
  /// **'Trip is not possible. You might be trying to plan a trip outside the map data boundary.'**
  String get errorOutOfBoundary;

  /// No description provided for @errorPathNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trip is not possible. Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway).'**
  String get errorPathNotFound;

  /// No description provided for @errorNoTransitTimes.
  ///
  /// In en, this message translates to:
  /// **'No transit times available. The date may be past or too far in the future or there may not be transit service for your trip at the time you chose.'**
  String get errorNoTransitTimes;

  /// No description provided for @errorServerTimeout.
  ///
  /// In en, this message translates to:
  /// **'The trip planner is taking way too long to process your request. Please try again later.'**
  String get errorServerTimeout;

  /// No description provided for @errorTrivialDistance.
  ///
  /// In en, this message translates to:
  /// **'Origin is within a trivial distance of the destination.'**
  String get errorTrivialDistance;

  /// No description provided for @errorServerCanNotHandleRequest.
  ///
  /// In en, this message translates to:
  /// **'The request has errors that the server is not willing or able to process.'**
  String get errorServerCanNotHandleRequest;

  /// No description provided for @errorUnknownOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin is unknown. Can you be a bit more descriptive?'**
  String get errorUnknownOrigin;

  /// No description provided for @errorUnknownDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination is unknown. Can you be a bit more descriptive?'**
  String get errorUnknownDestination;

  /// No description provided for @errorUnknownOriginDestination.
  ///
  /// In en, this message translates to:
  /// **'Both origin and destination are unknown. Can you be a bit more descriptive?'**
  String get errorUnknownOriginDestination;

  /// No description provided for @errorNoBarrierFree.
  ///
  /// In en, this message translates to:
  /// **'Both origin and destination are not wheelchair accessible'**
  String get errorNoBarrierFree;

  /// No description provided for @errorAmbiguousOrigin.
  ///
  /// In en, this message translates to:
  /// **'The trip planner is unsure of the location you want to start from. Please select from the following options, or be more specific.'**
  String get errorAmbiguousOrigin;

  /// No description provided for @errorAmbiguousDestination.
  ///
  /// In en, this message translates to:
  /// **'The trip planner is unsure of the location you want to go to. Please select from the following options, or be more specific.'**
  String get errorAmbiguousDestination;

  /// No description provided for @errorAmbiguousOriginDestination.
  ///
  /// In en, this message translates to:
  /// **'Both origin and destination are ambiguous. Please select from the following options, or be more specific.'**
  String get errorAmbiguousOriginDestination;

  /// No description provided for @searchHintOrigin.
  ///
  /// In en, this message translates to:
  /// **'Choose starting point'**
  String get searchHintOrigin;

  /// No description provided for @searchHintDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get searchHintDestination;

  /// No description provided for @searchItemChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get searchItemChooseOnMap;

  /// No description provided for @searchItemYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get searchItemYourLocation;

  /// No description provided for @searchItemNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchItemNoResults;

  /// No description provided for @searchTitlePlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get searchTitlePlaces;

  /// No description provided for @searchTitleRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchTitleRecent;

  /// No description provided for @searchTitleFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get searchTitleFavorites;

  /// No description provided for @searchTitleResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchTitleResults;

  /// No description provided for @searchPleaseSelectOrigin.
  ///
  /// In en, this message translates to:
  /// **'Select origin'**
  String get searchPleaseSelectOrigin;

  /// No description provided for @searchPleaseSelectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get searchPleaseSelectDestination;

  /// No description provided for @searchFailLoadingPlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plan.'**
  String get searchFailLoadingPlan;

  /// No description provided for @searchMapMarker.
  ///
  /// In en, this message translates to:
  /// **'Map Marker'**
  String get searchMapMarker;

  /// No description provided for @chooseLocationPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a point'**
  String get chooseLocationPageTitle;

  /// No description provided for @chooseLocationPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pan & zoom map under pin'**
  String get chooseLocationPageSubtitle;

  /// No description provided for @instructionWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk {duration} ({distance}) to\n{location}'**
  String instructionWalk(Object distance, Object duration, Object location);

  /// No description provided for @instructionRide.
  ///
  /// In en, this message translates to:
  /// **'Ride {vehicle} for {duration} ({distance}) to\n{location}'**
  String instructionRide(Object vehicle, Object distance, Object duration, Object location);

  /// No description provided for @instructionVehicleBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get instructionVehicleBus;

  /// No description provided for @instructionVehicleMicro.
  ///
  /// In en, this message translates to:
  /// **'Micro'**
  String get instructionVehicleMicro;

  /// No description provided for @instructionVehicleMinibus.
  ///
  /// In en, this message translates to:
  /// **'Minibus'**
  String get instructionVehicleMinibus;

  /// No description provided for @instructionVehicleTrufi.
  ///
  /// In en, this message translates to:
  /// **'Trufi'**
  String get instructionVehicleTrufi;

  /// No description provided for @instructionVehicleCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get instructionVehicleCar;

  /// No description provided for @instructionVehicleGondola.
  ///
  /// In en, this message translates to:
  /// **'Gondola'**
  String get instructionVehicleGondola;

  /// No description provided for @instructionDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String instructionDurationMinutes(Object value);

  /// No description provided for @instructionDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String instructionDistanceKm(Object value);

  /// No description provided for @instructionDistanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String instructionDistanceMeters(Object value);

  /// No description provided for @menuConnections.
  ///
  /// In en, this message translates to:
  /// **'Show routes'**
  String get menuConnections;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @menuTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get menuTeam;

  /// No description provided for @menuFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get menuFeedback;

  /// No description provided for @menuOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get menuOnline;

  /// No description provided for @menuAppReview.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get menuAppReview;

  /// No description provided for @menuShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share the app'**
  String get menuShareApp;

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'Download {appTitle}, the public transport app for {cityName}, at {url}'**
  String shareAppText(Object url);

  /// No description provided for @feedbackContent.
  ///
  /// In en, this message translates to:
  /// **'Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you.'**
  String get feedbackContent;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Please e-mail us'**
  String get feedbackTitle;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'We are a Bolivian and international team of people that love and support public transport. We have developed this app to make it easy for people to use the transport system in Cochabamba and the surrounding area.'**
  String get aboutContent;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutOpenSource.
  ///
  /// In en, this message translates to:
  /// **'This app is released as open source on GitHub. Feel free to contribute or bring it to your own city.'**
  String get aboutOpenSource;

  /// No description provided for @teamContent.
  ///
  /// In en, this message translates to:
  /// **'We are an international team called Trufi Association that has created this app with the help of many volunteers! Do you want to improve the Trufi App and be part of our team? Please contact us via:'**
  String get teamContent;

  /// No description provided for @teamSectionRepresentatives.
  ///
  /// In en, this message translates to:
  /// **'Representatives: {representatives}'**
  String teamSectionRepresentatives(Object representatives);

  /// No description provided for @teamSectionTeam.
  ///
  /// In en, this message translates to:
  /// **'Team: {teamMembers}'**
  String teamSectionTeam(Object teamMembers);

  /// No description provided for @teamSectionTranslations.
  ///
  /// In en, this message translates to:
  /// **'Translations: {translators}'**
  String teamSectionTranslations(Object translators);

  /// No description provided for @teamSectionRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes: {routeContributors} and all users that uploaded routes to OpenStreetMap, such as {osmContributors}.\nContact us if you want to join the OpenStreetMap community!'**
  String teamSectionRoutes(Object osmContributors, Object routeContributors);

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @readOurBlog.
  ///
  /// In en, this message translates to:
  /// **'Read our blog'**
  String get readOurBlog;

  /// No description provided for @followOnFacebook.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Facebook'**
  String get followOnFacebook;

  /// No description provided for @followOnTwitter.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Twitter'**
  String get followOnTwitter;

  /// No description provided for @followOnInstagram.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Instagram'**
  String get followOnInstagram;

  /// No description provided for @appReviewDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Trufi?'**
  String get appReviewDialogTitle;

  /// No description provided for @appReviewDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Support us with a review on the Google Play Store.'**
  String get appReviewDialogContent;

  /// No description provided for @appReviewDialogButtonDecline.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get appReviewDialogButtonDecline;

  /// No description provided for @appReviewDialogButtonAccept.
  ///
  /// In en, this message translates to:
  /// **'Write review'**
  String get appReviewDialogButtonAccept;

  /// No description provided for @instructionJunction.
  ///
  /// In en, this message translates to:
  /// **'{street1} and {street2}'**
  String instructionJunction(Object street1, Object street2);

  /// No description provided for @instructionVehicleLightRail.
  ///
  /// In en, this message translates to:
  /// **'Light Rail Train'**
  String get instructionVehicleLightRail;

  /// No description provided for @menuYourPlaces.
  ///
  /// In en, this message translates to:
  /// **'Your places'**
  String get menuYourPlaces;

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

  /// No description provided for @mapTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Map Type'**
  String get mapTypeLabel;

  /// No description provided for @mapTypeStreetsCaption.
  ///
  /// In en, this message translates to:
  /// **'Streets'**
  String get mapTypeStreetsCaption;

  /// No description provided for @mapTypeSatelliteCaption.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get mapTypeSatelliteCaption;

  /// No description provided for @mapTypeTerrainCaption.
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get mapTypeTerrainCaption;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @savedPlacesEnterNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get savedPlacesEnterNameTitle;
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
