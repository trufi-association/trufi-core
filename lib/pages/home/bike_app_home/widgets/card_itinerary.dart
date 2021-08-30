import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/utils/time_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class CardItinerary extends StatelessWidget {
  const CardItinerary({
    Key key,
    @required this.itinerary,
    @required this.index,
  }) : super(key: key);
  final PlanItinerary itinerary;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Card(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Über Station X$index",
              style: theme.textTheme.bodyText1
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${localization.instructionDurationMinutes(itinerary.time)} ",
                  style: theme.textTheme.subtitle1
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${durationToHHmm(itinerary.startTime)} - ${durationToHHmm(itinerary.endTime)}',
                  style: theme.primaryTextTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  itinerary.getDistanceString(localization),
                  style: theme.textTheme.subtitle1
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Mehr Bike',
                  style: theme.textTheme.bodyText2
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
