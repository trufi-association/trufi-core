import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;

import 'package:trufi_core/l10n/trufi_localization.dart';

NumberFormat formatTwoDecimals({String localeName}) {
  return NumberFormat('#.00', localeName ?? 'en');
}

NumberFormat formatOneDecimals({String localeName}) {
  return NumberFormat('#.0', localeName ?? 'en');
}

String displayDistanceWithLocale(
    TrufiLocalization localization, double meters) {
  final tempMeters = meters ?? 0;
  if (tempMeters < 100) {
    return localization.instructionDistanceMeters(formatOneDecimals(
      localeName: localization.localeName,
    ).format((tempMeters / 10).round() * 10));
  }
  if (tempMeters < 975) {
    return localization.instructionDistanceMeters(
        formatOneDecimals(localeName: localization.localeName)
            .format((tempMeters / 50).round() * 50));
  }
  if (tempMeters < 10000) {
    return localization.instructionDistanceKm(
        formatOneDecimals(localeName: localization.localeName)
            .format(((tempMeters / 100).round() * 100) / 1000));
  }
  if (tempMeters < 100000) {
    return localization.instructionDistanceKm(
        formatOneDecimals(localeName: localization.localeName)
            .format((tempMeters / 1000).round()));
  }
  return localization.instructionDistanceKm(
      formatOneDecimals(localeName: localization.localeName)
          .format((tempMeters / 1000).round() * 10));
}

double estimateItineraryDistance(LatLng from, LatLng to,
    {List<LatLng> viaPoints = const []}) {
  double distance = 0;
  final List<LatLng> points = [from, ...viaPoints, to];
  for (var i = 0; i < points.length - 1; i++) {
    distance += toolkit.SphericalUtil.computeDistanceBetween(
      toolkit.LatLng(points[i].latitude, points[i].longitude),
      toolkit.LatLng(points[i + 1].latitude, points[i + 1].longitude),
    );
  }
  return distance;
}
