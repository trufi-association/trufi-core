import 'package:flutter/material.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/pages/home/plan_map/widget/duration_component.dart';
import 'package:trufi_core/pages/home/plan_map/widget/walk_distance.dart';

class BarItineraryDetails extends StatelessWidget {
  final PlanItinerary itinerary;
  const BarItineraryDetails({
    Key key,
    @required this.itinerary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          DurationComponent(
            duration: itinerary.durationTrip,
            startTime: itinerary.startTime,
            endTime: itinerary.endTime,
            futureText: itinerary.futureText(languageCode),
          ),
          // TODO adding spacer
          if (itinerary.totalWalkingDistance > 0)
            WalkDistance(
              walkDistance: itinerary.totalWalkingDistance,
              walkDuration: itinerary.totalWalkingDuration,
            ),
          if (itinerary.totalBikingDistance != null &&
              itinerary.totalBikingDistance > 0)
            WalkDistance(
              walkDistance: itinerary.totalBikingDistance,
              walkDuration: itinerary.totalBikingDuration,
              icon: bikeSvg,
            ),
        ],
      ),
    );
  }
}
