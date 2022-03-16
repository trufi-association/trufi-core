import 'package:flutter/material.dart';

import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/mode_leg.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class ItinerarySummaryAdvanced extends StatelessWidget {
  final double maxWidth;
  final Itinerary itinerary;

  const ItinerarySummaryAdvanced({
    Key? key,
    required this.itinerary,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);

    final compressLegs = itinerary.compressLegs;

    final renderBarThreshold = (24 * 10) / maxWidth;
    final legRender = itinerary.getNumberLegHide(renderBarThreshold);
    final legRenderDuration = itinerary.getNumberLegTime(renderBarThreshold);
    final newMaxWidth = maxWidth - (legRender * 24);

    final durationItinerary = itinerary.duration.inSeconds - legRenderDuration;
    final newRenderBarThreshold = (24 * 10) / newMaxWidth;

    final List<Widget> legs = [];

    final lastLeg = compressLegs[compressLegs.length - 1];
    final lastLegLength =
        ((lastLeg.duration.inSeconds) / durationItinerary) * 10;
    double addition = 0;

    compressLegs.asMap().forEach((index, leg) {
      double? waitTime;
      bool renderBar = true;

      Leg? nextLeg;
      final isNextLegLast = index + 1 == compressLegs.length - 1;

      final bool shouldRenderLastLeg =
          isNextLegLast && lastLegLength < newRenderBarThreshold;

      if (index < compressLegs.length - 1) {
        nextLeg = compressLegs[index + 1];
      }

      double legLength = (leg.duration.inSeconds / durationItinerary) * 10;

      if (nextLeg != null) {
        waitTime =
            nextLeg.startTime.difference(leg.endTime).inSeconds.toDouble();
          legLength += (waitTime / durationItinerary) * 10;
      }

      legLength += addition;
      addition = 0;

      if (shouldRenderLastLeg && !leg.isLegOnFoot) {
        legLength += newRenderBarThreshold;
      }

      if (legLength < newRenderBarThreshold && leg.isLegOnFoot) {
        renderBar = false;
      }

      if (leg.isLegOnFoot && renderBar) {
        legs.add(ModeLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
        ));
      } else if (leg.transportMode == TransportMode.car) {
        legs.add(RouteLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
          // duration: leg.duration.inSeconds ~/ 60,
        ));
      } else if (leg.transportMode == TransportMode.bicycle && renderBar) {
        legs.add(ModeLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
        ));
      }
      if ((leg.route != null || leg.shortName != null)) {
        legs.add(RouteLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
        ));
      }
      // if (waiting) {
      //   legs.add(WaitLeg(
      //     maxWidth: newMaxWidth,
      //     legLength: waitLength!,
      //     duration: waitTime! ~/ 60,
      //   ));
      // }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: legs.length > 1
              ? <Widget>[
                  ...legs.getRange(0, legs.length - 1),
                  Expanded(child: legs.last)
                ]
              : [...legs],
        ),
        Container(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            itinerary.firstLegStartTime(localization),
            style: TextStyle(
              fontSize: 14,
              color: hintTextColor(theme),
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
