import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/journey_plan/utils/duration_utils.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class DurationComponent extends StatelessWidget {
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final String futureText;

  const DurationComponent({
    Key? key,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.futureText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    return Row(
      children: [
        const Icon(Icons.timer_sharp),
        const SizedBox(width: 2),
        Text(
          durationFormatString(localization, duration),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
