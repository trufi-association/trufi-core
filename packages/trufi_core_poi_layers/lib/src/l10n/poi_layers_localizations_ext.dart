import 'poi_layers_localizations.dart';

/// Extension methods for POILayersLocalizations to provide dynamic lookup.
extension POILayersLocalizationsX on POILayersLocalizations {
  /// Get localized POI type name by type key.
  String poiType(String typeName) {
    switch (typeName) {
      case 'bus_stop':
        return poiTypeBusStop;
      case 'platform':
        return poiTypePlatform;
      case 'stop_position':
        return poiTypeStopPosition;
      case 'station':
        return poiTypeStation;
      case 'taxi_stand':
        return poiTypeTaxiStand;
      case 'parking':
        return poiTypeParking;
      case 'restaurant':
        return poiTypeRestaurant;
      case 'cafe':
        return poiTypeCafe;
      case 'fast_food':
        return poiTypeFastFood;
      case 'bar':
        return poiTypeBar;
      case 'bakery':
        return poiTypeBakery;
      case 'ice_cream':
        return poiTypeIceCream;
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
      case 'bank':
        return poiTypeBank;
      case 'atm':
        return poiTypeAtm;
      case 'exchange_point':
        return poiTypeExchangePoint;
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
      case 'park':
        return poiTypePark;
      case 'sports_centre':
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
      case 'swimming_pool':
        return poiTypeSwimmingPool;
      case 'townhall':
        return poiTypeTownhall;
      case 'embassy':
        return poiTypeEmbassy;
      case 'post_office':
        return poiTypePostOffice;
      case 'courthouse':
        return poiTypeCourthouse;
      case 'public_building':
        return poiTypePublicBuilding;
      case 'place_of_worship':
        return poiTypePlaceOfWorship;
      case 'church':
        return poiTypeChurch;
      case 'mosque':
        return poiTypeMosque;
      case 'synagogue':
        return poiTypeSynagogue;
      case 'police':
        return poiTypePolice;
      case 'fire_station':
        return poiTypeFireStation;
      case 'ambulance_station':
        return poiTypeAmbulanceStation;
      case 'hostel':
        return poiTypeHostel;
      case 'guest_house':
        return poiTypeGuestHouse;
      case 'motel':
        return poiTypeMotel;
      case 'apartment':
        return poiTypeApartment;
      default:
        return poiTypeUnknown;
    }
  }

  /// Get localized category name by category key.
  String categoryName(String categoryName) {
    switch (categoryName) {
      case 'transport':
        return poiCategoryTransport;
      case 'food':
        return poiCategoryFood;
      case 'shopping':
        return poiCategoryShopping;
      case 'healthcare':
        return poiCategoryHealthcare;
      case 'education':
        return poiCategoryEducation;
      case 'finance':
        return poiCategoryFinance;
      case 'tourism':
        return poiCategoryTourism;
      case 'recreation':
        return poiCategoryRecreation;
      case 'government':
        return poiCategoryGovernment;
      case 'religion':
        return poiCategoryReligion;
      case 'emergency':
        return poiCategoryEmergency;
      case 'accommodation':
        return poiCategoryAccommodation;
      default:
        return categoryName;
    }
  }
}
