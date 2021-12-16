import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:trufi_core/blocs/configuration/configuration.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/menu/default_item_menu.dart';
import 'package:trufi_core/models/menu/default_pages_menu.dart';

abstract class MenuItem {
  final String? id;
  final WidgetBuilder selectedIcon;
  final WidgetBuilder notSelectedIcon;
  final WidgetBuilder name;
  final void Function(BuildContext, bool isSelected) onClick;

  MenuItem({
    this.id,
    required this.selectedIcon,
    required this.notSelectedIcon,
    required this.name,
    required this.onClick,
  });
  Widget buildItem(BuildContext context, {bool isSelected = false}) {
    return Container(
      color: isSelected ? Colors.grey[300] : null,
      child: ListTile(
        leading: isSelected ? selectedIcon(context) : notSelectedIcon(context),
        title: name(context),
        selected: isSelected,
        onTap: () => onClick(context, isSelected),
      ),
    );
  }

  static Widget buildName(BuildContext context, String name, {Color? color}) {
    return Text(
      name,
      style: TextStyle(
        color: color ?? Theme.of(context).textTheme.bodyText1!.color,
      ),
    );
  }
}

class AppShareButtonMenu extends MenuItem {
  AppShareButtonMenu(String url)
      : super(
          selectedIcon: (context) =>
              const Icon(Icons.share, color: Colors.grey),
          notSelectedIcon: (context) =>
              const Icon(Icons.share, color: Colors.grey),
          name: (context) => MenuItem.buildName(
            context,
            TrufiLocalization.of(context).menuShareApp,
          ),
          onClick: (context, _) {
            final Configuration config =
                context.read<ConfigurationCubit>().state;
            final currentLocale = Localizations.localeOf(context);
            final localization = TrufiLocalization.of(context);
            Share.share(
              localization.shareAppText(
                url,
                config.customTranslations!.get(
                  config.customTranslations!.title,
                  currentLocale,
                  localization.title,
                ),
                config.appCity,
              ),
            );
          },
        );
}

final List<List<MenuItem>> defaultMenuItems = [
  DefaultPagesMenu.values
      .map((menuPage) => menuPage.toMenuPage())
      .whereNotNull()
      .toList(),
  DefaultItemsMenu.values
      .map((menuPage) => menuPage.toMenuItem())
      .whereNotNull()
      .toList(),
  [AppShareButtonMenu("")]
];
