import 'package:flutter/material.dart';
import 'package:trufi_core/models/social_media/social_media_item.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaButton extends StatelessWidget {
  final SocialMediaItem socialMediaItem;

  const SocialMediaButton({Key key, this.socialMediaItem}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: socialMediaItem.buildIcon(context),
      title: Text(
        socialMediaItem.getTitle(context),
        style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
      ),
      onTap: () => launch(socialMediaItem.url),
    );
  }
}