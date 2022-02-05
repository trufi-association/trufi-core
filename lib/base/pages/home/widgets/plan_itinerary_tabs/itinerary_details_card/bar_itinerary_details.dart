import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/duration_component.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/walk_distance.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';

class BarItineraryDetails extends StatelessWidget {
  final Itinerary itinerary;
  const BarItineraryDetails({
    Key? key,
    required this.itinerary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Container(
      height: itinerary.startDateText(localization) == '' ? 40 : 54,
      padding: const EdgeInsets.only(right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DurationComponent(
            duration: itinerary.duration,
            startTime: itinerary.startTime,
            endTime: itinerary.endTime,
            futureText: itinerary.startDateText(localization),
          ),
          Row(
            children: [
              if (itinerary.walkDistance > 0)
                WalkDistance(
                  walkDistance: itinerary.walkDistance,
                  walkDuration: itinerary.walkTime,
                  icon: walkIcon(color: theme.iconTheme.color),
                ),
              const SizedBox(width: 10),
              if (itinerary.totalBikingDistance > 0)
                WalkDistance(
                  walkDistance: itinerary.totalBikingDistance,
                  walkDuration: itinerary.totalBikingDuration,
                  icon: bikeIcon(color: theme.iconTheme.color),
                ),
            ],
          )
        ],
      ),
    );
  }
}
