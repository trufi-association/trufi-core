import 'package:trufi_core/models/elevation_profile_component.dart';

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

  ElevationProfileComponentEntity toElevationProfileComponentEntity() {
    return ElevationProfileComponentEntity(
      distance: distance,
      elevation: elevation,
    );
  }
}
