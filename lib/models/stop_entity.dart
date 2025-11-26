part of 'plan_entity.dart';

class StopEntity {
  final String? gtfsId;
  final double? lat;
  final double? lon;
  final String? name;
  final String? code;
  final TransportMode? vehicleMode;
  final String? platformCode;
  final String? zoneId;
  final String? id;
  final List<AlertEntity>? alerts;

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
    this.alerts,
  });

  static const String _gtfsId = 'gtfsId';
  static const String _lat = 'lat';
  static const String _lon = 'lon';
  static const String _name = 'name';
  static const String _code = 'code';
  static const String _vehicleMode = 'vehicleMode';
  static const String _platformCode = 'platformCode';
  static const String _zoneId = 'zoneId';
  static const String _id = 'id';
  static const String _alerts = 'alerts';

  factory StopEntity.fromJson(Map<String, dynamic> map) {
    return StopEntity(
      id: map[_id],
      gtfsId: map[_gtfsId],
      name: map[_name],
      lat: map[_lat],
      lon: map[_lon],
      code: map[_code],
      zoneId: map[_zoneId],
      platformCode: map[_platformCode],
      vehicleMode: getTransportMode(mode: map[_vehicleMode]),
      alerts:
          map[_alerts] != null
              ? List<AlertEntity>.from(
                (map[_alerts] as List<dynamic>).map(
                  (x) => AlertEntity.fromJson(x as Map<String, dynamic>),
                ),
              )
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      _gtfsId: gtfsId,
      _lat: lat,
      _lon: lon,
      _name: name,
      _code: code,
      _vehicleMode: vehicleMode?.name,
      _platformCode: platformCode,
      _zoneId: zoneId,
      _id: id,
      _alerts:
          alerts != null
              ? List<dynamic>.from(alerts!.map((x) => x.toJson()))
              : null,
    };
  }
}
