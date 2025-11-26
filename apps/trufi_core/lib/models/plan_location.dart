part of 'plan_entity.dart';

class PlanLocation {
  const PlanLocation({this.name, this.latitude, this.longitude});

  static const String _name = "name";
  static const String _latitude = "lat";
  static const String _longitude = "lon";

  final String? name;
  final double? latitude;
  final double? longitude;

  factory PlanLocation.fromJson(Map<String, dynamic> json) {
    return PlanLocation(
      name: json[_name],
      latitude: json[_latitude],
      longitude: json[_longitude],
    );
  }

  Map<String, dynamic> toJson() {
    return {_name: name, _latitude: latitude, _longitude: longitude};
  }
}
