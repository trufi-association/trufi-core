import 'package:intl/intl.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';

import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

import '../plan.dart';

String distanceWithTranslation(
    TrufiBaseLocalization localization, double meters) {
  final tempMeters = meters;
  if (tempMeters < 100) {
    double roundMeters = (tempMeters / 10).round() * 10;

    return localization.instructionDistanceMeters(_formatOneDecimals(
      localeName: localization.localeName,
    ).format(roundMeters > 0 ? roundMeters : 1));
  }
  if (tempMeters < 975) {
    return localization.instructionDistanceMeters(
        _formatOneDecimals(localeName: localization.localeName)
            .format((tempMeters / 50).round() * 50));
  }
  if (tempMeters < 10000) {
    return localization.instructionDistanceKm(
        _formatOneDecimals(localeName: localization.localeName)
            .format(((tempMeters / 100).round() * 100) / 1000));
  }
  if (tempMeters < 100000) {
    return localization.instructionDistanceKm(
        _formatOneDecimals(localeName: localization.localeName)
            .format((tempMeters / 1000).round()));
  }
  return localization.instructionDistanceKm(
      _formatOneDecimals(localeName: localization.localeName)
          .format((tempMeters / 1000).round() * 10));
}

NumberFormat _formatOneDecimals({String? localeName}) {
  return NumberFormat('#.0', localeName ?? 'en');
}

bool continueWithNoTransit(Leg leg1, Leg leg2) {
  final bool isBicycle1 = leg1.transportMode == TransportMode.bicycle ||
      leg1.transportMode == TransportMode.walk;
  final bool isBicycle2 = leg2.transportMode == TransportMode.bicycle ||
      leg2.transportMode == TransportMode.walk;
  return isBicycle1 && isBicycle2;
}

double getTotalBikingDistance(List<Leg> legs) =>
    sumDistances(legs.where(isBikingLeg).toList());

double sumDistances(List<Leg> legs) {
  return legs.isNotEmpty
      ? legs.map((e) => e.distance).reduce((value, element) => value + element)
      : 0;
}

Duration getTotalBikingDuration(List<Leg> legs) {
  return _sumDurations(legs.where(isBikingLeg).toList());
}

Duration _sumDurations(List<Leg> legs) {
  return legs.isNotEmpty
      ? legs.map((e) => e.duration).reduce((value, element) => value + element)
      : const Duration();
}

bool isWalkingLeg(Leg leg) {
  return [TransportMode.walk].contains(leg.transportMode);
}

bool isBikingLeg(Leg leg) {
  return [
    TransportMode.bicycle,
  ].contains(leg.transportMode);
}
