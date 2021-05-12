import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/utils/util_icons/custom_icons.dart';
import 'package:trufi_core/models/social_media/social_media_item.dart';

class InstagramSocialMedia implements SocialMediaItem {
  final String _url;

  InstagramSocialMedia(this._url);
  @override
  WidgetBuilder get buildIcon => (context) => const Icon(CustomIcons.instagram);

  @override
  String getTitle(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return localization.followOnInstagram;
  }

  @override
  String get url => _url;
}
