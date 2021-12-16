import 'package:flutter/material.dart';
import 'package:trufi_core/models/menu/menu_item.dart';
import 'package:url_launcher/url_launcher.dart';

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
            launch(url);
          },
        );
}
