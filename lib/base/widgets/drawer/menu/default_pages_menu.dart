import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:trufi_core/base/pages/about/about.dart';
import 'package:trufi_core/base/pages/about/translations/about_localizations.dart';
import 'package:trufi_core/base/pages/feedback/feedback.dart';
import 'package:trufi_core/base/pages/feedback/translations/feedback_localizations.dart';
import 'package:trufi_core/base/pages/home/home.dart';
import 'package:trufi_core/base/pages/saved_places/saved_places.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/drawer/menu/menu_item.dart';

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
            Navigator.pop(context);
            Routemaster.of(context).push(id);
          },
        );
}

enum DefaultPagesMenu { homePage, transportList, savedPlaces, feedback, about }

extension LayerIdsToString on DefaultPagesMenu {
  MenuPageItem toMenuPage() {
    final Map<DefaultPagesMenu, MenuPageItem> map = {
      DefaultPagesMenu.homePage: MenuPageItem(
        id: HomePage.route,
        selectedIcon: (context) => Icon(
          Icons.linear_scale,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.linear_scale,
          color: Colors.grey,
        ),
        name: (context) {
          return TrufiBaseLocalization.of(context).menuConnections;
        },
      ),
      DefaultPagesMenu.savedPlaces: MenuPageItem(
        id: SavedPlacesPage.route,
        selectedIcon: (context) => Icon(
          Icons.room,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.room,
          color: Colors.grey,
        ),
        name: (context) {
          return SavedPlacesLocalization.of(context).menuYourPlaces;
        },
      ),
      DefaultPagesMenu.feedback: MenuPageItem(
        id: FeedbackPage.route,
        selectedIcon: (context) => Icon(
          Icons.feedback,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.feedback,
          color: Colors.grey,
        ),
        name: (context) {
          return FeedbackLocalization.of(context).menuFeedback;
        },
      ),
      DefaultPagesMenu.transportList: MenuPageItem(
        id: TransportList.route,
        selectedIcon: (context) => Icon(
          Icons.list,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.list,
          color: Colors.grey,
        ),
        name: (context) {
          return TrufiBaseLocalization.of(context).menuTransportList;
        },
      ),
      DefaultPagesMenu.about: MenuPageItem(
        id: AboutPage.route,
        selectedIcon: (context) => Icon(
          Icons.info,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        notSelectedIcon: (context) => const Icon(
          Icons.info,
          color: Colors.grey,
        ),
        name: (context) {
          return AboutLocalization.of(context).menuAbout;
        },
      ),
    };

    return map[this]!;
  }
}
