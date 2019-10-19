import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core/trufi_configuration.dart';

void main() async {
  final trufiCfg = TrufiConfiguration();
  final globalCfg = GlobalConfiguration();
  await globalCfg.loadFromAsset("app_config");

  // Abbreviations
  trufiCfg.abbreviations.addAll({
    "Avenida": "Av.",
    "Calle": "C.",
    "Camino": "C.º",
  });

  // Animation
  trufiCfg.animation.success.asset = "assets/images/success.flr";
  trufiCfg.animation.success.animation = "Untitled";
  trufiCfg.animation.loading.asset = "assets/images/loading.flr";
  trufiCfg.animation.loading.animation = "Trufi Drive";

  // Attribution
  trufiCfg.attribution.representatives.addAll([
    "Christoph Hanser",
    "Samuel Rioja",
  ]);
  trufiCfg.attribution.team.addAll([
    "Andreas Helms",
    "Annika Bock",
    "Christian Brückner",
    "Javier Rocha",
    "Luz Choque",
    "Malte Dölker",
    "Martin Kleppe",
    "Michael Brückner",
    "Natalya Blanco",
    "Neyda Mili",
    "Raimund Wege",
  ]);
  trufiCfg.attribution.translations.addAll([
    "Gladys Aguilar",
    "Jeremy Maes",
    "Gaia Vitali Roscini",
  ]);
  trufiCfg.attribution.routes.addAll([
    "Trufi team",
    "Guia Cochala team",
  ]);
  trufiCfg.attribution.osm.addAll([
    "Marco Antonio",
    "Noémie",
    "Philipp",
    "Felix D",
    "Valor Naram", // Sören Reinecke
  ]);

  // Email
  trufiCfg.email.feedback = globalCfg.getString("emailFeedback");
  trufiCfg.email.info = globalCfg.getString("emailInfo");

  // Image
  trufiCfg.image.drawerBackground = "assets/images/drawer-bg.jpg";

  // Map
  trufiCfg.map.mapTilerKey = globalCfg.get("keyMapTiler");
  trufiCfg.map.defaultZoom = 12.0;
  trufiCfg.map.offlineMinZoom = 8.0;
  trufiCfg.map.offlineMaxZoom = 14.0;
  trufiCfg.map.offlineZoom = 13.0;
  trufiCfg.map.onlineMinZoom = 1.0;
  trufiCfg.map.onlineMaxZoom = 19.0;
  trufiCfg.map.onlineZoom = 13.0;
  trufiCfg.map.chooseLocationZoom = 16.0;
  trufiCfg.map.center = LatLng(5.574558, -0.214656);
  trufiCfg.map.southWest = LatLng(5.510057, -0.328217);
  trufiCfg.map.northEast = LatLng(5.726678, 0.071411);

  // Languages
  trufiCfg.languages.addAll([
    TrufiConfigurationLanguage(
      languageCode: "de",
      countryCode: "DE",
      displayName: "Deutsch",
    ),
    TrufiConfigurationLanguage(
      languageCode: "en",
      countryCode: "US",
      displayName: "English",
    ),
    TrufiConfigurationLanguage(
      languageCode: "es",
      countryCode: "ES",
      displayName: "Español",
      isDefault: true,
    ),
    TrufiConfigurationLanguage(
      languageCode: "fr",
      countryCode: "FR",
      displayName: "Français",
    ),
    TrufiConfigurationLanguage(
      languageCode: "it",
      countryCode: "IT",
      displayName: "Italiano",
    ),
    TrufiConfigurationLanguage(
      languageCode: "qu",
      countryCode: "BO",
      displayName: "Quechua simi",
    ),
  ]);

  // Url
  trufiCfg.url.otpEndpoint = globalCfg.getString("urlOtpEndpoint");
  trufiCfg.url.routeFeedback = globalCfg.getString("urlRouteFeedback");
  trufiCfg.url.donate = globalCfg.getString("urlDonate");
  trufiCfg.url.website = globalCfg.getString("urlWebsite");
  trufiCfg.url.facebook = globalCfg.getString("urlFacebook");
  trufiCfg.url.instagram = globalCfg.getString("urlInstagram");

  // Run app
  runApp(TrufiApp());
}
