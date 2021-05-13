import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/models/social_media/facebook_social_media.dart';
import 'package:trufi_core/models/social_media/instagram_social_media.dart';
import 'package:trufi_core/models/social_media/twitter_social_media.dart';
import 'package:trufi_core/models/social_media/website_social_media.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core/trufi_configuration.dart';

// TODO: Remove the async GlobalConfig load
// https://github.com/trufi-association/trufi-core/pull/419#discussion_r615767538
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final trufiCfg = TrufiConfiguration();
  final globalCfg = GlobalConfiguration();
  await globalCfg.loadFromAsset("app_config");

  trufiCfg.map.mapTilerKey = globalCfg.getValue<String>("mapTilerKey");

  // Abbreviations
  trufiCfg.abbreviations.addAll({
    "Avenida": "Av.",
    "Calle": "C.",
    "Camino": "C.º",
  });

  // Animation
  trufiCfg.animation.loading = const FlareActor(
    "assets/images/loading.flr",
    animation: "Trufi Drive",
  );
  trufiCfg.animation.success = const FlareActor(
    "assets/images/success.flr",
    animation: "Untitled",
  );

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
  trufiCfg.email.feedback = globalCfg.getValue<String>("emailFeedback");
  trufiCfg.email.info = globalCfg.getValue<String>("emailInfo");

  // Image
  trufiCfg.image.drawerBackground = "assets/images/drawer-bg.jpg";

  // Map
  trufiCfg.map.defaultZoom = 12.0;
  trufiCfg.map.offlineMinZoom = 8.0;
  trufiCfg.map.offlineMaxZoom = 14.0;
  trufiCfg.map.offlineZoom = 13.0;
  trufiCfg.map.onlineMinZoom = 1.0;
  trufiCfg.map.onlineMaxZoom = 19.0;
  trufiCfg.map.onlineZoom = 13.0;
  trufiCfg.map.chooseLocationZoom = 16.0;
  trufiCfg.map.center = LatLng(-17.39000, -66.15400);
  trufiCfg.map.southWest = LatLng(-17.79300, -66.75000);
  trufiCfg.map.northEast = LatLng(-16.90400, -65.67400);

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
  trufiCfg.url.otpEndpoint = globalCfg.getValue<String>("urlOtpEndpoint");
  trufiCfg.url.adsEndpoint = globalCfg.getValue<String>("urlAdsEndpoint");
  trufiCfg.url.routeFeedback = globalCfg.getValue<String>("urlRouteFeedback");
  trufiCfg.url.donate = globalCfg.getValue<String>("urlDonate");
  trufiCfg.url.website = globalCfg.getValue<String>("urlWebsite");
  trufiCfg.url.facebook = globalCfg.getValue<String>("urlFacebook");
  trufiCfg.url.twitter = globalCfg.getValue<String>("urlTwitter");
  trufiCfg.url.instagram = globalCfg.getValue<String>("urlInstagram");
  trufiCfg.url.share = globalCfg.getValue<String>("urlShare");
  trufiCfg.generalConfiguration.debug = true;

  _setupCustomTrufiLocalization();

  // Colors
  final theme = ThemeData(
    primaryColor: const Color(0xff263238),
    primaryColorLight: const Color(0xffeceff1),
    accentColor: const Color(0xffd81b60),
    backgroundColor: Colors.white,
  );

  // Run app
  runApp(TrufiApp(
    theme: theme,
    socialMediaItem: [
      FacebookSocialMedia("https://www.facebook.com/trufiapp"),
      InstagramSocialMedia("https://www.instagram.com/trufi.app"),
      TwitterSocialMedia("https://twitter.com/TrufiAssoc"),
      WebSiteSocialMedia("https://www.trufi.app/blog/"),
    ],
  ));
}

/// This is an example on how to customize your application
/// We override the singleton of [TrufiConfiguration.customTranslations] with
/// the corresponding Map of Locale to TranslationString
void _setupCustomTrufiLocalization() {
  TrufiConfiguration().customTranslations
    ..title = {
      const Locale("de"): "Trufi App (German)",
      const Locale("en", "US"): "Trufi App (English)"
    }
    ..tagline = {
      const Locale("de"): "Tagline (German)",
      const Locale("en", "US"): "Tagline (English)"
    };
}
