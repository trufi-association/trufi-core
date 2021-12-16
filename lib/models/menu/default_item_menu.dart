import 'package:flutter/material.dart';

import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:app_review/app_review.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/models/menu/menu_item.dart';
import 'package:trufi_core/widgets/trufi_drawer.dart';

enum DefaultItemsMenu { language, appReview }

extension LayerIdsToString on DefaultItemsMenu {
  SimpleMenuItem? toMenuItem() {
    final Map<DefaultItemsMenu, SimpleMenuItem> map = {
      DefaultItemsMenu.language: SimpleMenuItem(
          buildIcon: (context) => const Icon(Icons.language),
          name: (context) {
            final values = context
                .read<ConfigurationCubit>()
                .state
                .supportedLanguages
                .map((lang) =>
                    LanguageDropdownValue(lang.languageCode, lang.displayName))
                .toList();
            final theme = Theme.of(context);
            final languageCode = Localizations.localeOf(context).languageCode;
            return DropdownButton<LanguageDropdownValue>(
              style: theme.textTheme.bodyText1,
              value: values
                  .firstWhere((value) => value.languageCode == languageCode),
              onChanged: (LanguageDropdownValue? value) {
                BlocProvider.of<PreferencesCubit>(context)
                    .updateLanguage(value!.languageCode);
              },
              items: values.map((LanguageDropdownValue value) {
                return DropdownMenuItem<LanguageDropdownValue>(
                  value: value,
                  child: Text(
                    value.languageString,
                    style: theme.textTheme.bodyText1,
                  ),
                );
              }).toList(),
            );
          }),
      DefaultItemsMenu.appReview: SimpleMenuItem(
        buildIcon: (context) => const Icon(Icons.star, color: Colors.grey),
        name: (context) => MenuItem.buildName(
          context,
          TrufiLocalization.of(context).menuAppReview,
        ),
        onClick: () {
          AppReview.writeReview;
        },
      ),
    };

    return map[this];
  }
}

class SimpleMenuItem extends MenuItem {
  SimpleMenuItem({
    required WidgetBuilder buildIcon,
    required WidgetBuilder name,
    void Function()? onClick,
  }) : super(
          selectedIcon: buildIcon,
          notSelectedIcon: buildIcon,
          name: name,
          onClick: (context, isSelected) {
            if (onClick != null) onClick();
          },
        );
}
