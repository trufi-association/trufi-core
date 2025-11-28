import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/localization/app_localization.dart';
import 'package:trufi_core/repositories/location/models/defaults_location.dart';

enum TrufiLocationType {
  /// Origin location for a route
  origin('origin_location'),

  /// Destination location for a route
  destination('destination_location'),

  /// Location selected directly on the map
  selectedOnMap('selected_on_map'),

  /// Current GPS location
  currentLocation('current_location'),

  /// Location from search results (Photon, etc.)
  searchResult('search_result'),

  /// Default saved location (home, work, etc.)
  defaultLocation('default_location'),

  /// Custom saved place
  customPlace('custom_place'),

  /// Location from OpenStreetMap data
  osmLocation('osm_location'),

  /// Unknown or unspecified type
  unknown('unknown');

  const TrufiLocationType(this.value);
  final String value;

  static TrufiLocationType fromString(String? value) {
    if (value == null) return TrufiLocationType.unknown;
    return TrufiLocationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrufiLocationType.unknown,
    );
  }
}

class TrufiLocation {
  final String description;
  final latlng.LatLng position;
  final List<String>? alternativeNames;
  final Map<String, String>? localizedNames;
  final String? address;
  final TrufiLocationType type;

  TrufiLocation({
    required this.description,
    required this.position,
    this.alternativeNames,
    this.localizedNames,
    this.address,
    this.type = TrufiLocationType.unknown,
  });

  TrufiLocation copyWith({
    String? description,
    latlng.LatLng? position,
    List<String>? alternativeNames,
    Map<String, String>? localizedNames,
    String? address,
    TrufiLocationType? type,
  }) {
    return TrufiLocation(
      description: description ?? this.description,
      position: position ?? this.position,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      localizedNames: localizedNames ?? this.localizedNames,
      address: address ?? this.address,
      type: type ?? this.type,
    );
  }

  factory TrufiLocation.fromLocationsJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['name'],
      position: latlng.LatLng(json['coords']['lat'], json['coords']['lng']),
    );
  }

  factory TrufiLocation.fromSearchPlacesJson(List<dynamic> json) {
    return TrufiLocation(
      description: json[0].toString(),
      alternativeNames: json[1].cast<String>() as List<String>?,
      localizedNames: json[2].cast<String, String>() as Map<String, String>?,
      position: latlng.LatLng(json[3][1], json[3][0]),
      address: json[4] as String?,
      type: TrufiLocationType.fromString(json[5] as String?),
    );
  }

  factory TrufiLocation.fromSearch(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'] as String,
      position: latlng.LatLng(json["latitude"], json["longitude"]),
    );
  }

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'] as String,
      position: latlng.LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      type: TrufiLocationType.fromString(json['type'] as String?),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'description': description,
    'latitude': position.latitude,
    'longitude': position.longitude,
    'type': type.value,
    'address': address ?? '',
  };

  String displayName(AppLocalization localization) {
    // Solo mostrar "Selected on map" si el tipo es específicamente 'selectedOnMap'
    // y la descripción está vacía
    if (type == TrufiLocationType.selectedOnMap && description.isEmpty) {
      return localization.translate(LocalizationKey.selectedOnMap);
    }

    // Si hay descripción, usarla (incluso si está vacía pero no es selectedOnMap)
    if (description.isNotEmpty) {
      final detected = DefaultLocationExt.detect(this);
      if (detected != null) {
        final base = localization.translate(detected.l10nKey);
        return isLatLngDefined
            ? base
            : localization.translateWithParams(
                '${LocalizationKey.defaultLocationAdd.key}:$base',
              );
      }
      return [description, if (address?.isNotEmpty ?? false) address].join(', ');
    }

    // Fallback: si no hay descripción y no es selectedOnMap, mostrar coordenadas
    return "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";
  }

  @override
  bool operator ==(Object other) =>
      other is TrufiLocation &&
      other.description == description &&
      other.position.latitude == position.latitude &&
      other.position.longitude == position.longitude &&
      other.type == type;

  @override
  int get hashCode =>
      Object.hash(description, position.latitude, position.longitude, type);

  @override
  String toString() => '${position.latitude},${position.longitude}';

  bool get isLatLngDefined => position.latitude != 0 && position.longitude != 0;

  String get subTitle => address != null && address!.isNotEmpty
      ? address!
      : "${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}";
}
