import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;

import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/trufi_place.dart';

String parsePlace(TrufiLocation location) {
  return "${location.description}::${location.latitude},${location.longitude}";
}

List<Map<String, String>> parseBikeAndPublicModes(List<TransportMode> list) {
  final dataParse = list
      .map((e) => <String, String>{
            'mode': e.name,
          })
      .where((e) => e['mode'] != TransportMode.bicycle.name)
      .toList();
  dataParse.add({"mode": TransportMode.bicycle.name});
  return dataParse;
}

List<Map<String, String>> parsebikeParkModes(List<TransportMode> list) {
  final dataParse = list
      .map((e) => <String, String>{
            'mode': e.name,
          })
      .where((e) => e['mode'] != TransportMode.bicycle.name)
      .toList();
  dataParse.add({"mode": TransportMode.bicycle.name, 'qualifier': 'PARK'});
  return dataParse;
}

Map<String, String> parseCarMode(LatLng destiny) {
  final bool isInHerrenbergOldTown = toolkit.PolygonUtil.containsLocation(
    toolkit.LatLng(destiny.latitude, destiny.longitude),
    herrenbergOldTown,
    false,
  );
  return {
    "mode": TransportMode.car.name,
    'qualifier': isInHerrenbergOldTown ? 'PARK' : null,
  };
}

List<Map<String, String>> parseTransportModes(List<TransportMode> list) {
  final dataParse = list
      .map((e) => <String, String>{
            'mode': e.name,
            'qualifier': e.qualifier,
          })
      .toList();
  return dataParse;
}

List<String> parseBikeRentalNetworks(List<BikeRentalNetwork> list) {
  final dataParse = list.map((e) => e.name).toList();
  return dataParse;
}

String parseDateFormat(DateTime date) {
  final tempDate = date ?? DateTime.now();
  return DateFormat('yyyy-MM-dd').format(tempDate);
}

String parseTime(DateTime date) {
  final tempDate = date ?? DateTime.now();
  return DateFormat('HH:mm:ss').format(tempDate);
}

final herrenbergOldTown = [
  toolkit.LatLng(48.597699150626, 8.869678974151611),
  toolkit.LatLng(48.597138608565004, 8.86869192123413),
  toolkit.LatLng(48.59679802300929, 8.868058919906614),
  toolkit.LatLng(48.59623037531388, 8.867533206939697),
  toolkit.LatLng(48.59579044396286, 8.867640495300293),
  toolkit.LatLng(48.59546404080754, 8.867865800857544),
  toolkit.LatLng(48.59491766558894, 8.869807720184326),
  toolkit.LatLng(48.59478284482093, 8.870537281036377),
  toolkit.LatLng(48.59473317392094, 8.871921300888062),
  toolkit.LatLng(48.59490347394611, 8.872436285018921),
  toolkit.LatLng(48.59498862374342, 8.873004913330078),
  toolkit.LatLng(48.59542856207662, 8.873004913330078),
  toolkit.LatLng(48.595804635356565, 8.872951269149778),
  toolkit.LatLng(48.59615232325695, 8.873069286346436),
  toolkit.LatLng(48.5964929131658, 8.873069286346436),
  toolkit.LatLng(48.59674125852678, 8.872683048248291),
  toolkit.LatLng(48.597159895085994, 8.87222170829773),
  toolkit.LatLng(48.597358568849394, 8.872264623641968),
  toolkit.LatLng(48.59748628728471, 8.871663808822632),
  toolkit.LatLng(48.59774881860992, 8.8714599609375),
  toolkit.LatLng(48.598238400409684, 8.871009349822998),
  toolkit.LatLng(48.598394497956946, 8.870773315429686),
  toolkit.LatLng(48.59770624605526, 8.869636058807373),
  toolkit.LatLng(48.59769915062, 8.8696789741516116)
];
