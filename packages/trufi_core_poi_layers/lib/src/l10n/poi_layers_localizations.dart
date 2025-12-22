import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'poi_layers_localizations_de.dart';
import 'poi_layers_localizations_en.dart';
import 'poi_layers_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of POILayersLocalizations
/// returned by `POILayersLocalizations.of(context)`.
///
/// Applications need to include `POILayersLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/poi_layers_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: POILayersLocalizations.localizationsDelegates,
///   supportedLocales: POILayersLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the POILayersLocalizations.supportedLocales
/// property.
abstract class POILayersLocalizations {
  POILayersLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static POILayersLocalizations? of(BuildContext context) {
    return Localizations.of<POILayersLocalizations>(
      context,
      POILayersLocalizations,
    );
  }

  static const LocalizationsDelegate<POILayersLocalizations> delegate =
      _POILayersLocalizationsDelegate();

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

  /// Title for POI layers settings
  ///
  /// In en, this message translates to:
  /// **'Points of Interest'**
  String get poiLayersTitle;

  /// Button to set POI as destination
  ///
  /// In en, this message translates to:
  /// **'Go here'**
  String get goHere;

  /// General label for POI section
  ///
  /// In en, this message translates to:
  /// **'Points of Interest'**
  String get pointsOfInterest;

  /// Subtitle for POI layers section
  ///
  /// In en, this message translates to:
  /// **'Toggle layers on the map'**
  String get toggleLayersOnTheMap;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Transport category name
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get poiCategoryTransport;

  /// Food & Drink category name
  ///
  /// In en, this message translates to:
  /// **'Food & Drink'**
  String get poiCategoryFood;

  /// Shopping category name
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get poiCategoryShopping;

  /// Healthcare category name
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get poiCategoryHealthcare;

  /// Education category name
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get poiCategoryEducation;

  /// Finance category name
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get poiCategoryFinance;

  /// Tourism category name
  ///
  /// In en, this message translates to:
  /// **'Tourism'**
  String get poiCategoryTourism;

  /// Recreation category name
  ///
  /// In en, this message translates to:
  /// **'Recreation'**
  String get poiCategoryRecreation;

  /// Government category name
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get poiCategoryGovernment;

  /// Religion category name
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get poiCategoryReligion;

  /// Emergency category name
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get poiCategoryEmergency;

  /// Accommodation category name
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get poiCategoryAccommodation;

  /// No description provided for @poiTypeBusStop.
  ///
  /// In en, this message translates to:
  /// **'Bus stop'**
  String get poiTypeBusStop;

  /// No description provided for @poiTypePlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get poiTypePlatform;

  /// No description provided for @poiTypeStopPosition.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get poiTypeStopPosition;

  /// No description provided for @poiTypeStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get poiTypeStation;

  /// No description provided for @poiTypeTaxiStand.
  ///
  /// In en, this message translates to:
  /// **'Taxi stand'**
  String get poiTypeTaxiStand;

  /// No description provided for @poiTypeParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get poiTypeParking;

  /// No description provided for @poiTypeRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get poiTypeRestaurant;

  /// No description provided for @poiTypeCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get poiTypeCafe;

  /// No description provided for @poiTypeFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast food'**
  String get poiTypeFastFood;

  /// No description provided for @poiTypeBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get poiTypeBar;

  /// No description provided for @poiTypeBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get poiTypeBakery;

  /// No description provided for @poiTypeIceCream.
  ///
  /// In en, this message translates to:
  /// **'Ice cream'**
  String get poiTypeIceCream;

  /// No description provided for @poiTypeSupermarket.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get poiTypeSupermarket;

  /// No description provided for @poiTypeConvenience.
  ///
  /// In en, this message translates to:
  /// **'Convenience store'**
  String get poiTypeConvenience;

  /// No description provided for @poiTypeMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get poiTypeMarketplace;

  /// No description provided for @poiTypeClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothing store'**
  String get poiTypeClothes;

  /// No description provided for @poiTypeElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get poiTypeElectronics;

  /// No description provided for @poiTypeMall.
  ///
  /// In en, this message translates to:
  /// **'Shopping mall'**
  String get poiTypeMall;

  /// No description provided for @poiTypeShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get poiTypeShop;

  /// No description provided for @poiTypeHospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get poiTypeHospital;

  /// No description provided for @poiTypeClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get poiTypeClinic;

  /// No description provided for @poiTypePharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get poiTypePharmacy;

  /// No description provided for @poiTypeDentist.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get poiTypeDentist;

  /// No description provided for @poiTypeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get poiTypeDoctor;

  /// No description provided for @poiTypeSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get poiTypeSchool;

  /// No description provided for @poiTypeUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get poiTypeUniversity;

  /// No description provided for @poiTypeCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get poiTypeCollege;

  /// No description provided for @poiTypeKindergarten.
  ///
  /// In en, this message translates to:
  /// **'Kindergarten'**
  String get poiTypeKindergarten;

  /// No description provided for @poiTypeLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get poiTypeLibrary;

  /// No description provided for @poiTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get poiTypeBank;

  /// No description provided for @poiTypeAtm.
  ///
  /// In en, this message translates to:
  /// **'ATM'**
  String get poiTypeAtm;

  /// No description provided for @poiTypeExchangePoint.
  ///
  /// In en, this message translates to:
  /// **'Currency exchange'**
  String get poiTypeExchangePoint;

