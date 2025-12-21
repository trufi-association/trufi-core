import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import '../data/models/poi_category.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of POILayersLocalizations
/// returned by `POILayersLocalizations.of(context)`.
abstract class POILayersLocalizations {
  POILayersLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static POILayersLocalizations of(BuildContext context) {
    return Localizations.of<POILayersLocalizations>(
            context, POILayersLocalizations) ??
        POILayersLocalizationsEn();
  }

  static const LocalizationsDelegate<POILayersLocalizations> delegate =
      _POILayersLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es')
  ];

  // General
  String get poiLayersTitle;
  String get goHere;
  String get pointsOfInterest;
  String get toggleLayersOnTheMap;
  String get done;

  // Categories
  String get poiCategoryTransport;
  String get poiCategoryFood;
  String get poiCategoryShopping;
  String get poiCategoryHealthcare;
  String get poiCategoryEducation;
  String get poiCategoryFinance;
  String get poiCategoryTourism;
  String get poiCategoryRecreation;
  String get poiCategoryGovernment;
  String get poiCategoryReligion;
  String get poiCategoryEmergency;
  String get poiCategoryAccommodation;

  // Types - Transport
  String get poiTypeBusStop;
  String get poiTypePlatform;
  String get poiTypeStopPosition;
  String get poiTypeStation;
  String get poiTypeTaxiStand;
  String get poiTypeParking;

  // Types - Food
  String get poiTypeRestaurant;
  String get poiTypeCafe;
  String get poiTypeFastFood;
  String get poiTypeBar;
  String get poiTypeBakery;
  String get poiTypeIceCream;

  // Types - Shopping
  String get poiTypeSupermarket;
  String get poiTypeConvenience;
  String get poiTypeMarketplace;
  String get poiTypeClothes;
  String get poiTypeElectronics;
  String get poiTypeMall;
  String get poiTypeShop;

  // Types - Healthcare
  String get poiTypeHospital;
  String get poiTypeClinic;
  String get poiTypePharmacy;
  String get poiTypeDentist;
  String get poiTypeDoctor;

  // Types - Education
  String get poiTypeSchool;
  String get poiTypeUniversity;
  String get poiTypeCollege;
  String get poiTypeKindergarten;
  String get poiTypeLibrary;

  // Types - Finance
  String get poiTypeBank;
  String get poiTypeAtm;
  String get poiTypeExchangePoint;

  // Types - Tourism
  String get poiTypeHotel;
  String get poiTypeAttraction;
  String get poiTypeViewpoint;
  String get poiTypeMuseum;
  String get poiTypeMonument;
  String get poiTypeArtwork;
  String get poiTypeInformation;

  // Types - Recreation
  String get poiTypePark;
  String get poiTypeSportsCentre;
  String get poiTypePlayground;
  String get poiTypeStadium;
  String get poiTypePitch;
  String get poiTypeCinema;
  String get poiTypeTheatre;
  String get poiTypeNightclub;
  String get poiTypeGym;
  String get poiTypeSwimmingPool;

  // Types - Government
  String get poiTypeTownhall;
  String get poiTypeEmbassy;
  String get poiTypePostOffice;
  String get poiTypeCourthouse;
  String get poiTypePublicBuilding;

  // Types - Religion
  String get poiTypePlaceOfWorship;
  String get poiTypeChurch;
  String get poiTypeMosque;
  String get poiTypeSynagogue;

  // Types - Emergency
  String get poiTypePolice;
  String get poiTypeFireStation;
  String get poiTypeAmbulanceStation;

  // Types - Accommodation
  String get poiTypeHostel;
  String get poiTypeGuestHouse;
  String get poiTypeMotel;
  String get poiTypeApartment;

  // Fallback
  String get poiTypeUnknown;

  /// Get localized category name
  String categoryName(POICategory category) {
    switch (category) {
      case POICategory.transport:
        return poiCategoryTransport;
      case POICategory.food:
        return poiCategoryFood;
      case POICategory.shopping:
        return poiCategoryShopping;
      case POICategory.healthcare:
        return poiCategoryHealthcare;
      case POICategory.education:
        return poiCategoryEducation;
      case POICategory.finance:
        return poiCategoryFinance;
      case POICategory.tourism:
        return poiCategoryTourism;
      case POICategory.recreation:
        return poiCategoryRecreation;
      case POICategory.government:
        return poiCategoryGovernment;
      case POICategory.religion:
        return poiCategoryReligion;
      case POICategory.emergency:
        return poiCategoryEmergency;
      case POICategory.accommodation:
        return poiCategoryAccommodation;
    }
  }

  /// Get localized POI type name
  String poiType(String type) {
    switch (type) {
      // Transport
      case 'busStop':
        return poiTypeBusStop;
      case 'platform':
        return poiTypePlatform;
      case 'stopPosition':
        return poiTypeStopPosition;
      case 'station':
        return poiTypeStation;
      case 'taxiStand':
        return poiTypeTaxiStand;
      case 'parking':
        return poiTypeParking;

      // Food
      case 'restaurant':
        return poiTypeRestaurant;
      case 'cafe':
        return poiTypeCafe;
      case 'fastFood':
        return poiTypeFastFood;
      case 'bar':
        return poiTypeBar;
      case 'bakery':
        return poiTypeBakery;
      case 'iceCream':
        return poiTypeIceCream;

      // Shopping
      case 'supermarket':
        return poiTypeSupermarket;
      case 'convenience':
        return poiTypeConvenience;
      case 'marketplace':
        return poiTypeMarketplace;
      case 'clothes':
        return poiTypeClothes;
      case 'electronics':
        return poiTypeElectronics;
      case 'mall':
        return poiTypeMall;
      case 'shop':
        return poiTypeShop;

      // Healthcare
      case 'hospital':
        return poiTypeHospital;
      case 'clinic':
        return poiTypeClinic;
      case 'pharmacy':
        return poiTypePharmacy;
      case 'dentist':
        return poiTypeDentist;
      case 'doctor':
        return poiTypeDoctor;

      // Education
      case 'school':
        return poiTypeSchool;
      case 'university':
        return poiTypeUniversity;
      case 'college':
        return poiTypeCollege;
      case 'kindergarten':
        return poiTypeKindergarten;
      case 'library':
        return poiTypeLibrary;

      // Finance
      case 'bank':
        return poiTypeBank;
      case 'atm':
        return poiTypeAtm;
      case 'exchangePoint':
        return poiTypeExchangePoint;

      // Tourism
      case 'hotel':
        return poiTypeHotel;
      case 'attraction':
        return poiTypeAttraction;
      case 'viewpoint':
        return poiTypeViewpoint;
      case 'museum':
        return poiTypeMuseum;
      case 'monument':
        return poiTypeMonument;
      case 'artwork':
        return poiTypeArtwork;
      case 'information':
        return poiTypeInformation;

      // Recreation
      case 'park':
        return poiTypePark;
      case 'sportsCentre':
        return poiTypeSportsCentre;
      case 'playground':
        return poiTypePlayground;
      case 'stadium':
        return poiTypeStadium;
      case 'pitch':
        return poiTypePitch;
      case 'cinema':
        return poiTypeCinema;
      case 'theatre':
        return poiTypeTheatre;
      case 'nightclub':
        return poiTypeNightclub;
      case 'gym':
        return poiTypeGym;
      case 'swimmingPool':
        return poiTypeSwimmingPool;

      // Government
      case 'townhall':
        return poiTypeTownhall;
      case 'embassy':
        return poiTypeEmbassy;
      case 'postOffice':
        return poiTypePostOffice;
      case 'courthouse':
        return poiTypeCourthouse;
      case 'publicBuilding':
        return poiTypePublicBuilding;

      // Religion
      case 'placeOfWorship':
        return poiTypePlaceOfWorship;
      case 'church':
        return poiTypeChurch;
      case 'mosque':
        return poiTypeMosque;
      case 'synagogue':
        return poiTypeSynagogue;

      // Emergency
      case 'police':
        return poiTypePolice;
      case 'fireStation':
        return poiTypeFireStation;
      case 'ambulanceStation':
        return poiTypeAmbulanceStation;

      // Accommodation
      case 'hostel':
        return poiTypeHostel;
      case 'guestHouse':
        return poiTypeGuestHouse;
      case 'motel':
        return poiTypeMotel;
      case 'apartment':
        return poiTypeApartment;

      default:
        return poiTypeUnknown;
    }
  }
}

