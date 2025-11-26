import 'package:latlong2/latlong.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class LocationSearchResponse {
  const LocationSearchResponse({
    this.type,
    this.name,
    this.street,
    this.latLng,
  });

  final String? type;
  final String? name;
  final String? street;
  final LatLng? latLng;

  String get getCode => "$type $name $street";

  factory LocationSearchResponse.fromJson(Map<String, dynamic> json) {
    final List coords = json["geometry"]["coordinates"];
    final dynamic properties = json["properties"];
    final String? county = properties["county"];
    final String? street = properties["street"];
    final String? locality = properties["locality"];
    final streetAll = <String>[
      if (county != null) county,
      if (street != null) street,
      if (locality != null) locality,
    ];

    final String? osmKey = properties["osm_key"]?.toString();
    final String? osmValue = properties["osm_value"]?.toString();
    final String? photonType = properties["type"]?.toString();
    final String? normalizedType = (osmKey != null && osmValue != null)
        ? "${osmKey.toLowerCase()}:${osmValue.toLowerCase()}"
        : photonType?.toLowerCase();
    return LocationSearchResponse(
      latLng: LatLng(coords[1], coords[0]),
      type: normalizedType,
      name: properties["name"],
      street: streetAll.join(", "),
    );
  }

  TrufiLocation toTrufiLocation() {
    return TrufiLocation(
      description: name ?? 'Not description',
      position: latLng ?? LatLng(0, 0),
      address: street,
      type: TrufiLocationType.fromString(type),
    );
  }
}
