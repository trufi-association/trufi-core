import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/controller/map_controller.dart';
import '../../domain/entities/camera.dart';
import '../../domain/entities/widget_marker.dart';
import '../../domain/layers/trufi_layer.dart';
import '../../presentation/widgets/map_type_option.dart';

/// Interface for map engines.
///
/// Implement this interface to create custom map engines that can be
/// used with MapTypeButton and other map selection widgets.
abstract class ITrufiMapEngine {
  /// Unique identifier for this engine.
  String get id;

  /// Display name shown in UI selectors.
  String get name;

  /// Description shown in map type selection screen.
  String get description;

  /// Optional preview widget for the map type selector.
  Widget? get previewWidget => null;

  /// Initialize the engine.
  Future<void> initialize() async {}

  /// Build the map widget with the declarative API.
  Widget buildMap({
    TrufiMapController? controller,
    required TrufiCameraPosition initialCamera,
    TrufiCameraPosition? camera,
    ValueChanged<TrufiCameraPosition>? onCameraChanged,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
    List<TrufiLayer> layers,
    List<WidgetMarker> widgetMarkers,
  });
}

/// Extension methods for ITrufiMapEngine.
extension TrufiMapEngineExtension on ITrufiMapEngine {
  /// Converts this engine to a MapTypeOption for use with MapTypeButton.
  MapTypeOption toMapTypeOption() {
    final isOffline = runtimeType.toString().contains('Offline');
    return MapTypeOption(
      id: id,
      name: name,
      description: description,
      previewImage: previewWidget,
      isOffline: isOffline,
    );
  }
}

/// Extension to convert a list of engines to MapTypeOptions.
extension MapEngineListExtension on List<ITrufiMapEngine> {
  List<MapTypeOption> toMapTypeOptions() {
    return map((e) => e.toMapTypeOption()).toList();
  }
}
