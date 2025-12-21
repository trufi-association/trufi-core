/// Configuration for POI layers
class POILayerConfig {
  /// Base path for POI GeoJSON assets
  final String assetsBasePath;

  /// Minimum zoom level to show POIs
  final int minZoom;

  /// Marker size in pixels
  final double markerSize;

  const POILayerConfig({
    required this.assetsBasePath,
    this.minZoom = 14,
    this.markerSize = 32,
  });
}
