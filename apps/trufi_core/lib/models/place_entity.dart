part of 'plan_entity.dart';

class PlaceEntity {
  final String name;
  final VertexTypeTrufi vertexType;
  final double lat;
  final double lon;
  final DateTime? arrivalTime;
  final DateTime? departureTime;
  final StopEntity? stopEntity;
  final BikeRentalStationEntity? bikeRentalStation;
  final BikeParkEntity? bikeParkEntity;
  final CarParkEntity? carParkEntity;
  final VehicleParkingWithEntranceEntity? vehicleParkingWithEntrance;

  const PlaceEntity({
    required this.name,
    required this.vertexType,
    required this.lat,
    required this.lon,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopEntity,
    required this.bikeRentalStation,
    required this.bikeParkEntity,
    required this.carParkEntity,
    required this.vehicleParkingWithEntrance,
  });

  static const String _name = 'name';
  static const String _vertexType = 'vertexType';
  static const String _lat = 'lat';
  static const String _lon = 'lon';
  static const String _arrivalTime = 'arrivalTime';
  static const String _departureTime = 'departureTime';
  static const String _stopEntity = 'stopEntity';
  static const String _bikeRentalStation = 'bikeRentalStation';
  static const String _bikeParkEntity = 'bikeParkEntity';
  static const String _carParkEntity = 'carParkEntity';
  static const String _vehicleParkingWithEntrance =
      'vehicleParkingWithEntrance';

  factory PlaceEntity.fromJson(Map<String, dynamic> map) {
    return PlaceEntity(
      name: map[_name],
      vertexType: getVertexTypeByString(map[_vertexType]),
      lat: map[_lat],
      lon: map[_lon],
      arrivalTime:
          map[_arrivalTime] != null
              ? DateTime.fromMillisecondsSinceEpoch((map[_arrivalTime]))
              : null,
      departureTime:
          map[_departureTime] != null
              ? DateTime.fromMillisecondsSinceEpoch((map[_departureTime]))
              : null,
      stopEntity:
          map[_stopEntity] != null
              ? StopEntity.fromJson(map[_stopEntity] as Map<String, dynamic>)
              : null,
      bikeRentalStation:
          map[_bikeRentalStation] != null
              ? BikeRentalStationEntity.fromJson(
                map[_bikeRentalStation] as Map<String, dynamic>,
              )
              : null,
      bikeParkEntity:
          map[_bikeParkEntity] != null
              ? BikeParkEntity.fromJson(
                map[_bikeParkEntity] as Map<String, dynamic>,
              )
              : null,
      carParkEntity:
          map[_carParkEntity] != null
              ? CarParkEntity.fromJson(
                map[_carParkEntity] as Map<String, dynamic>,
              )
              : null,
      vehicleParkingWithEntrance:
          map[_vehicleParkingWithEntrance] != null
              ? VehicleParkingWithEntranceEntity.fromMap(
                map[_vehicleParkingWithEntrance] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _name: name,
      _vertexType: vertexType.name,
      _lat: lat,
      _lon: lon,
      _arrivalTime: arrivalTime?.millisecondsSinceEpoch,
      _departureTime: departureTime?.millisecondsSinceEpoch,
      _stopEntity: stopEntity?.toJson(),
      _bikeRentalStation: bikeRentalStation?.toJson(),
      _bikeParkEntity: bikeParkEntity?.toJson(),
      _carParkEntity: carParkEntity?.toJson(),
      _vehicleParkingWithEntrance: vehicleParkingWithEntrance?.toMap(),
    };
  }
}
