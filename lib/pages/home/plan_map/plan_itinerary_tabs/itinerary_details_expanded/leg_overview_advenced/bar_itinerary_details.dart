import 'package:flutter/material.dart';

import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class BarItineraryDetails extends StatelessWidget {
  final PlanItinerary itinerary;
  const BarItineraryDetails({
    Key key,
    @required this.itinerary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final localization = TrufiLocalization.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_sharp),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${itinerary.durationTripString(localization)} ',
                    style: theme.primaryTextTheme.bodyText1
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                      '${itinerary.startTimeComplete(languageCode)} - ${itinerary.endTimeHHmm}',
                      style: theme.primaryTextTheme.bodyText1
                          .copyWith(fontWeight: FontWeight.w400)),
                ],
              ),
              const Spacer(),
              Icon(TransportMode.walk.icon),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerary.walkTimeHHmm(localization),
                    style: theme.primaryTextTheme.bodyText1
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    itinerary.getWalkDistanceString(localization),
                    style: theme.primaryTextTheme.bodyText1
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
