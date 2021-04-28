import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/l10n/trufi_custom_localization.dart';

class TrufiConfiguration {
  static final TrufiConfiguration _singleton = TrufiConfiguration._internal();

  factory TrufiConfiguration() {
    return _singleton;
  }

  TrufiConfiguration._internal();

  final abbreviations = <String, String>{};
  final animation = TrufiConfigurationAnimation();
  final email = TrufiConfigurationEmail();
  final image = TrufiConfigurationImage();
  final url = TrufiConfigurationUrl();
  final map = TrufiConfigurationMap();
  final attribution = TrufiConfigurationAttribution();
  final customTranslations = TrufiCustomLocalizations();
  final generalConfiguration = TrufiGeneralConfiguration();

  // TODO: Could be removed by a Collection of Locale
  final List<TrufiConfigurationLanguage> languages = [];

  int minimumReviewWorthyActionCount = 3;
}

class TrufiGeneralConfiguration {
  String appCity = "Cochabamba";
  bool debug = false;
}

class TrufiCustomLocalizations extends TrufiCustomLocalization {}

class TrufiConfigurationAnimation {
  FlareActor loading;
  FlareActor success;
}

class TrufiConfigurationAttribution {
  final representatives = [];
  final team = [];
  final translations = [];
  final routes = [];
  final osm = [];
}

class TrufiConfigurationEmail {
  String feedback = "";
  String info = "";
}

class TrufiConfigurationImage {
  String drawerBackground = "";
}

class TrufiConfigurationLanguage {
  TrufiConfigurationLanguage({
    @required this.languageCode,
    @required this.countryCode,
    @required this.displayName,
    this.isDefault = false,
  });

  final String languageCode;
  final String countryCode;
  final String displayName;
  final bool isDefault;
}

class TrufiConfigurationMap {
  String mapTilerKey = "";
  bool satelliteMapTypeEnabled = false;
  bool terrainMapTypeEnabled = false;
  double defaultZoom = 12.0;
  double offlineZoom = 13.0;
  double offlineMinZoom = 8.0;
  double offlineMaxZoom = 14.0;
  double onlineMinZoom = 1.0;
  double onlineMaxZoom = 19.0;
  double onlineZoom = 13.0;
  double chooseLocationZoom = 16.0;
  LatLng center = LatLng(5.574558, -0.214656);
  LatLng southWest = LatLng(5.510057, -0.328217);
  LatLng northEast = LatLng(5.726678, 0.071411);
}

class TrufiConfigurationUrl {
  final openStreetMapCopyright = "https://www.openstreetmap.org/copyright";
  final mapTilerCopyright = "https://www.maptiler.com/copyright/";
  String otpEndpoint = "";
  String tilesStreetsEndpoint = "";
  String tilesSatelliteEndpoint = "";
  String tilesTerrainEndpoint = "";
  String adsEndpoint = "";
  String routeFeedback = "";
  String website = "";
  String facebook = "";
  String instagram = "";
  String twitter = "";
  String donate = "";
  String share = "";
  bool   isOtpGraphQL = false;
}
