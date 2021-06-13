import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/icons_transport_modes.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinarary_details_collapsed/mode_leg.dart';

class ItinerarySummaryAdvanced extends StatelessWidget {
  final double maxWidth;
  static const renderBarThreshold = 5;
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
    double addition = 0;
    const waitThreshold = 180;
    final List<Widget> legs = [];
    final compressLegs = itinerary.compressLegs;
    final lastLeg = compressLegs[itinerary.compressLegs.length - 1];
    final lastLegLength =
        ((lastLeg.durationIntLeg) / itinerary.durationItinerary) * 100;
    final int bikeParkedIndex =
        compressLegs.indexWhere((leg) => leg.toPlace?.bikeParkEntity != null);

    compressLegs.asMap().forEach((index, leg) {
      bool waiting = false;
      double waitTime;
      double waitLength;
      bool renderBar = true;
      PlanItineraryLeg nextLeg;
      final isNextLegLast = index + 1 == compressLegs.length - 1;
      final bool shouldRenderLastLeg =
          isNextLegLast && lastLegLength < renderBarThreshold;

      if (index < itinerary.legs.length - 1) {
        nextLeg = itinerary.legs[index + 1];
      }

      double legLength =
          (leg.durationIntLeg / itinerary.durationItinerary) * 100;

      if (nextLeg != null && !(nextLeg.intermediatePlace ?? false)) {
        waitTime =
            nextLeg.startTime.difference(leg.endTime).inSeconds.toDouble();
        waitLength = (waitTime / itinerary.durationItinerary) * 100;
        if (waitTime > waitThreshold && waitLength > renderBarThreshold) {
          waiting = true;
        } else {
          legLength = ((leg.durationIntLeg + (waitTime > 0 ? waitTime : 0)) /
                  itinerary.durationItinerary) *
              100;
        }
      }
      if (nextLeg != null && (nextLeg.interlineWithPreviousLeg ?? false)) {
        final int lastTime =
            nextLeg.endTime.difference(leg.startTime).inSeconds;
        if (lastTime > 0) {
          legLength = (lastTime / itinerary.durationItinerary) * 100;
        }
      }

      legLength += addition;
      addition = 0;

      if (shouldRenderLastLeg) {
        legLength += lastLegLength;
      }

      if (legLength < renderBarThreshold && leg.isLegOnFoot) {
        renderBar = false;
        addition += legLength;
      }

      if (leg.isLegOnFoot && renderBar) {
        legs.add(ModeLeg(
          maxWidth: maxWidth,
          leg: leg,
          legLength: legLength,
          duration: leg.durationIntLeg ~/ 60,
          renderModeIcons: itinerary.renderModeIcons,
          mode: itinerary.usingOwnBicycle && index < bikeParkedIndex
              ? 'BICYCLE_WALK'
              : 'WALK',
          isTransitLeg: false,
        ));
        if (leg.toPlace?.bikeParkEntity != null) {
          // onlyIconLegs += 1;
          legs.add(SizedBox(
            height: 22,
            width: 22,
            child: bikeParkingSvg,
          ));
        }
      } else if (leg.rentedBike ?? false) {
        legs.add(ModeLeg(
          maxWidth: maxWidth,
          leg: leg,
          legLength: legLength,
          duration: leg.durationIntLeg ~/ 60,
          renderModeIcons: itinerary.renderModeIcons,
          mode: 'CITYBIKE',
          isTransitLeg: false,
        ));
      } else if (leg.transportMode == TransportMode.car) {
        legs.add(ModeLeg(
          maxWidth: maxWidth,
          leg: leg,
          legLength: legLength,
          duration: leg.durationIntLeg ~/ 60,
          renderModeIcons: itinerary.renderModeIcons,
          mode: 'CAR',
          isTransitLeg: false,
        ));

        if (leg.toPlace?.carParkEntity != null) {
          // onlyIconLegs += 1;
          legs.add(SizedBox(
            height: 22,
            width: 22,
            child: carParkWithoutBoxSvg,
          ));
        }
      } else if (leg.transportMode == TransportMode.bicycle && renderBar) {
        legs.add(ModeLeg(
          maxWidth: maxWidth,
          leg: leg,
          legLength: legLength,
          duration: leg.durationIntLeg ~/ 60,
          renderModeIcons: itinerary.renderModeIcons,
          mode: 'BICYCLE',
          isTransitLeg: false,
        ));
        if (leg.toPlace?.bikeParkEntity != null) {
          // onlyIconLegs += 1;
          legs.add(SizedBox(
            height: 22,
            width: 22,
            child: bikeParkingSvg,
          ));
        }
      }
      if (leg.route != null && !(leg.interlineWithPreviousLeg ?? false)) {
        legs.add(RouteLeg(
          maxWidth: maxWidth,
          leg: leg,
          legLength: legLength,
          renderModeIcons: itinerary.renderModeIcons,
          mode: leg.transportMode.name,
          isTransitLeg: true,
        ));
      }
      if (waiting) {
        legs.add(ModeLeg(
          maxWidth: maxWidth,
          leg: leg,
          legLength: waitLength,
          duration: waitTime ~/ 60,
          renderModeIcons: itinerary.renderModeIcons,
          mode: 'WAIT',
          isTransitLeg: false,
        ));
      }
      // final int normalLegs = legs.length - onlyIconLegs;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: <Widget>[...legs],
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
