import 'package:intl/intl.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

import '../../../../trufi_models.dart';

String parsePlace(TrufiLocation location) {
  return "${location.description}::${location.latitude},${location.longitude}";
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
