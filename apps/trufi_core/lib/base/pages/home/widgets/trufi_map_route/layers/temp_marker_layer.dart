import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Layer for displaying temporary markers (e.g., from long press).
///
/// Follows the TrufiLayer pattern from trufi_core_maps example.
/// Used for temporary interactions like selecting a location on the map.
class TempMarkerLayer extends TrufiLayer {
  static const String layerId = 'temp-marker-layer';

  final ThemeData? themeData;
  TrufiLatLng? _tempLocation;

  TempMarkerLayer(
    super.controller, {
    this.themeData,
  }) : super(id: layerId, layerLevel: 60);

  /// Wraps a widget with Theme for off-screen rendering.
  Widget _wrapWithTheme(Widget widget) {
    if (themeData != null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(data: themeData!, child: widget),
      );
    }
    return widget;
  }

  /// Get the current temp location
  TrufiLatLng? get tempLocation => _tempLocation;

  /// Set a temporary marker at the given location
  void setTempMarker(TrufiLatLng location, {Widget? customWidget}) {
    _tempLocation = location;
    clearMarkers();

    final widget = customWidget != null
        ? _wrapWithTheme(customWidget)
        : _buildDefaultTempMarker();

    addMarker(
      TrufiMarker(
        id: 'temp-marker',
        position: latlng.LatLng(location.latitude, location.longitude),
        widget: widget,
        size: const Size(40, 40),
        alignment: Alignment.bottomCenter,
        layerLevel: layerLevel,
      ),
    );
  }

  /// Build the default temporary marker widget
  Widget _buildDefaultTempMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.place,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  /// Clear the temporary marker
  void clearTempMarker() {
    _tempLocation = null;
    clearMarkers();
  }
}
