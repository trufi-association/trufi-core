import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/journey_plan/utils/duration_utils.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class DurationComponent extends StatelessWidget {
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final String futureText;

  const DurationComponent({
    super.key,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.futureText = '',
  });

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.timer_sharp,
          size: 24,
        ),
        const SizedBox(width: 2),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              durationFormatString(localization, duration),
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, height: 0),
            ),
            Text(
              localization.localeName == 'en'
                  ? "(Estimated time)"
                  : "(Tiempo aproximado)",
              style: const TextStyle(
                height: 0,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
