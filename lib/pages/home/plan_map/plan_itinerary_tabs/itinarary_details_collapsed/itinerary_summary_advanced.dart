import 'package:flutter/material.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinarary_details_collapsed/mode_leg.dart';

class ItinerarySummaryAdvanced extends StatelessWidget {
  static const renderBarThreshold = 10;
  final PlanItinerary itinerary;

  const ItinerarySummaryAdvanced({
    Key key,
    @required this.itinerary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double addition = 0;
    const waitThreshold = 120;
    final List<Widget> list = [];
    final compressLegs = itinerary.compressLegs;
    final lastLeg = compressLegs[itinerary.compressLegs.length - 1];
    final lastLegLength =
        ((lastLeg.durationIntLeg) / itinerary.durationItinerary) * 100;

    compressLegs.asMap().forEach((index, value) {
      final leg = value;
      PlanItineraryLeg nextLeg;
      if (index < itinerary.legs.length - 1) {
        nextLeg = itinerary.legs[index + 1];
      }

      final isNextLegLast = index + 1 == compressLegs.length - 1;

      final bool shouldRenderLastLeg =
          isNextLegLast && lastLegLength < renderBarThreshold;

      bool waiting = false;
      double waitTime;
      double waitLength;
      bool renderBar = true;
      double legLength =
          (leg.durationIntLeg / itinerary.durationItinerary) * 100;

      if (nextLeg != null) {
        waitTime =
            nextLeg.startTime.difference(leg.endTime).inSeconds.toDouble();
        waitLength = (waitTime / itinerary.durationItinerary) * 100;
        if (waitTime > waitThreshold && waitLength > renderBarThreshold) {
          waiting = true;
        } else {
          legLength =
              ((leg.durationIntLeg + waitTime) / itinerary.durationItinerary) *
                  100;
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

      Widget tempWidget;
      if (leg.isLegOnFoot && renderBar) {
        tempWidget = Row(
          children: [
            ModeLeg(
              leg: leg,
              legLength: legLength,
              duration: leg.durationIntLeg ~/ 60,
              renderModeIcons: itinerary.renderModeIcons,
              mode: itinerary.usingOwnBicycle &&
                      leg.toPlace?.bikeParkEntity != null
                  ? 'WALK'
                  : 'BICYCLE_WALK',
              isTransitLeg: false,
            ),
            // if (leg.toPlace?.bikeParkEntity != null)
            //   SizedBox(
            //     height: 20,
            //     width: 20,
            //     child: bikeParkingSvg,
            //   ),
          ],
        );
      } else if (leg.rentedBike ?? false) {
        // addition += legLength;
        // tempWidget = ModeLeg(
        //   leg: leg,
        //   legLength: legLength,
        //   duration: (leg.durationIntLeg / 1000) ~/ 60,
        //   renderModeIcons: itinerary.renderModeIcons,
        //   mode: 'CITYBIKE',
        //   isTransitLeg: false,
        // );
      } else if (leg.transportMode == TransportMode.car) {
        tempWidget = Row(
          children: [
            ModeLeg(
              leg: leg,
              legLength: legLength,
              duration: (leg.durationIntLeg / 1000) ~/ 60,
              renderModeIcons: itinerary.renderModeIcons,
              mode: 'CAR',
              isTransitLeg: false,
            ),
            // if (leg.toPlace?.carParkEntity != null)
            //   SizedBox(
            //     height: 20,
            //     width: 20,
            //     child: carParkWithoutBoxSvg,
            //   ),
          ],
        );
      } else if (leg.transportMode == TransportMode.bicycle && renderBar) {
        tempWidget = Row(
          children: [
            ModeLeg(
              leg: leg,
              legLength: legLength,
              duration: (leg.durationIntLeg / 1000) ~/ 60,
              renderModeIcons: itinerary.renderModeIcons,
              mode: 'BICYCLE',
              isTransitLeg: false,
            ),
            // if (leg.toPlace?.bikeParkEntity != null)
            //   SizedBox(
            //     height: 20,
            //     width: 20,
            //     child: bikeParkingSvg,
            //   ),
          ],
        );
      }
      list.add(Row(
        children: [
          if (tempWidget != null) tempWidget,
          if (leg.route != null)
            RouteLeg(
              leg: leg,
              legLength: legLength,
              duration: (leg.durationIntLeg / 1000) ~/ 60,
              renderModeIcons: itinerary.renderModeIcons,
              mode: leg.transportMode.name,
              isTransitLeg: true,
            ),
          if (waiting)
            ModeLeg(
              leg: leg,
              legLength: waitLength,
              duration: (waitTime / 1000) ~/ 60,
              renderModeIcons: itinerary.renderModeIcons,
              mode: 'WAIT',
              isTransitLeg: false,
            ),
        ],
      ));
    });
    final width = MediaQuery.of(context).size.width * 0.9;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: Row(
            children: <Widget>[...list],
          ),
        ),
        SizedBox(
          child: Text(
            itinerary.firstLegStartTime,
            style: theme.primaryTextTheme.bodyText1,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