class _POILayersLocalizationsDelegate
    extends LocalizationsDelegate<POILayersLocalizations> {
  const _POILayersLocalizationsDelegate();

  @override
  Future<POILayersLocalizations> load(Locale locale) {
    return SynchronousFuture<POILayersLocalizations>(
        lookupPOILayersLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_POILayersLocalizationsDelegate old) => false;
}

POILayersLocalizations lookupPOILayersLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return POILayersLocalizationsDe();
    case 'en':
      return POILayersLocalizationsEn();
    case 'es':
      return POILayersLocalizationsEs();
  }
  return POILayersLocalizationsEn();
}

/// English translations
class POILayersLocalizationsEn extends POILayersLocalizations {
  POILayersLocalizationsEn([super.locale = 'en']);

  // General
  @override
  String get poiLayersTitle => 'Points of Interest';
  @override
  String get goHere => 'Go here';
  @override
  String get pointsOfInterest => 'Points of Interest';
  @override
  String get toggleLayersOnTheMap => 'Toggle layers on the map';
  @override
  String get done => 'Done';

  // Categories
  @override
  String get poiCategoryTransport => 'Transport';
  @override
  String get poiCategoryFood => 'Food & Drink';
  @override
  String get poiCategoryShopping => 'Shopping';
  @override
  String get poiCategoryHealthcare => 'Healthcare';
  @override
  String get poiCategoryEducation => 'Education';
  @override
  String get poiCategoryFinance => 'Finance';
  @override
  String get poiCategoryTourism => 'Tourism';
  @override
  String get poiCategoryRecreation => 'Recreation';
  @override
  String get poiCategoryGovernment => 'Government';
  @override
  String get poiCategoryReligion => 'Religion';
  @override
  String get poiCategoryEmergency => 'Emergency';
  @override
  String get poiCategoryAccommodation => 'Accommodation';

