part of 'plan_entity.dart';

class BikeParkEntity {
  final String? id;
  final String? bikeParkId;
  final String? name;
  final int? spacesAvailable;
  final bool? realtime;
  final double? lon;
  final double? lat;

  const BikeParkEntity({
    this.id,
    this.bikeParkId,
    this.name,
    this.spacesAvailable,
    this.realtime,
    this.lon,
    this.lat,
  });

  static const String _id = 'id';
  static const String _bikeParkId = 'bikeParkId';
  static const String _name = 'name';
  static const String _spacesAvailable = 'spacesAvailable';
  static const String _realtime = 'realtime';
  static const String _lon = 'lon';
  static const String _lat = 'lat';

  factory BikeParkEntity.fromJson(Map<String, dynamic> map) {
    return BikeParkEntity(
      id: map[_id],
      bikeParkId: map[_bikeParkId],
      name: map[_name],
      spacesAvailable: map[_spacesAvailable],
      realtime: map[_realtime],
      lon: map[_lon],
      lat: map[_lat],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _id: id,
      _bikeParkId: bikeParkId,
      _name: name,
      _spacesAvailable: spacesAvailable,
      _realtime: realtime,
      _lon: lon,
      _lat: lat,
    };
  }
}
