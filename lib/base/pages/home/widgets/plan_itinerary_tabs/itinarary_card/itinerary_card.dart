import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/base/const/styles.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/itinerary_summary_advanced.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;
  final GestureTapCallback onTap;

  const ItineraryCard({
    Key? key,
    required this.itinerary,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    final mapRouteCubit = context.read<MapRouteCubit>();
    final mapRouteState = mapRouteCubit.state;
    return GestureDetector(
      onTap: () async {
        await mapRouteCubit.selectItinerary(itinerary);
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
                  Expanded(
                      child: Container(
                    height: 1.5,
                    color: theme.dividerColor,
                  )),
                  const SizedBox(width: 8),
                  RichText(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: itinerary.durationFormat(localization),
                          style: theme.textTheme.bodyText2?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text:
                              " (${itinerary.getDistanceString(localization)})",
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                          ),
                        )
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
                  color: itinerary == mapRouteState.selectedItinerary
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
                  onTap: () {
                    onTap();
                    mapRouteCubit.selectItinerary(itinerary);
                  },
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
