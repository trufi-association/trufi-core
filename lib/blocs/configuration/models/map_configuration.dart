import 'package:latlong/latlong.dart';

// TODO: Add some documentation that makes sense
// -> Why do we need NorthEast, SouthWest and Center
// -> Why do we need so many zoom levels
class MapConfiguration {
  /// Default Zoom level of the map on start
  double defaultZoom;

  /// Offline Zoom level of the map on start
  double offlineZoom;

  /// Offline Minimal Zoom
  double offlineMinZoom;

  /// Offline Maximal Zoom
  double offlineMaxZoom;

  /// Online Minimal Zoom
  double onlineMinZoom;

  /// Online Maximal Zoom Level
  double onlineMaxZoom;

  /// Online Default Zoom
  double onlineZoom;

  /// Choose Location Zoom
  double chooseLocationZoom;

  /// Center of the map
  LatLng center = LatLng(5.574558, -0.214656);

  /// SouthWest of the map
  LatLng southWest = LatLng(5.510057, -0.328217);

  /// NorthEast of the map
  LatLng northEast = LatLng(5.726678, 0.071411);

  MapConfiguration({
    this.defaultZoom = 12.0,
    this.offlineZoom = 13.0,
    this.offlineMinZoom = 8.0,
    this.offlineMaxZoom = 14.0,
    this.onlineMinZoom = 1.0,
    this.onlineMaxZoom = 19.0,
    this.onlineZoom = 13.0,
    this.chooseLocationZoom = 16.0,
    this.center,
    this.southWest,
    this.northEast,
  });
}
