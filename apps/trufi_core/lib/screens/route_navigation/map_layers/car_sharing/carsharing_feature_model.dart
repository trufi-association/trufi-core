import 'package:latlong2/latlong.dart';
import 'package:trufi_core/configuration/config_default/config_default.dart';
import 'package:trufi_core/configuration/config_default/config_default/city_bike_config.dart';
import 'package:vector_tile/vector_tile.dart';

class CarSharingFeature {
  final GeoJsonPoint? geoJsonPoint;
  final String id;
  final String? networkId;
  final NetworkConfig? network;
  final String? name;
  final String? formFactors;
  final int? vehiclesAvailable;
  final int? spacesAvailable;
  final bool? operative;

  final LatLng position;
  CarSharingFeature({
    required this.geoJsonPoint,
    required this.id,
    required this.networkId,
    required this.network,
    required this.name,
    required this.formFactors,
    required this.vehiclesAvailable,
    required this.spacesAvailable,
    required this.operative,
    required this.position,
  });
  static CarSharingFeature? fromGeoJsonPoint(GeoJsonPoint? geoJsonPoint) {
    if (geoJsonPoint?.properties == null) return null;
    final properties = geoJsonPoint?.properties ?? <String, VectorTileValue>{};
    String? id = properties['id']?.dartStringValue;
    if (id == null) return null;
    String? networkId = properties['network']?.dartStringValue;
    NetworkConfig? network = ConfigDefault.value.cityBike.networks?[networkId];
    String? name = properties['name']?.dartStringValue;
    String? formFactors = properties['formFactors']?.dartStringValue;
    int? vehiclesAvailable =
        properties['vehiclesAvailable']?.dartIntValue?.toInt();
    int? spacesAvailable = properties['spacesAvailable']?.dartIntValue?.toInt();
    bool? operative = properties['operative']?.dartBoolValue;
    return CarSharingFeature(
      geoJsonPoint: geoJsonPoint,
      id: id,
      networkId: networkId,
      network: network,
      name: name,
      formFactors: formFactors,
      vehiclesAvailable: vehiclesAvailable,
      spacesAvailable: spacesAvailable,
      operative: operative,
      position: LatLng(
        geoJsonPoint?.geometry?.coordinates[1] ?? 0,
        geoJsonPoint?.geometry?.coordinates[0] ?? 0,
      ),
    );
  }
}
