import 'package:intl/intl.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

String durationFormatString(TrufiBaseLocalization localization, Duration duration) {
  final minutes =
      localization.instructionDurationMinutes(duration.inMinutes.remainder(60));

  if (duration.inHours >= 1) {
    final hours = localization
        .instructionDurationHours(duration.inHours + duration.inDays * 24);
    return '$hours $minutes';
  }

  if (duration.inMinutes < 1) {
    return '< ${localization.instructionDurationMinutes(1)}';
  }

  return minutes;
}

String durationToHHmm(DateTime duration) =>
    DateFormat('HH:mm').format(duration);
