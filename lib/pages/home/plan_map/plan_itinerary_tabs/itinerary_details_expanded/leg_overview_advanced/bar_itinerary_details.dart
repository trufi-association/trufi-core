import 'package:flutter/material.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
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
    final localization = TrufiLocalization.of(context);
    return Container(
      height: 40,
      padding: const EdgeInsets.only(right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DurationComponent(
            duration: itinerary.durationTrip,
            startTime: itinerary.startTime,
            endTime: itinerary.endTime,
            futureText: itinerary.futureText(localization),
          ),
          Row(
            children: [
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
          )
        ],
      ),
    );
  }
}
