import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;

import 'package:trufi_core/l10n/trufi_localization.dart';

NumberFormat formatTwoDecimals({String localeName}) {
  return NumberFormat('#.00', localeName ?? 'en');
}

String displayDistanceWithLocale(
    TrufiLocalization localization, double meters) {
  if (meters < 100) {
    return localization.instructionDistanceMeters(formatTwoDecimals(
      localeName: localization.localeName,
    ).format(double.parse(((meters / 10).round() * 10).toStringAsFixed(1))));
  }
  if (meters < 975) {
    return localization.instructionDistanceMeters(formatTwoDecimals(
            localeName: localization.localeName)
        .format(double.parse(((meters / 50).round() * 50).toStringAsFixed(1))));
  }
  if (meters < 10000) {
    return localization.instructionDistanceKm(
        formatTwoDecimals(localeName: localization.localeName).format(
            double.parse(
                (((meters / 100).round() * 100) / 1000).toStringAsFixed(1))));
  }
  if (meters < 100000) {
    return localization.instructionDistanceKm(
        formatTwoDecimals(localeName: localization.localeName)
            .format(double.parse((meters / 1000).round().toStringAsFixed(1))));
  }
  return localization.instructionDistanceKm(formatTwoDecimals(
          localeName: localization.localeName)
      .format(double.parse(((meters / 1000).round() * 10).toStringAsFixed(1))));
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
