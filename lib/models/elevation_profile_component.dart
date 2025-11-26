class ElevationProfileComponentEntity {
  final double? distance;
  final double? elevation;

  const ElevationProfileComponentEntity({this.distance, this.elevation});

  static const String _distance = 'distance';
  static const String _elevation = 'elevation';

  factory ElevationProfileComponentEntity.fromJson(Map<String, dynamic> json) =>
      ElevationProfileComponentEntity(
        distance: json[_distance],
        elevation: json[_elevation],
      );

  Map<String, dynamic> toJson() => {_distance: distance, _elevation: elevation};
}
