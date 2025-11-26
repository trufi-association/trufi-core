part of 'plan_entity.dart';

class CarParkEntity {
  final String? id;
  final String? carParkId;
  final String? name;
  final int? maxCapacity;
  final int? spacesAvailable;
  final bool? realtime;
  final double? lon;
  final double? lat;

  const CarParkEntity({
    this.id,
    this.carParkId,
    this.name,
    this.maxCapacity,
    this.spacesAvailable,
    this.realtime,
    this.lon,
    this.lat,
  });

  static const String _id = 'id';
  static const String _carParkId = 'carParkId';
  static const String _name = 'name';
  static const String _maxCapacity = 'maxCapacity';
  static const String _spacesAvailable = 'spacesAvailable';
  static const String _realtime = 'realtime';
  static const String _lon = 'lon';
  static const String _lat = 'lat';

  factory CarParkEntity.fromJson(Map<String, dynamic> map) {
    return CarParkEntity(
      id: map[_id],
      carParkId: map[_carParkId],
      name: map[_name],
      maxCapacity: map[_maxCapacity],
      spacesAvailable: map[_spacesAvailable],
      realtime: map[_realtime],
      lon: map[_lon],
      lat: map[_lat],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _id: id,
      _carParkId: carParkId,
      _name: name,
      _maxCapacity: maxCapacity,
      _spacesAvailable: spacesAvailable,
      _realtime: realtime,
      _lon: lon,
      _lat: lat,
    };
  }
}