  // Types - Transport
  @override
  String get poiTypeBusStop => 'Bus stop';
  @override
  String get poiTypePlatform => 'Platform';
  @override
  String get poiTypeStopPosition => 'Stop';
  @override
  String get poiTypeStation => 'Station';
  @override
  String get poiTypeTaxiStand => 'Taxi stand';
  @override
  String get poiTypeParking => 'Parking';

  // Types - Food
  @override
  String get poiTypeRestaurant => 'Restaurant';
  @override
  String get poiTypeCafe => 'Café';
  @override
  String get poiTypeFastFood => 'Fast food';
  @override
  String get poiTypeBar => 'Bar';
  @override
  String get poiTypeBakery => 'Bakery';
  @override
  String get poiTypeIceCream => 'Ice cream';

  // Types - Shopping
  @override
  String get poiTypeSupermarket => 'Supermarket';
  @override
  String get poiTypeConvenience => 'Convenience store';
  @override
  String get poiTypeMarketplace => 'Marketplace';
  @override
  String get poiTypeClothes => 'Clothing store';
  @override
  String get poiTypeElectronics => 'Electronics';
  @override
  String get poiTypeMall => 'Shopping mall';
  @override
  String get poiTypeShop => 'Shop';

  // Types - Healthcare
  @override
  String get poiTypeHospital => 'Hospital';
  @override
  String get poiTypeClinic => 'Clinic';
  @override
  String get poiTypePharmacy => 'Pharmacy';
  @override
  String get poiTypeDentist => 'Dentist';
  @override
  String get poiTypeDoctor => 'Doctor';

  // Types - Education
  @override
  String get poiTypeSchool => 'School';
  @override
  String get poiTypeUniversity => 'University';
  @override
  String get poiTypeCollege => 'College';
  @override
  String get poiTypeKindergarten => 'Kindergarten';
  @override
  String get poiTypeLibrary => 'Library';

  // Types - Finance
  @override
  String get poiTypeBank => 'Bank';
  @override
  String get poiTypeAtm => 'ATM';
  @override
  String get poiTypeExchangePoint => 'Currency exchange';

  // Types - Tourism
  @override
  String get poiTypeHotel => 'Hotel';
  @override
  String get poiTypeAttraction => 'Attraction';
  @override
  String get poiTypeViewpoint => 'Viewpoint';
  @override
  String get poiTypeMuseum => 'Museum';
  @override
  String get poiTypeMonument => 'Monument';
  @override
  String get poiTypeArtwork => 'Artwork';
  @override
  String get poiTypeInformation => 'Information';

  // Types - Recreation
  @override
  String get poiTypePark => 'Park';
  @override
  String get poiTypeSportsCentre => 'Sports center';
  @override
  String get poiTypePlayground => 'Playground';
  @override
  String get poiTypeStadium => 'Stadium';
  @override
  String get poiTypePitch => 'Sports field';
  @override
  String get poiTypeCinema => 'Cinema';
  @override
  String get poiTypeTheatre => 'Theatre';
  @override
  String get poiTypeNightclub => 'Nightclub';
  @override
  String get poiTypeGym => 'Gym';
  @override
  String get poiTypeSwimmingPool => 'Swimming pool';

