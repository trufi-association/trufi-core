import 'dart:math';

import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_core/l10n/trufi_localization.dart';

String displayDistanceWithLocale(
    TrufiLocalization localization, double meters) {
  if (meters < 100) {
    return localization.instructionDistanceMeters(
        NumberFormat.decimalPattern(localization.localeName).format(
            double.parse(((meters / 10).round() * 10).toStringAsFixed(1))));
  }
  if (meters < 975) {
    return localization.instructionDistanceMeters(
        NumberFormat.decimalPattern(localization.localeName).format(
            double.parse(((meters / 50).round() * 50).toStringAsFixed(1))));
  }
  if (meters < 10000) {
    return localization.instructionDistanceKm(
        NumberFormat.decimalPattern(localization.localeName).format(
            double.parse(
                (((meters / 100).round() * 100) / 1000).toStringAsFixed(1))));
  }
  if (meters < 100000) {
    return localization.instructionDistanceKm(
        NumberFormat.decimalPattern(localization.localeName)
            .format(double.parse((meters / 1000).round().toStringAsFixed(1))));
  }
  return localization.instructionDistanceKm(
      NumberFormat.decimalPattern(localization.localeName).format(
          double.parse(((meters / 1000).round() * 10).toStringAsFixed(1))));
}

double estimateItineraryDistance(LatLng from, LatLng to,
    {List<LatLng> viaPoints = const []}) {
  double distance = 0;
  final List<LatLng> points = [from, ...viaPoints, to];
  for (var i = 0; i < points.length - 1; i++) {
    distance += distanceTwoPoints(points[i], points[i + 1]);
  }
  return distance;
}

double distanceTwoPoints(LatLng from, LatLng to) {
  const p = 0.017453292519943295;
  final a = 0.5 -
      cos((to.latitude - from.latitude) * p) / 2 +
      cos(from.latitude * p) *
          cos(to.latitude * p) *
          (1 - cos(to.longitude - from.longitude * p) / 2);
  return 12742 * asin(sqrt(a));
}
