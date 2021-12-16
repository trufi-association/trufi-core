part of 'plan_entity.dart';

class PlanLocation {
  PlanLocation({
    this.name,
    this.latitude,
    this.longitude,
  });

  static const String _name = "name";
  static const String _latitude = "lat";
  static const String _longitude = "lon";

  final String? name;
  final double? latitude;
  final double? longitude;

  factory PlanLocation.fromJson(Map<String, dynamic> json) {
    return PlanLocation(
      name: json[_name] as String?,
      latitude: json[_latitude] as double?,
      longitude: json[_longitude] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _name: name,
      _latitude: latitude,
      _longitude: longitude,
    };
  }

  factory PlanLocation.fromTrufiLocation(TrufiLocation trufiLocation) {
    return PlanLocation(
      name: trufiLocation.description,
      latitude: trufiLocation.latitude,
      longitude: trufiLocation.longitude,
    );
  }
}
