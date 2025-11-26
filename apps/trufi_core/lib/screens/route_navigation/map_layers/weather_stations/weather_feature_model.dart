import 'package:latlong2/latlong.dart';
import 'package:vector_tile/vector_tile.dart';

class WeatherFeature {
  final String address;
  final String? airTemperatureC;
  final String? airPressureRelhPa;
  final String? moisturePercentage;
  final String? roadTemperatureC;
  final String? precipitationType;
  final String? roadCondition;
  final String? icePercentage;
  final String? updatedAt;

  final LatLng position;

  WeatherFeature({
    required this.address,
    required this.airTemperatureC,
    required this.airPressureRelhPa,
    required this.moisturePercentage,
    required this.roadTemperatureC,
    required this.precipitationType,
    required this.roadCondition,
    required this.icePercentage,
    required this.updatedAt,
    required this.position,
  });

  static WeatherFeature? fromGeoJsonPoint(GeoJsonPoint? geoJsonPoint) {
    if (geoJsonPoint?.properties == null || geoJsonPoint?.geometry?.coordinates == null) return null;
    final properties = geoJsonPoint!.properties ?? <String, VectorTileValue>{};

    String getString(String key) => properties[key]?.dartStringValue ?? '';
    String? getIntAsString(String key) => properties[key]?.dartIntValue?.toString();

    return WeatherFeature(
      address: getString('address'),
      airTemperatureC: getIntAsString('airTemperatureC'),
      airPressureRelhPa: getIntAsString('airPressureRelhPa'),
      moisturePercentage: getIntAsString('moisturePercentage'),
      roadTemperatureC: getIntAsString('roadTemperatureC'),
      precipitationType: getIntAsString('precipitationType'),
      roadCondition: getIntAsString('roadCondition'),
      icePercentage: getIntAsString('icePercentage'),
      updatedAt: getString('updatedAt'),
      position: LatLng(
        geoJsonPoint.geometry!.coordinates[1],
        geoJsonPoint.geometry!.coordinates[0],
      ),
    );
  }
}
