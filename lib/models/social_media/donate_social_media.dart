import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/social_media/social_media_item.dart';

class DonateSocialMedia implements SocialMediaItem {
  final String _url;

  DonateSocialMedia(this._url);
  @override
  WidgetBuilder get buildIcon => (context) => const Icon(Icons.monetization_on);

  @override
  String getTitle(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return localization.donate;
  }

  @override
  String get url => _url;
}