  // Types - Government
  @override
  String get poiTypeTownhall => 'Town hall';
  @override
  String get poiTypeEmbassy => 'Embassy';
  @override
  String get poiTypePostOffice => 'Post office';
  @override
  String get poiTypeCourthouse => 'Courthouse';
  @override
  String get poiTypePublicBuilding => 'Public building';

  // Types - Religion
  @override
  String get poiTypePlaceOfWorship => 'Place of worship';
  @override
  String get poiTypeChurch => 'Church';
  @override
  String get poiTypeMosque => 'Mosque';
  @override
  String get poiTypeSynagogue => 'Synagogue';

  // Types - Emergency
  @override
  String get poiTypePolice => 'Police station';
  @override
  String get poiTypeFireStation => 'Fire station';
  @override
  String get poiTypeAmbulanceStation => 'Ambulance station';

  // Types - Accommodation
  @override
  String get poiTypeHostel => 'Hostel';
  @override
  String get poiTypeGuestHouse => 'Guest house';
  @override
  String get poiTypeMotel => 'Motel';
  @override
  String get poiTypeApartment => 'Apartment';

  // Fallback
  @override
  String get poiTypeUnknown => 'Place';
}

/// Spanish translations
class POILayersLocalizationsEs extends POILayersLocalizations {
  POILayersLocalizationsEs([super.locale = 'es']);

  // General
  @override
  String get poiLayersTitle => 'Puntos de Interés';
  @override
  String get goHere => 'Ir aquí';
  @override
  String get pointsOfInterest => 'Puntos de Interés';
  @override
  String get toggleLayersOnTheMap => 'Activar capas en el mapa';
  @override
  String get done => 'Listo';

  // Categories
  @override
  String get poiCategoryTransport => 'Transporte';
  @override
  String get poiCategoryFood => 'Comida y Bebida';
  @override
  String get poiCategoryShopping => 'Compras';
  @override
  String get poiCategoryHealthcare => 'Salud';
  @override
  String get poiCategoryEducation => 'Educación';
  @override
  String get poiCategoryFinance => 'Finanzas';
  @override
  String get poiCategoryTourism => 'Turismo';
  @override
  String get poiCategoryRecreation => 'Recreación';
  @override
  String get poiCategoryGovernment => 'Gobierno';
  @override
  String get poiCategoryReligion => 'Religión';
  @override
  String get poiCategoryEmergency => 'Emergencia';
  @override
  String get poiCategoryAccommodation => 'Alojamiento';

  // Types - Transport
  @override
  String get poiTypeBusStop => 'Parada de bus';
  @override
  String get poiTypePlatform => 'Plataforma';
  @override
  String get poiTypeStopPosition => 'Parada';
  @override
  String get poiTypeStation => 'Estación';
  @override
  String get poiTypeTaxiStand => 'Parada de taxi';
  @override
  String get poiTypeParking => 'Estacionamiento';

  // Types - Food
  @override
  String get poiTypeRestaurant => 'Restaurante';
  @override
  String get poiTypeCafe => 'Café';
  @override
  String get poiTypeFastFood => 'Comida rápida';
  @override
  String get poiTypeBar => 'Bar';
  @override
  String get poiTypeBakery => 'Panadería';
  @override
  String get poiTypeIceCream => 'Heladería';

  // Types - Shopping
  @override
  String get poiTypeSupermarket => 'Supermercado';
  @override
  String get poiTypeConvenience => 'Tienda de conveniencia';
  @override
  String get poiTypeMarketplace => 'Mercado';
  @override
  String get poiTypeClothes => 'Tienda de ropa';
  @override
  String get poiTypeElectronics => 'Electrónicos';
  @override
  String get poiTypeMall => 'Centro comercial';
  @override
  String get poiTypeShop => 'Tienda';

  // Types - Healthcare
  @override
  String get poiTypeHospital => 'Hospital';
  @override
  String get poiTypeClinic => 'Clínica';
  @override
  String get poiTypePharmacy => 'Farmacia';
  @override
  String get poiTypeDentist => 'Dentista';
  @override
  String get poiTypeDoctor => 'Doctor';

