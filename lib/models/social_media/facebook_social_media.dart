import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/utils/util_icons/custom_icons.dart';
import 'package:trufi_core/models/social_media/social_media_item.dart';

class FacebookSocialMedia implements SocialMediaItem {
  final String _url;

  FacebookSocialMedia(this._url);
  @override
  WidgetBuilder get buildIcon => (context) => const Icon(CustomIcons.facebook);

  @override
  String getTitle(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return localization.followOnFacebook;
  }

  @override
  String get url => _url;
}
