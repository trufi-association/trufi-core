part of 'plan.dart';

class Place extends Equatable {
  static const _name = 'name';
  static const _lat = 'lat';
  static const _lon = 'lon';

  final String name;
  final double lat;
  final double lon;

  const Place({
    this.name = 'Not name',
    required this.lat,
    required this.lon,
  });

  Map<String, dynamic> toJson() {
    return {
      _name: name,
      _lat: lat,
      _lon: lon,
    };
  }

  factory Place.fromJson(Map<String, dynamic> map) {
    return Place(
      name: map[_name] as String,
      lat: map[_lat] as double,
      lon: map[_lon] as double,
    );
  }

  Place copyWith({
    String? name,
    double? lat,
    double? lon,
  }) {
    return Place(
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  List<Object?> get props => [
        name,
        lat,
        lon,
      ];
}
