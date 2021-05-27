import 'package:trufi_core/l10n/trufi_localization.dart';

String parseDurationTime(
  TrufiLocalization localization,
  Duration duration,
) {
  if (duration.inHours > 0) {
    return '${localization.instructionDurationHours(duration?.inHours)} h ${localization.instructionDurationMinutes(duration?.inMinutes?.remainder(60))}';
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
  return distance >= 1000
      ? localization.instructionDistanceKm((distance / 1000).toStringAsFixed(1))
      : localization.instructionDistanceMeters(distance.toStringAsFixed(0));
}
