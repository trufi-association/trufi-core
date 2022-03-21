part of 'map_configuration_cubit.dart';

class MapConfiguration {
  /// Default Zoom level of the map on start
  final double defaultZoom;

  /// Online Minimal Zoom
  final double onlineMinZoom;

  /// Online Maximal Zoom Level
  final double onlineMaxZoom;

  /// Online Default Zoom
  final double onlineZoom;

  /// Choose Location Zoom
  final double chooseLocationZoom;

  /// Center of the map
  final LatLng center;

  /// This widgetBuilder creates the Attribution Texts on top of the map
  WidgetBuilder? mapAttributionBuilder;

  /// To, From and yourLocation Marker
  final MarkerConfiguration markersConfiguration;

  // /// Itinerari creator configuration
  // final ItinararyCreator itinararyCreator;

  MapConfiguration({
    required this.center,
    this.defaultZoom = 12.0,
    this.onlineMinZoom = 2.0,
    this.onlineMaxZoom = 18.0,
    this.onlineZoom = 13.0,
    this.chooseLocationZoom = 16.0,
    this.mapAttributionBuilder,
    this.markersConfiguration = const DefaultMarkerConfiguration(),
    // this.itinararyCreator = const DefaultItineraryCreator(),
  }) {
    mapAttributionBuilder =
        mapAttributionBuilder ?? (context) => const MapTileAndOSMCopyright();
  }
}
