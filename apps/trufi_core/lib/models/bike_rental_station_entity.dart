part of 'plan_entity.dart';

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

  static const String _id = 'id';
  static const String _stationId = 'stationId';
  static const String _name = 'name';
  static const String _bikesAvailable = 'bikesAvailable';
  static const String _spacesAvailable = 'spacesAvailable';
  static const String _state = 'state';
  static const String _realtime = 'realtime';
  static const String _allowDropoff = 'allowDropoff';
  static const String _networks = 'networks';
  static const String _lon = 'lon';
  static const String _lat = 'lat';
  static const String _capacity = 'capacity';
  static const String _allowOverloading = 'allowOverloading';

  factory BikeRentalStationEntity.fromJson(Map<String, dynamic> map) {
    return BikeRentalStationEntity(
      id: map[_id],
      stationId: map[_stationId],
      name: map[_name],
      bikesAvailable: map[_bikesAvailable],
      spacesAvailable: map[_spacesAvailable],
      state: map[_state],
      realtime: map[_realtime],
      allowDropoff: map[_allowDropoff],
      networks:
          map[_networks] != null
              ? (map[_networks] as List<dynamic>).cast<String>()
              : null,
      lon: map[_lon],
      lat: map[_lat],
      capacity: map[_capacity],
      allowOverloading: map[_allowOverloading],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _id: id,
      _stationId: stationId,
      _name: name,
      _bikesAvailable: bikesAvailable,
      _spacesAvailable: spacesAvailable,
      _state: state,
      _realtime: realtime,
      _allowDropoff: allowDropoff,
      _networks: networks,
      _lon: lon,
      _lat: lat,
      _capacity: capacity,
      _allowOverloading: allowOverloading,
    };
  }
}
