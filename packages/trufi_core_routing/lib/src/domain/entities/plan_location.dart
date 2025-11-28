import 'package:latlong2/latlong.dart';

/// A location in a trip plan (origin or destination).
class PlanLocation {
  const PlanLocation({
    this.name,
    this.latitude,
    this.longitude,
  });

  final String? name;
  final double? latitude;
  final double? longitude;

  /// Creates a [PlanLocation] from JSON.
  factory PlanLocation.fromJson(Map<String, dynamic> json) {
    return PlanLocation(
      name: json['name'] as String?,
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lon'] as num?)?.toDouble(),
    );
  }

  /// Converts this location to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': latitude,
      'lon': longitude,
    };
  }

  /// Returns a [LatLng] if both latitude and longitude are available.
  LatLng? get latLng {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is PlanLocation &&
      other.name == name &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(name, latitude, longitude);
}
