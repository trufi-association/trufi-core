import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/controller/map_controller.dart';
import '../../presentation/widgets/map_type_option.dart';

/// Interface for map engines.
///
/// Implement this interface to create custom map engines that can be
/// used with MapTypeButton and other map selection widgets.
///
/// Example implementation:
/// ```dart
/// class CustomEngine implements ITrufiMapEngine {
///   @override
///   String get id => 'custom';
///
///   @override
///   String get name => 'Custom Map';
///
///   @override
///   String get description => 'My custom map engine';
///
///   @override
///   Widget buildMap({...}) => MyCustomMapWidget(...);
/// }
/// ```
abstract class ITrufiMapEngine {
  /// Unique identifier for this engine.
  String get id;

  /// Display name shown in UI selectors.
  String get name;

  /// Description shown in map type selection screen.
  String get description;

  /// Optional preview widget for the map type selector.
  /// If null, a default icon will be shown.
  Widget? get previewWidget => null;

  /// Build the map widget.
  ///
  /// [controller] - The TrufiMapController to control the map.
  /// [onMapClick] - Callback when the map is tapped.
  /// [onMapLongClick] - Callback when the map is long-pressed.
  Widget buildMap({
    required TrufiMapController controller,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
  });
}

/// Extension methods for ITrufiMapEngine.
extension TrufiMapEngineExtension on ITrufiMapEngine {
  /// Converts this engine to a MapTypeOption for use with MapTypeButton.
  MapTypeOption toMapTypeOption() {
    return MapTypeOption(
      id: id,
      name: name,
      description: description,
      previewImage: previewWidget,
    );
  }
}

/// Extension to convert a list of engines to MapTypeOptions.
extension MapEngineListExtension on List<ITrufiMapEngine> {
  /// Converts all engines to MapTypeOptions.
  List<MapTypeOption> toMapTypeOptions() {
    return map((e) => e.toMapTypeOption()).toList();
  }
}
