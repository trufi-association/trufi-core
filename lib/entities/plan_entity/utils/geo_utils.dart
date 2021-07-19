import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
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

double estimateDistance(LatLng from, LatLng to,
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

bool insidePointInPolygon(LatLng point, List<LatLng> polygon) {
  return toolkit.PolygonUtil.containsLocation(
    toolkit.LatLng(point.latitude, point.longitude),
    convertToTolkitLatLng(polygon),
    false,
  );
}

List<toolkit.LatLng> convertToTolkitLatLng(List<LatLng> list) {
  return list
      .map((point) => toolkit.LatLng(point.latitude, point.longitude))
      .toList();
}

final herrenbergOldTown = [
  LatLng(48.597699150626, 8.869678974151611),
  LatLng(48.597138608565004, 8.86869192123413),
  LatLng(48.59679802300929, 8.868058919906614),
  LatLng(48.59623037531388, 8.867533206939697),
  LatLng(48.59579044396286, 8.867640495300293),
  LatLng(48.59546404080754, 8.867865800857544),
  LatLng(48.59491766558894, 8.869807720184326),
  LatLng(48.59478284482093, 8.870537281036377),
  LatLng(48.59473317392094, 8.871921300888062),
  LatLng(48.59490347394611, 8.872436285018921),
  LatLng(48.59498862374342, 8.873004913330078),
  LatLng(48.59542856207662, 8.873004913330078),
  LatLng(48.595804635356565, 8.872951269149778),
  LatLng(48.59615232325695, 8.873069286346436),
  LatLng(48.5964929131658, 8.873069286346436),
  LatLng(48.59674125852678, 8.872683048248291),
  LatLng(48.597159895085994, 8.87222170829773),
  LatLng(48.597358568849394, 8.872264623641968),
  LatLng(48.59748628728471, 8.871663808822632),
  LatLng(48.59774881860992, 8.8714599609375),
  LatLng(48.598238400409684, 8.871009349822998),
  LatLng(48.598394497956946, 8.870773315429686),
  LatLng(48.59770624605526, 8.869636058807373),
  LatLng(48.59769915062, 8.8696789741516116)
];

final areaPolygon = [
  LatLng(60.3316, 18.776),
  LatLng(60.7385, 18.9625),
  LatLng(60.8957, 19.8615),
  LatLng(61.1942, 20.4145),
  LatLng(61.9592, 20.4349),
  LatLng(63.2157, 19.7853),
  LatLng(63.6319, 20.4727),
  LatLng(63.8559, 21.6353),
  LatLng(64.7794, 23.4626),
  LatLng(65.3008, 23.7244),
  LatLng(65.8569, 23.6873),
  LatLng(66.2701, 23.2069),
  LatLng(66.8344, 23.4627),
  LatLng(67.4662, 22.9291),
  LatLng(67.9229, 23.0459),
  LatLng(68.7605, 20.5459),
  LatLng(69.14, 20.0996),
  LatLng(69.4835, 21.426),
  LatLng(69.4009, 21.9928),
  LatLng(68.8678, 22.9226),
  LatLng(69.0145, 23.8108),
  LatLng(68.8614, 24.6903),
  LatLng(69.0596, 25.2262),
  LatLng(69.7235, 25.4029),
  LatLng(70.0559, 26.066),
  LatLng(70.2496, 28.2123),
  LatLng(69.7854, 29.5813),
  LatLng(69.49, 29.8467),
  LatLng(68.515, 28.9502),
  LatLng(67.6952, 30.4855),
  LatLng(66.9232, 29.4962),
  LatLng(65.8728, 30.5219),
  LatLng(64.9646, 30.1543),
  LatLng(64.1321, 30.9641),
  LatLng(63.7098, 30.572),
  LatLng(63.3309, 31.5491),
  LatLng(62.9304, 31.9773),
  LatLng(62.426, 31.576),
  LatLng(60.1117, 27.739),
  LatLng(59.8015, 26.0945),
  LatLng(59.3342, 22.4235),
  LatLng(59.2763, 20.2983),
  LatLng(59.6858, 19.3719),
  LatLng(60.1305, 18.7454),
  LatLng(60.3316, 18.776),
];
