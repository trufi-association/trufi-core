import 'package:trufi_core/models/enums/absolute_direction.dart';
import 'package:trufi_core/models/enums/relative_direction.dart';
import 'package:trufi_core/models/elevation_profile_component.dart';

class StepEntity {
  final double? distance;
  final double? lon;
  final double? lat;
  final List<ElevationProfileComponentEntity>? elevationProfile;
  final RelativeDirectionTrufi? relativeDirection;
  final AbsoluteDirectionTrufi? absoluteDirection;
  final String? streetName;
  final String? exit;
  final bool? stayOn;
  final bool? area;
  final bool? bogusName;
  final bool? walkingBike;

  const StepEntity({
    this.distance,
    this.lon,
    this.lat,
    this.elevationProfile,
    this.relativeDirection,
    this.absoluteDirection,
    this.streetName,
    this.exit,
    this.stayOn,
    this.area,
    this.bogusName,
    this.walkingBike,
  });

  static const String _distance = 'distance';
  static const String _lon = 'lon';
  static const String _lat = 'lat';
  static const String _elevationProfile = 'elevationProfile';
  static const String _relativeDirection = 'relativeDirection';
  static const String _absoluteDirection = 'absoluteDirection';
  static const String _streetName = 'streetName';
  static const String _exit = 'exit';
  static const String _stayOn = 'stayOn';
  static const String _area = 'area';
  static const String _bogusName = 'bogusName';
  static const String _walkingBike = 'walkingBike';

  factory StepEntity.fromJson(Map<String, dynamic> json) => StepEntity(
    distance: json[_distance],
    lon: json[_lon],
    lat: json[_lat],
    relativeDirection:
        json[_relativeDirection] != null
            ? getRelativeDirectionByString(json[_relativeDirection])
            : null,
    absoluteDirection:
        json[_absoluteDirection] != null
            ? getAbsoluteDirectionByString(json[_absoluteDirection])
            : null,
    streetName: json[_streetName],
    exit: json[_exit],
    stayOn: json[_stayOn],
    area: json[_area],
    bogusName: json[_bogusName],
    walkingBike: json[_walkingBike],
  );

  Map<String, dynamic> toMap() => {
    _distance: distance,
    _lon: lon,
    _lat: lat,
    _elevationProfile: List<dynamic>.from(
      (elevationProfile ?? []).map((x) => x.toJson()),
    ),
    _relativeDirection: relativeDirection?.name,
    _absoluteDirection: absoluteDirection?.name,
    _streetName: streetName,
    _exit: exit,
    _stayOn: stayOn,
    _area: area,
    _bogusName: bogusName,
    _walkingBike: walkingBike,
  };
}
