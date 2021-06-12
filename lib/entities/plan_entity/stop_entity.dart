import 'dart:convert';

import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class StopEntity {
  final String gtfsId;
  final double lat;
  final double lon;
  final String name;
  final String code;
  final TransportMode vehicleMode;
  final String platformCode;
  final String zoneId;
  final String id;

  const StopEntity({
    this.gtfsId,
    this.lat,
    this.lon,
    this.name,
    this.code,
    this.vehicleMode,
    this.platformCode,
    this.zoneId,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'gtfsId': gtfsId,
      'lat': lat,
      'lon': lon,
      'name': name,
      'code': code,
      'vehicleMode': vehicleMode?.name,
      'platformCode': platformCode,
      'zoneId': zoneId,
      'id': id,
    };
  }

  factory StopEntity.fromMap(Map<String, dynamic> map) {
    return StopEntity(
        id: map['id'] as String,
        gtfsId: map['gtfsId'] as String,
        name: map['name'] as String,
        lat: double.tryParse(map['lat'].toString()) ?? 0,
        lon: double.tryParse(map['lon'].toString()) ?? 0,
        code: map['code'] as String,
        zoneId: map['zoneId'] as String,
        platformCode: map['platformCode'] as String,
        vehicleMode: getTransportMode(mode: map['vehicleMode'].toString()));
  }

  String toJson() => json.encode(toMap());

  factory StopEntity.fromJson(String source) =>
      StopEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}
