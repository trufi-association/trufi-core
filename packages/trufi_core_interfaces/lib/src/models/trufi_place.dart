import 'trufi_latlng.dart';
import 'trufi_location.dart';

/// Base marker interface for all place types.
abstract class TrufiPlace {}

/// A geographic location with full details.
class TrufiLocation implements TrufiPlace, ITrufiLocation {
  @override
  final String description;
  @override
  final double latitude;
  @override
  final double longitude;
  final List<String>? alternativeNames;
  final Map<String, String>? localizedNames;
  @override
  final String? address;
  @override
  final String? type;

  const TrufiLocation({
    required this.description,
    required this.latitude,
    required this.longitude,
    this.alternativeNames,
    this.localizedNames,
    this.address,
    this.type,
  });

  TrufiLocation copyWith({
    String? description,
    double? latitude,
    double? longitude,
    List<String>? alternativeNames,
    Map<String, String>? localizedNames,
    String? address,
    String? type,
  }) {
    return TrufiLocation(
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      localizedNames: localizedNames ?? this.localizedNames,
      address: address ?? this.address,
      type: type ?? this.type,
    );
  }

  factory TrufiLocation.fromLocationDetail(ILocationDetail locationDetail) {
    return TrufiLocation(
      description: locationDetail.description,
      address: locationDetail.street,
      latitude: locationDetail.position.latitude,
      longitude: locationDetail.position.longitude,
    );
  }

  /// Alias for fromLocationDetail for backward compatibility.
  factory TrufiLocation.fromChooseLocationDetail(
    LocationDetail chooseLocationDetail,
  ) {
    return TrufiLocation.fromLocationDetail(chooseLocationDetail);
  }

  factory TrufiLocation.fromLocationsJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['name'] as String,
      latitude: json['coords']['lat'] as double,
      longitude: json['coords']['lng'] as double,
    );
  }

  factory TrufiLocation.fromSearchPlacesJson(List<dynamic> json) {
    return TrufiLocation(
      description: json[0].toString(),
      alternativeNames: json[1].cast<String>() as List<String>?,
      localizedNames: json[2].cast<String, String>() as Map<String, String>?,
      longitude: json[3][0].toDouble() as double,
      latitude: json[3][1].toDouble() as double,
      address: json[4] as String?,
      type: json[5] as String?,
    );
  }

  factory TrufiLocation.fromSearch(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'] as String,
      latitude: json['lat'] as double,
      longitude: json['lng'] as double,
    );
  }

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json["description"] as String,
      latitude: json["latitude"] as double,
      longitude: json["longitude"] as double,
      type: json["type"] as String?,
      address: json["address"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "type": type,
      "address": address ?? '',
    };
  }

  @override
  bool operator ==(Object other) =>
      other is TrufiLocation &&
      other.description == description &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.type == type;

  @override
  int get hashCode =>
      description.hashCode ^ latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() {
    return '$latitude,$longitude';
  }

  static bool sameLocations(TrufiLatLng location1, TrufiLatLng location2) {
    return location1.latitude.toStringAsFixed(2) ==
            location2.latitude.toStringAsFixed(2) &&
        location1.longitude.toStringAsFixed(2) ==
            location2.longitude.toStringAsFixed(2);
  }

  static TrufiLatLng centerLocation(
    TrufiLatLng location1,
    TrufiLatLng location2,
  ) {
    return TrufiLatLng(
      (location1.latitude + location2.latitude) / 2,
      (location1.longitude + location2.longitude) / 2,
    );
  }

  bool get isLatLngDefined {
    return latitude != 0 && longitude != 0;
  }

  TrufiLatLng get latLng {
    return TrufiLatLng(latitude, longitude);
  }
}

/// A street with optional junctions.
class TrufiStreet implements TrufiPlace {
  TrufiStreet({required this.location});

  final TrufiLocation location;
  final List<TrufiStreetJunction> junctions = [];

  factory TrufiStreet.fromSearchJson(List<dynamic> json) {
    return TrufiStreet(
      location: TrufiLocation(
        description: json[0] as String,
        alternativeNames: json[1].cast<String>() as List<String>,
        longitude: json[2][0].toDouble() as double,
        latitude: json[2][1].toDouble() as double,
      ),
    );
  }

  String get description => location.description;
}

/// Junction of two streets.
class TrufiStreetJunction {
  TrufiStreetJunction({
    required this.street1,
    required this.street2,
    required this.latitude,
    required this.longitude,
  });

  final TrufiStreet street1;
  final TrufiStreet street2;
  final double latitude;
  final double longitude;

  String get description {
    return '${street1.location.description} & ${street2.location.description}';
  }
}

/// Helper class for Levenshtein distance sorting.
class LevenshteinObject<T> {
  LevenshteinObject(this.object, this.distance);

  final T object;
  final int distance;
}

/// Default location types.
enum DefaultLocation { defaultHome, defaultWork }

/// Extension for default location initialization.
extension DefaultLocationExtension on DefaultLocation {
  static final initLocations = <DefaultLocation, TrufiLocation>{
    DefaultLocation.defaultHome: TrufiLocation(
      description: keys[DefaultLocation.defaultHome] ?? 'ErrorDefaultLocation',
      latitude: 0,
      longitude: 0,
      type: 'saved_place:home',
    ),
    DefaultLocation.defaultWork: TrufiLocation(
      description: keys[DefaultLocation.defaultWork] ?? 'ErrorDefaultLocation',
      latitude: 0,
      longitude: 0,
      type: 'saved_place:work',
    ),
  };

  static final keys = <DefaultLocation, String>{
    DefaultLocation.defaultHome: 'Key-Default-Home',
    DefaultLocation.defaultWork: 'Key-Default-Work',
  };

  TrufiLocation get initLocation =>
      initLocations[this] ??
      TrufiLocation(
        description: keyLocation,
        latitude: 0,
        longitude: 0,
        type: 'saved_place:work',
      );

  String get keyLocation => keys[this] ?? 'Key-Default-Home';
}
