import 'package:flutter/material.dart';
import 'package:trufi_core/models/social_media/facebook_social_media.dart';
import 'package:trufi_core/models/social_media/instagram_social_media.dart';
import 'package:trufi_core/models/social_media/twitter_social_media.dart';
import 'package:trufi_core/models/social_media/website_social_media.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core_example/configuration_service.dart';

void main() {
  // Colors
  final theme = ThemeData(
    primaryColor: const Color(0xff263238),
    primaryColorLight: const Color(0xffeceff1),
    accentColor: const Color(0xffd81b60),
    backgroundColor: Colors.white,
  );

  // Run app
  runApp(TrufiApp(
    configuration: setupExampleConfiguration(),
    theme: theme,
    socialMediaItem: [
      FacebookSocialMedia("https://www.facebook.com/trufiapp"),
      InstagramSocialMedia("https://www.instagram.com/trufi.app"),
      TwitterSocialMedia("https://twitter.com/TrufiAssoc"),
      WebSiteSocialMedia("https://www.trufi.app/blog/"),
    ],
  ));
}
