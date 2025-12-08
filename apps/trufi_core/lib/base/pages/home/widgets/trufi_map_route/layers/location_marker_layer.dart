import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/map_configuration/marker_configurations/marker_configuration.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/builders/route_marker_builder.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Layer for displaying from/to location markers.
///
/// Follows the TrufiLayer pattern from trufi_core_maps example.
/// Manages the origin and destination markers separately from route markers.
class LocationMarkerLayer extends TrufiLayer {
  static const String layerId = 'location-marker-layer';

  final RouteMarkerBuilder _markerBuilder;

  TrufiLatLng? _fromLocation;
  TrufiLatLng? _toLocation;

  LocationMarkerLayer(
    super.controller, {
    required MarkerConfiguration markerConfiguration,
    ThemeData? themeData,
  })  : _markerBuilder = RouteMarkerBuilder(
          markerConfiguration: markerConfiguration,
          themeData: themeData,
        ),
        super(id: layerId, layerLevel: 50);

  /// Get the current from location
  TrufiLatLng? get fromLocation => _fromLocation;

  /// Get the current to location
  TrufiLatLng? get toLocation => _toLocation;

  /// Set the from (origin) location
  void setFromLocation(TrufiLatLng? location) {
    _fromLocation = location;
    _updateMarkers();
  }

  /// Set the to (destination) location
  void setToLocation(TrufiLatLng? location) {
    _toLocation = location;
    _updateMarkers();
  }

  /// Set both from and to locations
  void setLocations({
    TrufiLatLng? from,
    TrufiLatLng? to,
  }) {
    _fromLocation = from;
    _toLocation = to;
    _updateMarkers();
  }

  /// Update the markers based on current locations
  void _updateMarkers() {
    clearMarkers();

    final markers = <TrufiMarker>[];

    if (_fromLocation != null) {
      markers.add(
        _markerBuilder.buildFromMarker(
          id: 'from-marker',
          point: _fromLocation!,
          layerLevel: layerLevel,
        ),
      );
    }

    if (_toLocation != null) {
      markers.add(
        _markerBuilder.buildToMarker(
          id: 'to-marker',
          point: _toLocation!,
          layerLevel: layerLevel + 1,
        ),
      );
    }

    if (markers.isNotEmpty) {
      addMarkers(markers);
    }
  }

  /// Clear all location markers
  void clearLocations() {
    _fromLocation = null;
    _toLocation = null;
    clearMarkers();
  }
}
