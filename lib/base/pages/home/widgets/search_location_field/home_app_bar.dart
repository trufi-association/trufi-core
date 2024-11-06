import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/date_time_picker/itinerary_date_selector.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/form_fields_landscape.dart';
import 'package:trufi_core/base/pages/home/widgets/search_location_field/form_fields_portrait.dart';
import 'package:trufi_core/base/widgets/choose_location/choose_location.dart';

class HomeAppBar extends StatelessWidget {
  final void Function(TrufiLocation) onSaveFrom;
  final void Function(TrufiLocation) onSaveTo;
  final void Function() onBackButton;
  final void Function() onFetchPlan;
  final void Function() onReset;
  final void Function() onSwap;
  final SelectLocationData selectPositionOnPage;

  const HomeAppBar({
    super.key,
    required this.onSaveFrom,
    required this.onSaveTo,
    required this.onBackButton,
    required this.onFetchPlan,
    required this.onReset,
    required this.onSwap,
    required this.selectPositionOnPage,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final theme = Theme.of(context);
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;
    return Card(
      margin: EdgeInsets.zero,
      color: ThemeCubit.isDarkMode(theme)
          ? theme.appBarTheme.backgroundColor
          : theme.colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(4),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPortrait) const SizedBox(width: 30),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        splashRadius: 24,
                        iconSize: 24,
                        onPressed: onBackButton,
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      ),
                      if (routePlannerState.enableDebugOutput != null)
                        Checkbox(
                          value: routePlannerState.enableDebugOutput,
                          onChanged: (value) =>
                              routePlannerCubit.activeDebugOutput(value),
                        )
                      else
                        FiveClickWidget(
                          onFiveClicks: () =>
                              routePlannerCubit.activeDebugOutput(false),
                        ),
                    ],
                  ),
                  Expanded(
                    child: (isPortrait)
                        ? FormFieldsPortrait(
                            onFetchPlan: onFetchPlan,
                            onReset: onReset,
                            onSaveFrom: onSaveFrom,
                            onSaveTo: onSaveTo,
                            onSwap: onSwap,
                            selectPositionOnPage: selectPositionOnPage,
                          )
                        : FormFieldsLandscape(
                            onFetchPlan: onFetchPlan,
                            onReset: onReset,
                            onSaveFrom: onSaveFrom,
                            onSaveTo: onSaveTo,
                            onSwap: onSwap,
                            selectPositionOnPage: selectPositionOnPage,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FiveClickWidget extends StatefulWidget {
  final VoidCallback onFiveClicks;
  const FiveClickWidget({super.key, required this.onFiveClicks});

  @override
  State<FiveClickWidget> createState() => _FiveClickWidgetState();
}

class _FiveClickWidgetState extends State<FiveClickWidget> {
  int _clickCount = 0;

  void _handleClick() {
    setState(() {
      _clickCount++;
      if (_clickCount == 15) {
        widget.onFiveClicks();
        _clickCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleClick,
      child: Container(
        color: Colors.transparent,
        width: 24,
        height: 46,
      ),
    );
  }
}
