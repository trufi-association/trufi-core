import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final localization = TrufiBaseLocalization.of(context)!;
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
              // The header text is bounded by the row minus the gap and a
              // 24 px minimum for the divider, so with large fonts or on a
              // narrow screen it wraps (right-aligned) instead of
              // overflowing the card (trufi-arequipa#29).
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      height: 1.5,
                      color: theme.dividerColor,
                    )),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (constraints.maxWidth - 8 - 24)
                            .clamp(0.0, double.infinity),
                      ),
                      child: RichText(
                        textAlign: TextAlign.end,
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: [
                            // TrufiChanged
                            // TextSpan(
                            //   text: itinerary.durationFormat(localization),
                            //   style: theme.textTheme.bodyMedium?.copyWith(
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            TextSpan(
                              text:
                                  "(${itinerary.getDistanceString(localization)})",
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            // trufi-arequipa#29: how many times the rider changes
                            // vehicle, next to the distance ("Directo" when none);
                            // nothing for a walk-only itinerary, which boards
                            // nothing.
                            if (itinerary.legs.any((leg) => leg.transitLeg))
                              TextSpan(
                                text:
                                    " · ${localization.itineraryTransfers(itinerary.transfers)}",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 5,
                  // ignore: deprecated_member_use
                  height:
                      50.0 * MediaQuery.of(context).textScaler.textScaleFactor,
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
