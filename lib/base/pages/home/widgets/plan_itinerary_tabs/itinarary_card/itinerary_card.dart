import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';
import 'package:trufi_core/base/const/styles.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/itinerary_summary_advanced.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;
  final GestureTapCallback onTap;

  const ItineraryCard({
    super.key,
    required this.itinerary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;
    return GestureDetector(
      onTap: () async {
        await routePlannerCubit.selectItinerary(itinerary);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: Insets.sm,
                bottom: Insets.xs,
                right: Insets.xl,
              ),
              child: Row(
                children: <Widget>[
                  if (CitySelectionManager().currentCity ==
                      CityInstance.toluca) ...[
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: itinerary.durationFormat(localization),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text:
                                " (${itinerary.getDistanceString(localization)})",
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4),
                  ],
                  Expanded(
                      child: Container(
                    height: 1.5,
                    color: theme.dividerColor,
                  )),
                  const SizedBox(width: 8),
                  if (CitySelectionManager().currentCity != CityInstance.toluca)
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: itinerary.durationFormat(localization),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text:
                                " (${itinerary.getDistanceString(localization)})",
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (CitySelectionManager().currentCity == CityInstance.toluca)
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            itinerary.fare?.formattedFare ?? 'N/A',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 5,
                  height: 50 * MediaQuery.of(context).textScaleFactor,
                  color: itinerary == routePlannerState.selectedItinerary
                      ? theme.colorScheme.secondary
                      : Colors.grey[400],
                  margin: const EdgeInsets.only(
                    right: 5,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(builder: (builderContext, constrains) {
                    return ItinerarySummaryAdvanced(
                      maxWidth: constrains.maxWidth,
                      itinerary: itinerary,
                    );
                  }),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    color: Colors.transparent,
                    width: 30,
                    height: 50,
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
