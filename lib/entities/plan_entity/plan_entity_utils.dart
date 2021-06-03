import 'package:intl/intl.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

String parseDurationTime(
  TrufiLocalization localization,
  Duration duration,
) {
  if (duration.inHours > 0) {
    return '${localization.instructionDurationHours(duration?.inHours)} ${localization.instructionDurationMinutes(duration?.inMinutes?.remainder(60))}';
  }
  if (duration.inMinutes == 0) {
    return localization.instructionDurationMinutes(1);
  } else {
    return localization
        .instructionDurationMinutes(duration?.inMinutes?.remainder(60));
  }
}

String getDistance(
  TrufiLocalization localization,
  double distance,
) {
  if (distance >= 1000) {
    final result = (distance / 1000).toStringAsFixed(1);
    final localizedDecimalPattern =
        NumberFormat.decimalPattern(localization.localeName)
            .format(double.parse(result));

    return localization.instructionDistanceKm(localizedDecimalPattern);
  } else {
    return localization.instructionDistanceMeters(distance.toStringAsFixed(0));
  }
}
