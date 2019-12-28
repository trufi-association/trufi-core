import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class TrufiConfiguration {
  static TrufiConfiguration _singleton = new TrufiConfiguration._internal();

  factory TrufiConfiguration() {
    return _singleton;
  }

  TrufiConfiguration._internal();

  final abbreviations = Map<String, String>();
  final animation = TrufiConfigurationAnimation();
  final email = TrufiConfigurationEmail();
  final image = TrufiConfigurationImage();
  final url = TrufiConfigurationUrl();
  final map = TrufiConfigurationMap();
  final attribution = TrufiConfigurationAttribution();
  final List<TrufiConfigurationLanguage> languages = List();

  var minimumReviewWorthyActionCount = 3;
}

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
  var feedback = "";
  var info = "";
}

class TrufiConfigurationImage {
  var drawerBackground = "";
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
  var mapTilerKey = "";
  var satelliteMapTypeEnabled = false;
  var terrainMapTypeEnabled = false;
  var defaultZoom = 12.0;
  var offlineZoom = 13.0;
  var offlineMinZoom = 8.0;
  var offlineMaxZoom = 14.0;
  var onlineMinZoom = 1.0;
  var onlineMaxZoom = 19.0;
  var onlineZoom = 13.0;
  var chooseLocationZoom = 16.0;
  var center = LatLng(5.574558, -0.214656);
  var southWest = LatLng(5.510057, -0.328217);
  var northEast = LatLng(5.726678, 0.071411);
}

class TrufiConfigurationUrl {
  final openStreetMapCopyright = "https://www.openstreetmap.org/copyright";
  final mapTilerCopyright = "https://www.maptiler.com/copyright/";
  var otpEndpoint = "";
  var tilesStreetsEndpoint = "";
  var tilesSatelliteEndpoint = "";
  var tilesTerrainEndpoint = "";
  var adsEndpoint = "";
  var routeFeedback = "";
  var website = "";
  var facebook = "";
  var instagram = "";
  var twitter = "";
  var donate = "";
  var share = "";
}