  // Types - Education
  @override
  String get poiTypeSchool => 'Escuela';
  @override
  String get poiTypeUniversity => 'Universidad';
  @override
  String get poiTypeCollege => 'Instituto';
  @override
  String get poiTypeKindergarten => 'Jardín de niños';
  @override
  String get poiTypeLibrary => 'Biblioteca';

  // Types - Finance
  @override
  String get poiTypeBank => 'Banco';
  @override
  String get poiTypeAtm => 'Cajero automático';
  @override
  String get poiTypeExchangePoint => 'Casa de cambio';

  // Types - Tourism
  @override
  String get poiTypeHotel => 'Hotel';
  @override
  String get poiTypeAttraction => 'Atracción';
  @override
  String get poiTypeViewpoint => 'Mirador';
  @override
  String get poiTypeMuseum => 'Museo';
  @override
  String get poiTypeMonument => 'Monumento';
  @override
  String get poiTypeArtwork => 'Obra de arte';
  @override
  String get poiTypeInformation => 'Información';

  // Types - Recreation
  @override
  String get poiTypePark => 'Parque';
  @override
  String get poiTypeSportsCentre => 'Centro deportivo';
  @override
  String get poiTypePlayground => 'Parque infantil';
  @override
  String get poiTypeStadium => 'Estadio';
  @override
  String get poiTypePitch => 'Cancha';
  @override
  String get poiTypeCinema => 'Cine';
  @override
  String get poiTypeTheatre => 'Teatro';
  @override
  String get poiTypeNightclub => 'Discoteca';
  @override
  String get poiTypeGym => 'Gimnasio';
  @override
  String get poiTypeSwimmingPool => 'Piscina';

  // Types - Government
  @override
  String get poiTypeTownhall => 'Alcaldía';
  @override
  String get poiTypeEmbassy => 'Embajada';
  @override
  String get poiTypePostOffice => 'Correos';
  @override
  String get poiTypeCourthouse => 'Juzgado';
  @override
  String get poiTypePublicBuilding => 'Edificio público';

  // Types - Religion
  @override
  String get poiTypePlaceOfWorship => 'Lugar de culto';
  @override
  String get poiTypeChurch => 'Iglesia';
  @override
  String get poiTypeMosque => 'Mezquita';
  @override
  String get poiTypeSynagogue => 'Sinagoga';

  // Types - Emergency
  @override
  String get poiTypePolice => 'Estación de policía';
  @override
  String get poiTypeFireStation => 'Estación de bomberos';
  @override
  String get poiTypeAmbulanceStation => 'Estación de ambulancias';

  // Types - Accommodation
  @override
  String get poiTypeHostel => 'Hostal';
  @override
  String get poiTypeGuestHouse => 'Casa de huéspedes';
  @override
  String get poiTypeMotel => 'Motel';
  @override
  String get poiTypeApartment => 'Apartamento';

  // Fallback
  @override
  String get poiTypeUnknown => 'Lugar';
}

/// German translations
class POILayersLocalizationsDe extends POILayersLocalizations {
  POILayersLocalizationsDe([super.locale = 'de']);

  // General
  @override
  String get poiLayersTitle => 'Sehenswürdigkeiten';
  @override
  String get goHere => 'Hierhin';
  @override
  String get pointsOfInterest => 'Sehenswürdigkeiten';
  @override
  String get toggleLayersOnTheMap => 'Ebenen auf der Karte umschalten';
  @override
  String get done => 'Fertig';

  // Categories
  @override
  String get poiCategoryTransport => 'Verkehr';
  @override
  String get poiCategoryFood => 'Essen & Trinken';
  @override
  String get poiCategoryShopping => 'Einkaufen';
  @override
  String get poiCategoryHealthcare => 'Gesundheit';
  @override
  String get poiCategoryEducation => 'Bildung';
  @override
  String get poiCategoryFinance => 'Finanzen';
  @override
  String get poiCategoryTourism => 'Tourismus';
  @override
  String get poiCategoryRecreation => 'Freizeit';
  @override
  String get poiCategoryGovernment => 'Behörden';
  @override
  String get poiCategoryReligion => 'Religion';
  @override
  String get poiCategoryEmergency => 'Notfall';
  @override
  String get poiCategoryAccommodation => 'Unterkunft';

  // Types - Transport
  @override
  String get poiTypeBusStop => 'Bushaltestelle';
  @override
  String get poiTypePlatform => 'Bahnsteig';
  @override
  String get poiTypeStopPosition => 'Haltestelle';
  @override
  String get poiTypeStation => 'Bahnhof';
  @override
  String get poiTypeTaxiStand => 'Taxistand';
  @override
  String get poiTypeParking => 'Parkplatz';

