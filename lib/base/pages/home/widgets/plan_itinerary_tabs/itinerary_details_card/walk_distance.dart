import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/journey_plan/utils/duration_utils.dart';
import 'package:trufi_core/base/models/journey_plan/utils/leg_utils.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class WalkDistance extends StatelessWidget {
  final double walkDistance;
  final Duration? walkDuration;
  final Widget icon;

  const WalkDistance({
    super.key,
    required this.walkDistance,
    required this.walkDuration,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(6),
          width: 24,
          height: 24,
          child: icon,
        ),
        const SizedBox(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (walkDuration != null)
              Text(
                durationFormatString(localization, walkDuration!),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            Text(
              distanceWithTranslation(localization, walkDistance),
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        )
      ],
    );
  }
}
