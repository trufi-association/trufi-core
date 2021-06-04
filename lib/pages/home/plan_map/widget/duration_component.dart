import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/utils/time_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class DurationComponent extends StatelessWidget {
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final String futureText;

  const DurationComponent({
    Key key,
    @required this.duration,
    @required this.startTime,
    @required this.endTime,
    this.futureText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Row(
      children: [
        const Icon(Icons.timer_sharp),
        const SizedBox(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              durationToString(localization, duration),
              style: theme.primaryTextTheme.bodyText1
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
                futureText != ''
                    ? '$futureText ${durationToHHmm(startTime)} - ${durationToHHmm(endTime)}'
                    : '${durationToHHmm(startTime)} - ${durationToHHmm(endTime)}',
                style: theme.primaryTextTheme.bodyText1
                    .copyWith(fontWeight: FontWeight.w400)),
          ],
        ),
      ],
    );
  }
}
