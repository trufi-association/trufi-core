import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/widgets/map/map_copyright.dart';

// TODO: Add some documentation that makes sense
// -> Why do we need NorthEast, SouthWest and Center
// -> Why do we need so many zoom levels
class MapConfiguration {
  /// Default Zoom level of the map on start
  final double defaultZoom;

  /// Offline Zoom level of the map on start
  final double offlineZoom;

  /// Offline Minimal Zoom
  final double offlineMinZoom;

  /// Offline Maximal Zoom
  final double offlineMaxZoom;

  /// Online Minimal Zoom
  final double onlineMinZoom;

  /// Online Maximal Zoom Level
  final double onlineMaxZoom;

  /// Online Default Zoom
  final double onlineZoom;

  /// Choose Location Zoom
  final double chooseLocationZoom;

  /// Center of the map
  LatLng center;

  /// SouthWest of the map
  LatLng southWest;

  /// NorthEast of the map
  LatLng northEast;

  /// This widgetBuilder creates the Attribution Texts on top of the map
  WidgetBuilder mapAttributionBuilder;

  MapConfiguration({
    this.defaultZoom = 12.0,
    this.offlineZoom = 13.0,
    this.offlineMinZoom = 8.0,
    this.offlineMaxZoom = 14.0,
    this.onlineMinZoom = 1.0,
    this.onlineMaxZoom = 19.0,
    this.onlineZoom = 13.0,
    this.chooseLocationZoom = 15.0,
    this.center,
    this.southWest,
    this.northEast,
    this.mapAttributionBuilder,
  }) {
    mapAttributionBuilder = mapAttributionBuilder ??
        (context) {
          return MapTileAndOSMCopyright();
        };
    center = center ?? LatLng(5.574558, -0.214656);
    southWest = southWest ?? LatLng(5.510057, -0.328217);
    northEast = northEast ?? LatLng(5.726678, 0.071411);
  }
}
