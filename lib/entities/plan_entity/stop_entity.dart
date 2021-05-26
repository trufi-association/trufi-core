class StopEntity {
  final String gtfsId;
  final double lat;
  final double lon;
  final String name;
  final String code;
  final String platformCode;
  final String zoneId;
  final String id;

  const StopEntity({
    this.gtfsId,
    this.lat,
    this.lon,
    this.name,
    this.code,
    this.platformCode,
    this.zoneId,
    this.id,
  });

  factory StopEntity.fromJson(Map<String, dynamic> json) => StopEntity(
        id: json['id'] as String,
        gtfsId: json['gtfsId'] as String,
        name: json['name'] as String,
        lat: double.tryParse(json['lat'].toString()) ?? 0,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
        code: json['code'] as String,
        zoneId: json['zoneId'] as String,
        platformCode: json['platformCode'] as String,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "gtfsId": gtfsId,
        "name": name,
        "lat": lat,
        "lon": lon,
        "code": code,
        "zoneId": zoneId,
        "platformCode": platformCode,
      };
}
