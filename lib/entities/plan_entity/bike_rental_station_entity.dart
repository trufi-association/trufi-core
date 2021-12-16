import 'dart:convert';

class BikeRentalStationEntity {
  final String? id;
  final String? stationId;
  final String? name;
  final int? bikesAvailable;
  final int? spacesAvailable;
  final String? state;
  final bool? realtime;
  final bool? allowDropoff;
  final List<String>? networks;
  final double? lon;
  final double? lat;
  final int? capacity;
  final bool? allowOverloading;

  const BikeRentalStationEntity({
    this.id,
    this.stationId,
    this.name,
    this.bikesAvailable,
    this.spacesAvailable,
    this.state,
    this.realtime,
    this.allowDropoff,
    this.networks,
    this.lon,
    this.lat,
    this.capacity,
    this.allowOverloading,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stationId': stationId,
      'name': name,
      'bikesAvailable': bikesAvailable,
      'spacesAvailable': spacesAvailable,
      'state': state,
      'realtime': realtime,
      'allowDropoff': allowDropoff,
      'networks': networks,
      'lon': lon,
      'lat': lat,
      'capacity': capacity,
      'allowOverloading': allowOverloading,
    };
  }

  factory BikeRentalStationEntity.fromMap(Map<String, dynamic> map) {
    return BikeRentalStationEntity(
      id: map['id'] as String?,
      stationId: map['stationId'] as String?,
      name: map['name'] as String?,
      bikesAvailable: map['bikesAvailable'] as int?,
      spacesAvailable: map['spacesAvailable'] as int?,
      state: map['state'].toString(),
      realtime: map['realtime'] as bool?,
      allowDropoff: map['allowDropoff'] as bool?,
      networks: map['networks'] != null
          ? (map['networks'] as List<dynamic>).cast<String>()
          : null,
      lon: map['lon'] as double?,
      lat: map['lat'] as double?,
      capacity: map['capacity'] as int?,
      allowOverloading: map['allowOverloading'] as bool?,
    );
  }

  String toJson() => json.encode(toMap());

  factory BikeRentalStationEntity.fromJson(String source) =>
      BikeRentalStationEntity.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
