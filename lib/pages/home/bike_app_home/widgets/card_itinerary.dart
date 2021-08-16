import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
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
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            color: Colors.black,
            child: Center(
              child: Text(
                "Route $index",
                style: theme.textTheme.headline6.copyWith(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Über Station X$index",
                  style: theme.textTheme.bodyText2
                      .copyWith(fontWeight: FontWeight.bold),
                ),
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
          ),
        ],
      ),
    );
  }
}
