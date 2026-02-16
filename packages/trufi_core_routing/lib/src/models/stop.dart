import 'package:latlong2/latlong.dart';

/// Represents a transit stop from OTP.
class Stop {
  final String name;
  final double lat;
  final double lon;

  const Stop({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        name: json['name'] as String,
        lat: double.tryParse(json['lat'].toString()) ?? 0,
        lon: double.tryParse(json['lon'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lon': lon,
      };

  LatLng toLatLng() => LatLng(lat, lon);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stop &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lat == other.lat &&
          lon == other.lon;

  @override
  int get hashCode => name.hashCode ^ lat.hashCode ^ lon.hashCode;
}
