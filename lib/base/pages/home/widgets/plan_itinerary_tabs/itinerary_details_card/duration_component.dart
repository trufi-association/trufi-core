import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
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
    final showTimeItinerary =
        context.read<MapConfigurationCubit>().state.showTimeItinerary;
    return Row(
      children: [
        const Icon(Icons.timer_sharp),
        const SizedBox(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              durationFormatString(localization, duration),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: showTimeItinerary ? 17 : null,
              ),
            ),
            if (showTimeItinerary)
              Text(
                '${durationToHHmm(startTime)} - ${durationToHHmm(endTime)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