  // Types - Food
  @override
  String get poiTypeRestaurant => 'Restaurant';
  @override
  String get poiTypeCafe => 'Café';
  @override
  String get poiTypeFastFood => 'Schnellrestaurant';
  @override
  String get poiTypeBar => 'Bar';
  @override
  String get poiTypeBakery => 'Bäckerei';
  @override
  String get poiTypeIceCream => 'Eisdiele';

  // Types - Shopping
  @override
  String get poiTypeSupermarket => 'Supermarkt';
  @override
  String get poiTypeConvenience => 'Kiosk';
  @override
  String get poiTypeMarketplace => 'Marktplatz';
  @override
  String get poiTypeClothes => 'Bekleidungsgeschäft';
  @override
  String get poiTypeElectronics => 'Elektronik';
  @override
  String get poiTypeMall => 'Einkaufszentrum';
  @override
  String get poiTypeShop => 'Geschäft';

  // Types - Healthcare
  @override
  String get poiTypeHospital => 'Krankenhaus';
  @override
  String get poiTypeClinic => 'Klinik';
  @override
  String get poiTypePharmacy => 'Apotheke';
  @override
  String get poiTypeDentist => 'Zahnarzt';
  @override
  String get poiTypeDoctor => 'Arzt';

  // Types - Education
  @override
  String get poiTypeSchool => 'Schule';
  @override
  String get poiTypeUniversity => 'Universität';
  @override
  String get poiTypeCollege => 'Hochschule';
  @override
  String get poiTypeKindergarten => 'Kindergarten';
  @override
  String get poiTypeLibrary => 'Bibliothek';

  // Types - Finance
  @override
  String get poiTypeBank => 'Bank';
  @override
  String get poiTypeAtm => 'Geldautomat';
  @override
  String get poiTypeExchangePoint => 'Wechselstube';

  // Types - Tourism
  @override
  String get poiTypeHotel => 'Hotel';
  @override
  String get poiTypeAttraction => 'Attraktion';
  @override
  String get poiTypeViewpoint => 'Aussichtspunkt';
  @override
  String get poiTypeMuseum => 'Museum';
  @override
  String get poiTypeMonument => 'Denkmal';
  @override
  String get poiTypeArtwork => 'Kunstwerk';
  @override
  String get poiTypeInformation => 'Information';

  // Types - Recreation
  @override
  String get poiTypePark => 'Park';
  @override
  String get poiTypeSportsCentre => 'Sportzentrum';
  @override
  String get poiTypePlayground => 'Spielplatz';
  @override
  String get poiTypeStadium => 'Stadion';
  @override
  String get poiTypePitch => 'Sportplatz';
  @override
  String get poiTypeCinema => 'Kino';
  @override
  String get poiTypeTheatre => 'Theater';
  @override
  String get poiTypeNightclub => 'Nachtclub';
  @override
  String get poiTypeGym => 'Fitnessstudio';
  @override
  String get poiTypeSwimmingPool => 'Schwimmbad';

  // Types - Government
  @override
  String get poiTypeTownhall => 'Rathaus';
  @override
  String get poiTypeEmbassy => 'Botschaft';
  @override
  String get poiTypePostOffice => 'Postamt';
  @override
  String get poiTypeCourthouse => 'Gericht';
  @override
  String get poiTypePublicBuilding => 'Öffentliches Gebäude';

  // Types - Religion
  @override
  String get poiTypePlaceOfWorship => 'Gotteshaus';
  @override
  String get poiTypeChurch => 'Kirche';
  @override
  String get poiTypeMosque => 'Moschee';
  @override
  String get poiTypeSynagogue => 'Synagoge';

  // Types - Emergency
  @override
  String get poiTypePolice => 'Polizeistation';
  @override
  String get poiTypeFireStation => 'Feuerwache';
  @override
  String get poiTypeAmbulanceStation => 'Rettungswache';

  // Types - Accommodation
  @override
  String get poiTypeHostel => 'Hostel';
  @override
  String get poiTypeGuestHouse => 'Pension';
  @override
  String get poiTypeMotel => 'Motel';
  @override
  String get poiTypeApartment => 'Apartment';

  // Fallback
  @override
  String get poiTypeUnknown => 'Ort';
}
