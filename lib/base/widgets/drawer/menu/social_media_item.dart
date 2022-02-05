import 'package:flutter/material.dart';
import 'package:trufi_core/base/widgets/drawer/menu/menu_item.dart';

abstract class SocialMediaItem extends MenuItem {
  final String url;
  SocialMediaItem({
    required this.url,
    required WidgetBuilder buildIcon,
    required String Function(BuildContext) name,
  }) : super(
          selectedIcon: buildIcon,
          notSelectedIcon: buildIcon,
          name: (context) => MenuItem.buildName(context, name(context)),
          onClick: (context, isSelected) {
            // TODO: launch(url);
          },
        );
}

class FacebookSocialMedia extends SocialMediaItem {
  FacebookSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => const Icon(
            Icons.error,
            color: Colors.grey,
          ),
          name: (BuildContext context) {
            return "followOnFacebook";
          },
        );
}

class InstagramSocialMedia extends SocialMediaItem {
  InstagramSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => const Icon(
            Icons.error,
            color: Colors.grey,
          ),
          name: (BuildContext context) {
            return "followOnInstagram";
          },
        );
}

class TwitterSocialMedia extends SocialMediaItem {
  TwitterSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => const Icon(
            Icons.error,
            color: Colors.grey,
          ),
          name: (BuildContext context) {
            return "followOnTwitter";
          },
        );
}

class WebSiteSocialMedia extends SocialMediaItem {
  WebSiteSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => const Icon(
            Icons.web,
            color: Colors.grey,
          ),
          name: (BuildContext context) {
            return "readOurBlog";
          },
        );
}
