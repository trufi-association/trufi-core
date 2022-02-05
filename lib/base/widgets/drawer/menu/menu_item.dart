import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_item_menu.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_pages_menu.dart';

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
    final theme = Theme.of(context);
    final backgroundColor =
        ThemeCubit.isDarkMode(theme) ? Colors.grey[900] : Colors.grey[400];
    return Container(
      color: isSelected ? backgroundColor : null,
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
        color: color ?? Theme.of(context).textTheme.bodyText1?.color,
      ),
    );
  }
}

final List<List<MenuItem>> defaultMenuItems = [
  DefaultPagesMenu.values.map((menuPage) => menuPage.toMenuPage()).toList(),
  DefaultItemsMenu.values.map((menuPage) => menuPage.toMenuItem()).toList(),
];
