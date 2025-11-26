import 'package:trufi_core/models/step_entity.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_stadtnavi/grapqhql_queries/otp_stadtnavi_models/enums/absolute_direction.dart';
import 'package:trufi_core/pages/home/service/routing_service/otp_stadtnavi/grapqhql_queries/otp_stadtnavi_models/enums/relative_direction.dart';

import 'elevation_profile_component.dart';

class Step {
  final double? distance;
  final double? lon;
  final double? lat;
  final List<ElevationProfileComponent>? elevationProfile;
  final RelativeDirection? relativeDirection;
  final AbsoluteDirection? absoluteDirection;
  final String? streetName;
  final String? exit;
  final bool? stayOn;
  final bool? area;
  final bool? bogusName;
  final bool? walkingBike;

  const Step({
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

  factory Step.fromJson(Map<String, dynamic> json) => Step(
    distance: double.tryParse(json['distance'].toString()) ?? 0,
    lon: double.tryParse(json['lon'].toString()) ?? 0,
    lat: double.tryParse(json['lat'].toString()) ?? 0,
    elevationProfile: json['elevationProfile'] != null
        ? List<ElevationProfileComponent>.from(
            (json["elevationProfile"] as List<dynamic>).map(
              (x) =>
                  ElevationProfileComponent.fromJson(x as Map<String, dynamic>),
            ),
          )
        : null,
    relativeDirection: json['relativeDirection'] != null
        ? getRelativeDirectionByString(json['relativeDirection'])
        : null,
    absoluteDirection: json['absoluteDirection'] != null
        ? getAbsoluteDirectionByString(json['absoluteDirection'])
        : null,
    streetName: json['streetName'],
    exit: json['exit'],
    stayOn: json['stayOn'],
    area: json['area'],
    bogusName: json['bogusName'],
    walkingBike: json['walkingBike'],
  );

  Map<String, dynamic> toJson() => {
    'distance': distance,
    'lon': lon,
    'lat': lat,
    'elevationProfile': List<dynamic>.from(
      (elevationProfile ?? []).map((x) => x.toJson()),
    ),
    'relativeDirection': relativeDirection,
    'absoluteDirection': absoluteDirection,
    'streetName': streetName,
    'exit': exit,
    'stayOn': stayOn,
    'area': area,
    'bogusName': bogusName,
    'walkingBike': walkingBike,
  };

  StepEntity toStepEntity() {
    return StepEntity(
      distance: distance,
      lon: lon,
      lat: lat,
      elevationProfile: elevationProfile
          ?.map((e) => e.toElevationProfileComponentEntity())
          .toList(),
      relativeDirection: relativeDirection?.toRelativeDirection(),
      absoluteDirection: absoluteDirection?.toRealtimeState(),
      streetName: streetName,
      exit: exit,
      stayOn: stayOn,
      area: area,
      bogusName: bogusName,
      walkingBike: walkingBike,
    );
  }
}
