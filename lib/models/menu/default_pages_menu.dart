import 'package:flutter/material.dart';

import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/menu/menu_item.dart';
import 'package:trufi_core/pages/about.dart';
import 'package:trufi_core/pages/feedback.dart';
import 'package:trufi_core/pages/home/home_page.dart';
import 'package:trufi_core/pages/saved_places/saved_places.dart';

class MenuPageItem extends MenuItem {
  MenuPageItem({
    required String id,
    required WidgetBuilder selectedIcon,
    required WidgetBuilder notSelectedIcon,
    required String Function(BuildContext) name,
    Color? nameColor,
  }) : super(
          id: id,
          selectedIcon: selectedIcon,
          notSelectedIcon: notSelectedIcon,
          name: (context) {
            return MenuItem.buildName(
              context,
              name(context),
              color: nameColor,
            );
          },
          onClick: (context, isSelected) {
            Navigator.popUntil(context, ModalRoute.withName(id));
            if (!isSelected) {
              Navigator.pushNamed(context, id);
            }
          },
        );
}

enum DefaultPagesMenu { homePage, savedPlaces, feedback, about }

extension LayerIdsToString on DefaultPagesMenu {
  MenuPageItem? toMenuPage() {
    final Map<DefaultPagesMenu, MenuPageItem> map = {
      DefaultPagesMenu.homePage: MenuPageItem(
        id: HomePage.route,
        selectedIcon: (context) => const Icon(
          Icons.linear_scale,
          color: Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.linear_scale,
          color: Colors.grey,
        ),
        name: (context) {
          final localization = TrufiLocalization.of(context);
          return localization.menuConnections;
        },
      ),
      DefaultPagesMenu.savedPlaces: MenuPageItem(
        id: SavedPlacesPage.route,
        selectedIcon: (context) => const Icon(
          Icons.room,
          color: Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.room,
          color: Colors.grey,
        ),
        name: (context) {
          final localization = TrufiLocalization.of(context);
          return localization.menuYourPlaces;
        },
      ),
      DefaultPagesMenu.feedback: MenuPageItem(
        id: FeedbackPage.route,
        selectedIcon: (context) => const Icon(
          Icons.feedback,
          color: Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.feedback,
          color: Colors.grey,
        ),
        name: (context) {
          final localization = TrufiLocalization.of(context);
          return localization.menuFeedback;
        },
      ),
      DefaultPagesMenu.about: MenuPageItem(
        id: AboutPage.route,
        selectedIcon: (context) => const Icon(
          Icons.info,
          color: Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.info,
          color: Colors.grey,
        ),
        name: (context) {
          final localization = TrufiLocalization.of(context);
          return localization.menuAbout;
        },
      ),
    };

    return map[this];
  }
}
