import 'package:flutter/material.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_item_menu.dart';
import 'package:trufi_core/base/widgets/drawer/menu/trufi_menu_item.dart' ;
import 'package:url_launcher/url_launcher.dart';

abstract class SocialMediaItem extends TrufiMenuItem {
  final String url;
  SocialMediaItem({
    required this.url,
    required WidgetBuilder buildIcon,
    required String Function(BuildContext) name,
  }) : super(
          selectedIcon: buildIcon,
          notSelectedIcon: buildIcon,
          name: (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TrufiMenuItem.buildName(context, name(context)),
          ),
          onClick: (context, isSelected) {
            // ignore: deprecated_member_use
            launch(url);
          },
        );
}

class FacebookSocialMedia extends SocialMediaItem {
  FacebookSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => SizedBox(
            height: 24,
            width: 24,
            child: facebookIcon(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
          name: (BuildContext context) {
            return TrufiBaseLocalization.of(context).followOnSocialMedia("Facebook");
          },
        );
}

class InstagramSocialMedia extends SocialMediaItem {
  InstagramSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => SizedBox(
            height: 24,
            width: 24,
            child: instagramIcon(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
          name: (BuildContext context) {
            return TrufiBaseLocalization.of(context).followOnSocialMedia("Instagram");
          },
        );
}

class TwitterSocialMedia extends SocialMediaItem {
  TwitterSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => SizedBox(
            height: 24,
            width: 24,
            child: twitterIcon(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
          name: (BuildContext context) {
            return TrufiBaseLocalization.of(context).followOnSocialMedia("Twitter");
          },
        );
}

class TiktokSocialMedia extends SocialMediaItem {
  TiktokSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => SizedBox(
            height: 24,
            width: 24,
            child: tiktokIcon(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
          name: (BuildContext context) {
            return TrufiBaseLocalization.of(context).followOnSocialMedia("Tiktok");
          },
        );
}

class WebSiteSocialMedia extends SocialMediaItem {
  WebSiteSocialMedia(String url)
      : super(
          url: url,
          buildIcon: (context) => SizedBox(
            height: 24,
            width: 24,
            child: Icon(
              Icons.web,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
          name: (BuildContext context) {
            return TrufiBaseLocalization.of(context).readOurBlog;
          },
        );
}

class UrlSocialMedia {
  final String? urlFacebook;
  final String? urlInstagram;
  final String? urlTwitter;
  final String? urlWebSite;
  final String? urlTiktok;

  const UrlSocialMedia({
    this.urlFacebook,
    this.urlInstagram,
    this.urlTwitter,
    this.urlWebSite,
    this.urlTiktok,
  });

  bool get existUrl =>
      urlFacebook != null ||
      urlInstagram != null ||
      urlTwitter != null ||
      urlWebSite != null ||
      urlTiktok != null;
}

TrufiMenuItem defaultSocialMedia(UrlSocialMedia defaultUrls) {
  return SimpleMenuItem(
      buildIcon: (context) => const Icon(Icons.share),
      name: (context) {
        return DropdownButton<SocialMediaItem>(
          icon: Row(
            children: [
              Text(
                TrufiBaseLocalization.of(context).menuSocialMedia,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          selectedItemBuilder: (_) => [],
          underline: Container(),
          onChanged: (SocialMediaItem? value) {
            value?.onClick(context, true);
          },
          items: <SocialMediaItem>[
            if (defaultUrls.urlFacebook != null)
              FacebookSocialMedia(defaultUrls.urlFacebook!),
            if (defaultUrls.urlInstagram != null)
              InstagramSocialMedia(defaultUrls.urlInstagram!),
            if (defaultUrls.urlTwitter != null)
              TwitterSocialMedia(defaultUrls.urlTwitter!),
            if (defaultUrls.urlTiktok != null)
              TiktokSocialMedia(defaultUrls.urlTiktok!),
            if (defaultUrls.urlWebSite != null)
              WebSiteSocialMedia(defaultUrls.urlWebSite!),
          ].map((SocialMediaItem value) {
            return DropdownMenuItem<SocialMediaItem>(
              value: value,
              child: Row(
                children: [
                  value.notSelectedIcon(context),
                  value.name(context),
                ],
              ),
            );
          }).toList(),
        );
      });
}
