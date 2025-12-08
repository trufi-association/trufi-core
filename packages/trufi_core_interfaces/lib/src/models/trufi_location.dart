import 'trufi_latlng.dart';

/// Interface for a geographic location with description.
abstract class ITrufiLocation {
  String get description;
  double get latitude;
  double get longitude;
  String? get address;
  String? get type;
}

/// Interface for location detail returned from location selection.
abstract class ILocationDetail {
  String get description;
  String get street;
  TrufiLatLng get position;
}

/// Basic implementation of ILocationDetail.
class LocationDetail implements ILocationDetail {
  @override
  final String description;
  @override
  final String street;
  @override
  final TrufiLatLng position;

  /// Creates a LocationDetail with positional arguments for backward compatibility.
  const LocationDetail(this.description, this.street, this.position);

  /// Creates a LocationDetail with named arguments.
  const LocationDetail.named({
    required this.description,
    required this.street,
    required this.position,
  });
}
