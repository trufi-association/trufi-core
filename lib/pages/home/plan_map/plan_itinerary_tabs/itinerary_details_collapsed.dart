import 'package:flutter/material.dart';

import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/widgets/vertical_swipe_detector.dart';

import 'transport_icon_detail.dart';

class ItineraryDetailsCollapsed extends StatelessWidget {
  static const _paddingHeight = 20.0;

  final Animation<double> animationCostHeight;
  final Animation<double> animationSummaryHeight;
  final Function(bool) setIsExpanded;
  final PlanItinerary itinerary;
  final AdEntity ad;

  const ItineraryDetailsCollapsed({
    Key key,
    @required this.setIsExpanded,
    @required this.itinerary,
    @required this.ad,
    @required this.animationCostHeight,
    @required this.animationSummaryHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);

    return VerticalSwipeDetector(
      onSwipeUp: () => setIsExpanded(true),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: _paddingHeight / 2),
        child: Flex(
          direction: isPortrait ? Axis.vertical : Axis.horizontal,
          children: <Widget>[
            Container(
              height: animationCostHeight.value,
              padding: const EdgeInsets.only(left: 12.0, right: 45.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (itinerary.hasAdvencedData)
                    Text(
                      "${itinerary.startTimeHHmm} - ${itinerary.endTimeHHmm}    ",
                      style: theme.textTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (itinerary.hasAdvencedData)
                        Text(
                          "${itinerary.durationTripString(localization)} ",
                          style: theme.textTheme.bodyText1
                              .copyWith(fontWeight: FontWeight.w500),
                        )
                      else
                        Text(
                          "${localization.instructionDurationMinutes(itinerary.time)} ",
                          style: theme.textTheme.bodyText1
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                      Text(
                        "(${itinerary.getDistanceString(localization)})",
                        style: theme.textTheme.bodyText2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                  height: animationSummaryHeight.value,
                  child: _ItinerarySummary(itinerary: itinerary, ad: ad)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItinerarySummary extends StatelessWidget {
  final PlanItinerary itinerary;
  final AdEntity ad;

  const _ItinerarySummary({
    Key key,
    @required this.itinerary,
    @required this.ad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.backgroundColor,
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.only(left: 12.0, right: 10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (contextBuilder, index) {
                    final PlanItineraryLeg leg = itinerary.legs[index];
                    return Row(
                      children: <Widget>[
                        LegTransportIcon(leg: leg),
                        if (ad != null || leg != itinerary.legs.last)
                          Icon(Icons.keyboard_arrow_right,
                              color: theme.primaryIconTheme.color),
                        if (ad != null)
                          Row(
                            children: <Widget>[
                              Icon(Icons.sentiment_very_satisfied,
                                  color: Theme.of(context).accentColor),
                            ],
                          ),
                      ],
                    );
                  },
                  itemCount: itinerary.legs.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
