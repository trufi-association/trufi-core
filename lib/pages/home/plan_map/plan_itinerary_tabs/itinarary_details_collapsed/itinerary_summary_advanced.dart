import 'package:flutter/material.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/icons_transport_modes.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinarary_details_collapsed/mode_leg.dart';

class ItinerarySummaryAdvanced extends StatelessWidget {
  final double maxWidth;
  final PlanItinerary itinerary;

  const ItinerarySummaryAdvanced({
    Key key,
    @required this.itinerary,
    @required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);

    final compressLegs = itinerary.compressLegs;

    final renderBarThreshold = (24 * 10) / maxWidth;
    final legRender = itinerary.getNumberLegHide(renderBarThreshold);
    final iconsRender = itinerary.getNumberIcons(renderBarThreshold);
    final legRenderDuration = itinerary.getNumberLegTime(renderBarThreshold);
    final newMaxWidth = maxWidth - (legRender * 24 + iconsRender * 22);

    final durationItinerary =
        itinerary.totalDurationItinerary - legRenderDuration;
    final newRenderBarThreshold = (24 * 10) / newMaxWidth;

    final List<Widget> legs = [];

    final int bikeParkedIndex =
        compressLegs.indexWhere((leg) => leg.toPlace?.bikeParkEntity != null);
    final lastLeg = compressLegs[compressLegs.length - 1];
    final lastLegLength = ((lastLeg.durationIntLeg) / durationItinerary) * 10;
    const waitThreshold = 180;
    double addition = 0;

    compressLegs.asMap().forEach((index, leg) {
      bool waiting = false;
      double waitTime;
      double waitLength;
      bool renderBar = true;

      PlanItineraryLeg nextLeg;
      final isNextLegLast = index + 1 == compressLegs.length - 1;

      final bool shouldRenderLastLeg =
          isNextLegLast && lastLegLength < newRenderBarThreshold;

      if (index < compressLegs.length - 1) {
        nextLeg = compressLegs[index + 1];
      }

      double legLength = (leg.durationIntLeg / durationItinerary) * 10;

      if (nextLeg != null) {
        waitTime =
            nextLeg.startTime.difference(leg.endTime).inSeconds.toDouble();
        waitLength = (waitTime / durationItinerary) * 10;
        if (waitTime > waitThreshold && waitLength > newRenderBarThreshold) {
          waiting = true;
        } else {
          legLength += waitLength;
        }
      }

      legLength += addition;
      addition = 0;

      if (shouldRenderLastLeg && !leg.isLegOnFoot) {
        legLength += newRenderBarThreshold;
      }

      if (legLength < newRenderBarThreshold && leg.isLegOnFoot) {
        renderBar = false;
        addition += newRenderBarThreshold;
      }

      if (leg.isLegOnFoot && renderBar) {
        legs.add(ModeLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
          duration: leg.durationIntLeg ~/ 60,
          mode: itinerary.usingOwnBicycle && index < bikeParkedIndex
              ? 'BICYCLE_WALK'
              : 'WALK',
          isTransitLeg: false,
        ));
        if (leg.toPlace?.bikeParkEntity != null) {
          legs.add(SizedBox(
            height: 22,
            width: 22,
            child: bikeParkingSvg,
          ));
        }
      } else if (leg.rentedBike ?? false) {
        legs.add(ModeLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
          duration: leg.durationIntLeg ~/ 60,
          mode: 'CITYBIKE',
          isTransitLeg: false,
        ));
      } else if (leg.transportMode == TransportMode.car) {
        legs.add(ModeLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
          duration: leg.durationIntLeg ~/ 60,
          mode: 'CAR',
          isTransitLeg: false,
        ));

        if (leg.toPlace?.carParkEntity != null) {
          legs.add(SizedBox(
            height: 22,
            width: 22,
            child: carParkWithoutBoxSvg,
          ));
        }
      } else if (leg.transportMode == TransportMode.bicycle && renderBar) {
        legs.add(ModeLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
          duration: leg.durationIntLeg ~/ 60,
          mode: 'BICYCLE',
          isTransitLeg: false,
        ));
        if (leg.toPlace?.bikeParkEntity != null) {
          legs.add(SizedBox(
            height: 22,
            width: 22,
            child: bikeParkingSvg,
          ));
        }
      }
      if (leg.route != null && !(leg.interlineWithPreviousLeg ?? false)) {
        legs.add(RouteLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: legLength,
          mode: leg.transportMode.name,
          isTransitLeg: true,
        ));
      }
      if (waiting) {
        legs.add(ModeLeg(
          maxWidth: newMaxWidth,
          leg: leg,
          legLength: waitLength,
          duration: waitTime ~/ 60,
          mode: 'WAIT',
          isTransitLeg: false,
        ));
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          // TODO enhance the width
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
            style: theme.primaryTextTheme.bodyText1
                .copyWith(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
