import 'package:latlong2/latlong.dart';

/// A location used for route planning requests.
class RoutingLocation {
  const RoutingLocation({
    required this.position,
    required this.description,
    this.address,
  });

  final LatLng position;
  final String description;
  final String? address;

  /// Converts to OTP location format.
  Map<String, dynamic> toOtpLocation() {
    return {
      'coordinates': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'name': description,
    };
  }

  /// Creates a [RoutingLocation] from JSON.
  factory RoutingLocation.fromJson(Map<String, dynamic> json) {
    return RoutingLocation(
      position: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      description: json['description'] as String,
      address: json['address'] as String?,
    );
  }

  /// Converts this location to JSON.
  Map<String, dynamic> toJson() {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'description': description,
      'address': address,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is RoutingLocation &&
      other.position.latitude == position.latitude &&
      other.position.longitude == position.longitude;

  @override
  int get hashCode => Object.hash(position.latitude, position.longitude);

  @override
  String toString() => '${position.latitude},${position.longitude}';
}
