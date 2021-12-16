import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/utils/geo_utils.dart';
import 'package:trufi_core/entities/plan_entity/utils/time_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class WalkDistance extends StatelessWidget {
  final double walkDistance;
  final Duration walkDuration;
  final Widget? icon;

  const WalkDistance({
    Key? key,
    required this.walkDistance,
    required this.walkDuration,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Container(
            margin: const EdgeInsets.all(6),
            width: 24,
            height: 24,
            child: icon,
          )
        else
          Icon(
            TransportMode.walk.icon,
            size: 27,
          ),
        const SizedBox(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              durationToString(localization, walkDuration),
              style: theme.primaryTextTheme.bodyText1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              displayDistanceWithLocale(localization, walkDistance),
              style: theme.primaryTextTheme.bodyText1!
                  .copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        )
      ],
    );
  }
}
