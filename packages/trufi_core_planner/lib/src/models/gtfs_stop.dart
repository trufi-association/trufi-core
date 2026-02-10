import 'package:latlong2/latlong.dart';

/// GTFS Stop entity.
/// Represents a stop/station from stops.txt
class GtfsStop {
  final String id;
  final String? code;
  final String name;
  final String? description;
  final double lat;
  final double lon;
  final String? zoneId;
  final String? url;
  final GtfsLocationType locationType;
  final String? parentStation;
  final String? timezone;
  final GtfsWheelchairBoarding wheelchairBoarding;
  final String? platformCode;

  const GtfsStop({
    required this.id,
    this.code,
    required this.name,
    this.description,
    required this.lat,
    required this.lon,
    this.zoneId,
    this.url,
    this.locationType = GtfsLocationType.stop,
    this.parentStation,
    this.timezone,
    this.wheelchairBoarding = GtfsWheelchairBoarding.noInfo,
    this.platformCode,
  });

  LatLng get position => LatLng(lat, lon);

  factory GtfsStop.fromCsv(Map<String, String> row) {
    return GtfsStop(
      id: row['stop_id'] ?? '',
      code: row['stop_code'],
      name: row['stop_name'] ?? '',
      description: row['stop_desc'],
      lat: double.tryParse(row['stop_lat'] ?? '') ?? 0,
      lon: double.tryParse(row['stop_lon'] ?? '') ?? 0,
      zoneId: row['zone_id'],
      url: row['stop_url'],
      locationType: GtfsLocationType.fromValue(
        int.tryParse(row['location_type'] ?? '') ?? 0,
      ),
      parentStation: row['parent_station'],
      timezone: row['stop_timezone'],
      wheelchairBoarding: GtfsWheelchairBoarding.fromValue(
        int.tryParse(row['wheelchair_boarding'] ?? '') ?? 0,
      ),
      platformCode: row['platform_code'],
    );
  }

  factory GtfsStop.fromJson(Map<String, dynamic> json) {
    return GtfsStop(
      id: json['id'] as String,
      code: json['code'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      zoneId: json['zoneId'] as String?,
      url: json['url'] as String?,
      locationType: GtfsLocationType.fromValue(
        json['locationType'] as int? ?? 0,
      ),
      parentStation: json['parentStation'] as String?,
      timezone: json['timezone'] as String?,
      wheelchairBoarding: GtfsWheelchairBoarding.fromValue(
        json['wheelchairBoarding'] as int? ?? 0,
      ),
      platformCode: json['platformCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'lat': lat,
        'lon': lon,
        'zoneId': zoneId,
        'url': url,
        'locationType': locationType.value,
        'parentStation': parentStation,
        'timezone': timezone,
        'wheelchairBoarding': wheelchairBoarding.value,
        'platformCode': platformCode,
      };
}

/// Location type for stops.
enum GtfsLocationType {
  stop(0),
  station(1),
  entranceExit(2),
  genericNode(3),
  boardingArea(4);

  final int value;
  const GtfsLocationType(this.value);

  static GtfsLocationType fromValue(int value) {
    return GtfsLocationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsLocationType.stop,
    );
  }
}

/// Wheelchair boarding accessibility.
enum GtfsWheelchairBoarding {
  noInfo(0),
  someAccessible(1),
  notAccessible(2);

  final int value;
  const GtfsWheelchairBoarding(this.value);

  static GtfsWheelchairBoarding fromValue(int value) {
    return GtfsWheelchairBoarding.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsWheelchairBoarding.noInfo,
    );
  }
}
