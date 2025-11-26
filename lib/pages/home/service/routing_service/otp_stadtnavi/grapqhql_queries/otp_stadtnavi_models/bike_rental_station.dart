import 'package:trufi_core/models/plan_entity.dart';

class BikeRentalStation {
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

  const BikeRentalStation({
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

  factory BikeRentalStation.fromJson(Map<String, dynamic> json) =>
      BikeRentalStation(
        id: json['id'] as String?,
        stationId: json['stationId'] as String?,
        name: json['name'] as String?,
        bikesAvailable: json['bikesAvailable'] as int?,
        spacesAvailable: json['spacesAvailable'] as int?,
        state: json['state'].toString(),
        realtime: json['realtime'] as bool?,
        allowDropoff: json['allowDropoff'] as bool?,
        networks: json['networks'] != null
            ? (json['networks'] as List<dynamic>).cast<String>()
            : null,
        lon: json['lon'] as double?,
        lat: json['lat'] as double?,
        capacity: json['capacity'] as int?,
        allowOverloading: json['allowOverloading'] as bool?,
      );

  Map<String, dynamic> toJson() => {
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

  BikeRentalStationEntity toBikeRentalStation() {
    return BikeRentalStationEntity(
      id: id,
      stationId: stationId,
      name: name,
      bikesAvailable: bikesAvailable,
      spacesAvailable: spacesAvailable,
      state: state,
      realtime: realtime,
      allowDropoff: allowDropoff,
      networks: networks,
      lon: lon,
      lat: lat,
      capacity: capacity,
      allowOverloading: allowOverloading,
    );
  }
}
