import 'package:flutter/material.dart';
import 'package:trufi_core/models/menu/menu_item.dart';
import 'package:trufi_core/models/menu/social_media/facebook_social_media.dart';
import 'package:trufi_core/models/menu/social_media/instagram_social_media.dart';
import 'package:trufi_core/models/menu/social_media/twitter_social_media.dart';
import 'package:trufi_core/models/menu/social_media/website_social_media.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core_example/configuration_service.dart';

import 'theme/theme.dart';

void main() {
  // Run app
  runApp(TrufiApp(
    configuration: setupExampleConfiguration(),
    theme: theme,
    bottomBarTheme: bottomBarTheme,
    menuItems: [
      ...defaultMenuItems,
      [
        FacebookSocialMedia("https://www.facebook.com/trufiapp"),
        InstagramSocialMedia("https://www.instagram.com/trufi.app"),
        TwitterSocialMedia("https://twitter.com/TrufiAssoc"),
        WebSiteSocialMedia("https://www.trufi.app/blog/"),
      ]
    ],
  ));
}
