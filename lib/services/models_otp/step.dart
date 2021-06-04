import 'elevation_profile_component.dart';

class Step {
  final double distance;
  final double lon;
  final double lat;
  final List<ElevationProfileComponent> elevationProfile;

  const Step({
    this.distance,
    this.lon,
    this.lat,
    this.elevationProfile,
  });

  factory Step.fromJson(Map<String, dynamic> json) => Step(
        distance: double.tryParse(json['distance'].toString()) ?? 0,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
        lat: double.tryParse(json['lat'].toString()) ?? 0,
        elevationProfile: json['elevationProfile'] != null
            ? List<ElevationProfileComponent>.from(
                (json["elevationProfile"] as List<dynamic>).map((x) =>
                    ElevationProfileComponent.fromJson(
                        x as Map<String, dynamic>)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'lon': lon,
        'lat': lat,
        'elevationProfile':
            List<dynamic>.from(elevationProfile.map((x) => x.toJson())),
      };
}