  /// No description provided for @poiTypeHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get poiTypeHotel;

  /// No description provided for @poiTypeAttraction.
  ///
  /// In en, this message translates to:
  /// **'Attraction'**
  String get poiTypeAttraction;

  /// No description provided for @poiTypeViewpoint.
  ///
  /// In en, this message translates to:
  /// **'Viewpoint'**
  String get poiTypeViewpoint;

  /// No description provided for @poiTypeMuseum.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get poiTypeMuseum;

  /// No description provided for @poiTypeMonument.
  ///
  /// In en, this message translates to:
  /// **'Monument'**
  String get poiTypeMonument;

  /// No description provided for @poiTypeArtwork.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get poiTypeArtwork;

  /// No description provided for @poiTypeInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get poiTypeInformation;

  /// No description provided for @poiTypePark.
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get poiTypePark;

  /// No description provided for @poiTypeSportsCentre.
  ///
  /// In en, this message translates to:
  /// **'Sports center'**
  String get poiTypeSportsCentre;

  /// No description provided for @poiTypePlayground.
  ///
  /// In en, this message translates to:
  /// **'Playground'**
  String get poiTypePlayground;

  /// No description provided for @poiTypeStadium.
  ///
  /// In en, this message translates to:
  /// **'Stadium'**
  String get poiTypeStadium;

  /// No description provided for @poiTypePitch.
  ///
  /// In en, this message translates to:
  /// **'Sports field'**
  String get poiTypePitch;

  /// No description provided for @poiTypeCinema.
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get poiTypeCinema;

  /// No description provided for @poiTypeTheatre.
  ///
  /// In en, this message translates to:
  /// **'Theatre'**
  String get poiTypeTheatre;

  /// No description provided for @poiTypeNightclub.
  ///
  /// In en, this message translates to:
  /// **'Nightclub'**
  String get poiTypeNightclub;

  /// No description provided for @poiTypeGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get poiTypeGym;

  /// No description provided for @poiTypeSwimmingPool.
  ///
  /// In en, this message translates to:
  /// **'Swimming pool'**
  String get poiTypeSwimmingPool;

  /// No description provided for @poiTypeTownhall.
  ///
  /// In en, this message translates to:
  /// **'Town hall'**
  String get poiTypeTownhall;

  /// No description provided for @poiTypeEmbassy.
  ///
  /// In en, this message translates to:
  /// **'Embassy'**
  String get poiTypeEmbassy;

  /// No description provided for @poiTypePostOffice.
  ///
  /// In en, this message translates to:
  /// **'Post office'**
  String get poiTypePostOffice;

  /// No description provided for @poiTypeCourthouse.
  ///
  /// In en, this message translates to:
  /// **'Courthouse'**
  String get poiTypeCourthouse;

  /// No description provided for @poiTypePublicBuilding.
  ///
  /// In en, this message translates to:
  /// **'Public building'**
  String get poiTypePublicBuilding;

  /// No description provided for @poiTypePlaceOfWorship.
  ///
  /// In en, this message translates to:
  /// **'Place of worship'**
  String get poiTypePlaceOfWorship;

  /// No description provided for @poiTypeChurch.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get poiTypeChurch;

  /// No description provided for @poiTypeMosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get poiTypeMosque;

  /// No description provided for @poiTypeSynagogue.
  ///
  /// In en, this message translates to:
  /// **'Synagogue'**
  String get poiTypeSynagogue;

  /// No description provided for @poiTypePolice.
  ///
  /// In en, this message translates to:
  /// **'Police station'**
  String get poiTypePolice;

  /// No description provided for @poiTypeFireStation.
  ///
  /// In en, this message translates to:
  /// **'Fire station'**
  String get poiTypeFireStation;

  /// No description provided for @poiTypeAmbulanceStation.
  ///
  /// In en, this message translates to:
  /// **'Ambulance station'**
  String get poiTypeAmbulanceStation;

  /// No description provided for @poiTypeHostel.
  ///
  /// In en, this message translates to:
  /// **'Hostel'**
  String get poiTypeHostel;

  /// No description provided for @poiTypeGuestHouse.
  ///
  /// In en, this message translates to:
  /// **'Guest house'**
  String get poiTypeGuestHouse;

  /// No description provided for @poiTypeMotel.
  ///
  /// In en, this message translates to:
  /// **'Motel'**
  String get poiTypeMotel;

  /// No description provided for @poiTypeApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get poiTypeApartment;

  /// No description provided for @poiTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get poiTypeUnknown;

  /// Title for POI selection sheet when multiple markers are tapped
  ///
  /// In en, this message translates to:
  /// **'Select place'**
  String get selectPlace;

  /// Count of places in selection sheet
  ///
  /// In en, this message translates to:
  /// **'{count} places'**
  String placesCount(int count);
}

class _POILayersLocalizationsDelegate
    extends LocalizationsDelegate<POILayersLocalizations> {
  const _POILayersLocalizationsDelegate();

  @override
  Future<POILayersLocalizations> load(Locale locale) {
    return SynchronousFuture<POILayersLocalizations>(
      lookupPOILayersLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_POILayersLocalizationsDelegate old) => false;
}

POILayersLocalizations lookupPOILayersLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return POILayersLocalizationsDe();
    case 'en':
      return POILayersLocalizationsEn();
    case 'es':
      return POILayersLocalizationsEs();
  }

  throw FlutterError(
    'POILayersLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
