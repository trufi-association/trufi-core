class ElevationProfileComponent {
  final double? distance;
  final double? elevation;

  const ElevationProfileComponent({this.distance, this.elevation});

  factory ElevationProfileComponent.fromJson(Map<String, dynamic> json) =>
      ElevationProfileComponent(
        distance: double.tryParse(json['distance'].toString()) ?? 0,
        elevation: double.tryParse(json['elevation'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'elevation': elevation,
      };
}
