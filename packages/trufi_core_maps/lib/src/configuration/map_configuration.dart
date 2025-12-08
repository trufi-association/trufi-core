import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import 'marker_configuration.dart';
import 'map_copyright.dart';

/// Configuration for map display settings.
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
  final TrufiLatLng center;

  /// This widgetBuilder creates the Attribution Texts on top of the map
  WidgetBuilder? mapAttributionBuilder;

  /// To, From and yourLocation Marker
  final MarkerConfiguration markersConfiguration;

  /// Link for report error in searches
  final String? feedbackForm;

  MapConfiguration({
    required this.center,
    this.defaultZoom = 12.0,
    this.onlineMinZoom = 2.0,
    this.onlineMaxZoom = 18.0,
    this.onlineZoom = 13.0,
    this.chooseLocationZoom = 16.0,
    this.mapAttributionBuilder,
    this.markersConfiguration = const DefaultMarkerConfiguration(),
    this.feedbackForm,
  }) {
    mapAttributionBuilder =
        mapAttributionBuilder ?? (context) => const MapTileAndOSMCopyright();
  }
}

/// Cubit for managing map configuration state.
class MapConfigurationCubit extends Cubit<MapConfiguration> {
  MapConfigurationCubit(MapConfiguration initialState) : super(initialState);
}
