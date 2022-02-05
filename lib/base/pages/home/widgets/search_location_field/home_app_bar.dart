import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/form_fields_landscape.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/form_fields_portrait.dart';

class HomeAppBar extends StatelessWidget {
  final void Function(TrufiLocation) onSaveFrom;
  final void Function(TrufiLocation) onSaveTo;
  final void Function() onBackButton;
  final void Function() onFetchPlan;
  final void Function() onReset;
  final void Function() onSwap;
  const HomeAppBar({
    Key? key,
    required this.onSaveFrom,
    required this.onSaveTo,
    required this.onBackButton,
    required this.onFetchPlan,
    required this.onReset,
    required this.onSwap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: ThemeCubit.isDarkMode(theme)
          ? theme.appBarTheme.backgroundColor
          : theme.colorScheme.primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  splashRadius: 24,
                  iconSize: 24,
                  onPressed: onBackButton,
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
                Expanded(
                  child: (isPortrait)
                      ? FormFieldsPortrait(
                          onFetchPlan: onFetchPlan,
                          onReset: onReset,
                          onSaveFrom: onSaveFrom,
                          onSaveTo: onSaveTo,
                          onSwap: onSwap,
                        )
                      : FormFieldsLandscape(
                          onFetchPlan: onFetchPlan,
                          onReset: onReset,
                          onSaveFrom: onSaveFrom,
                          onSaveTo: onSaveTo,
                          onSwap: onSwap,
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
