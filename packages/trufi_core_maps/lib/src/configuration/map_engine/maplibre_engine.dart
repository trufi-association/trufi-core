import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/controller/map_controller.dart';
import '../../domain/entities/camera.dart';
import '../../domain/entities/widget_marker.dart';
import '../../domain/layers/trufi_layer.dart';
import '../../presentation/map/trufi_map.dart';
import 'trufi_map_engine.dart';

/// MapLibre GL engine implementation.
///
/// Provides vector map rendering with modern styling and better performance.
///
/// Example:
/// ```dart
/// MapLibreEngine(
///   engineId: 'maplibre_liberty',
///   styleString: 'https://tiles.openfreemap.org/styles/liberty',
///   displayName: 'Liberty',
/// )
/// ```
class MapLibreEngine implements ITrufiMapEngine {
  final String styleString;
  final String? engineId;
  final String? displayName;
  final String? displayDescription;
  final Widget? preview;

  const MapLibreEngine({
    required this.styleString,
    this.engineId,
    this.displayName,
    this.displayDescription,
    this.preview,
  });

  @override
  String get id => engineId ?? 'maplibre';

  @override
  String get name => displayName ?? 'Vector (MapLibre)';

  @override
  String get description =>
      displayDescription ??
      'Vector map with modern styling and better performance';

  @override
  Widget? get previewWidget =>
      preview ??
      Container(
        color: Colors.blue.shade100,
        child: const Center(
          child: Icon(Icons.map, size: 40, color: Colors.blue),
        ),
      );

  @override
  Future<void> initialize() async {}

  @override
  Widget buildMap({
    TrufiMapController? controller,
    required TrufiCameraPosition initialCamera,
    TrufiCameraPosition? camera,
    ValueChanged<TrufiCameraPosition>? onCameraChanged,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
    List<TrufiLayer> layers = const [],
    List<WidgetMarker> widgetMarkers = const [],
  }) {
    return TrufiMap(
      key: ValueKey(id),
      controller: controller,
      initialCamera: initialCamera,
      camera: camera,
      styleString: styleString,
      onCameraChanged: onCameraChanged,
      onMapClick: onMapClick,
      onMapLongClick: onMapLongClick,
      layers: layers,
      widgetMarkers: widgetMarkers,
    );
  }
}
