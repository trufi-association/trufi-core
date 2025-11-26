class CoordinatesEntity {
  final double? lat;
  final double? lon;

  const CoordinatesEntity({this.lat, this.lon});

  static const String _lat = 'lat';
  static const String _lon = 'lon';

  factory CoordinatesEntity.fromJson(Map<String, dynamic> json) =>
      CoordinatesEntity(lat: json[_lat], lon: json[_lon]);

  Map<String, dynamic> toJson() => {_lat: lat, _lon: lon};
}
