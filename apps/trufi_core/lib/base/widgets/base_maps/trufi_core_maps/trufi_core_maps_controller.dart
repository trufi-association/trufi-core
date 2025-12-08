import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/base/models/map_provider_collection/i_trufi_map_controller.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Layer for displaying the user's current location marker
class LocationLayer extends TrufiLayer {
  static const String layerId = 'location-layer';

  LocationLayer(super.controller) : super(id: layerId, layerLevel: 100);
}

/// Controller that bridges ITrufiMapController interface with TrufiMapController.
///
/// Based on trufi_core_maps example pattern:
/// - Uses TrufiMapController for state management
/// - Includes FitCameraLayer for viewport fitting
/// - Includes LocationLayer for current location marker
class TrufiCoreMapsController implements ITrufiMapController {
  static const int animationDuration = 500;

  final TrufiMapController mapController;
  final Completer<Null> _readyCompleter = Completer<Null>();

  /// Layer for fitting camera to bounds
  FitCameraLayer? fitCameraLayer;

  /// Layer for displaying current location
  LocationLayer? locationLayer;

  List<TrufiLatLng>? _selectedBoundsPoints;

  TrufiCoreMapsController({
    required TrufiCameraPosition initialCameraPosition,
    bool createFitCameraLayer = true,
    bool createLocationLayer = true,
  }) : mapController = TrufiMapController(
          initialCameraPosition: initialCameraPosition,
        ) {
    // Initialize layers following the example pattern
    if (createFitCameraLayer) {
      fitCameraLayer = FitCameraLayer(
        mapController,
        showCornerDots: false,
        debugFlag: false,
      );
    }

    if (createLocationLayer) {
      locationLayer = LocationLayer(mapController);
    }
  }

  /// Factory constructor from TrufiLatLng and zoom
  factory TrufiCoreMapsController.fromLatLng({
    required TrufiLatLng center,
    required double zoom,
    bool createFitCameraLayer = true,
    bool createLocationLayer = true,
  }) {
    return TrufiCoreMapsController(
      initialCameraPosition: TrufiCameraPosition(
        target: latlng.LatLng(center.latitude, center.longitude),
        zoom: zoom,
      ),
      createFitCameraLayer: createFitCameraLayer,
      createLocationLayer: createLocationLayer,
    );
  }

  @override
  Future<Null> get onReady => _readyCompleter.future;

  void markReady() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  @override
  void cleanMap() {
    _selectedBoundsPoints = null;
    fitCameraLayer?.clearFitPoints();

    // Clear all layers markers and lines except location layer
    for (final layer in mapController.layersNotifier.value.values) {
      if (layer.id != LocationLayer.layerId) {
        layer.clearMarkers();
        layer.clearLines();
      }
    }
  }

  @override
  Future<void> moveToYourLocation({
    required BuildContext context,
    required TrufiLatLng location,
    required double zoom,
    TickerProvider? tickerProvider,
  }) async {
    move(
      center: location,
      zoom: zoom,
      tickerProvider: tickerProvider,
    );
  }

  @override
  void moveBounds({
    required List<TrufiLatLng> points,
    required TickerProvider tickerProvider,
  }) {
    if (points.isEmpty) return;

    _selectedBoundsPoints = points;

    // Use FitCameraLayer if available
    if (fitCameraLayer != null) {
      final latLngPoints =
          points.map((p) => latlng.LatLng(p.latitude, p.longitude)).toList();
      fitCameraLayer!.fitBoundsOnCamera(latLngPoints);
    } else {
      _fitBoundsToPoints(points);
    }
  }

  @override
  void moveCurrentBounds({
    required TickerProvider tickerProvider,
  }) {
    if (fitCameraLayer != null) {
      fitCameraLayer!.reFitCamera();
    } else if (_selectedBoundsPoints != null) {
      _fitBoundsToPoints(_selectedBoundsPoints!);
    }
  }

  @override
  void move({
    required TrufiLatLng center,
    required double zoom,
    TickerProvider? tickerProvider,
  }) {
    mapController.updateCamera(
      target: latlng.LatLng(center.latitude, center.longitude),
      zoom: zoom,
    );
  }

  /// Fallback bounds fitting when FitCameraLayer is not available
  void _fitBoundsToPoints(List<TrufiLatLng> points) {
    if (points.isEmpty) return;

    final latLngPoints =
        points.map((p) => latlng.LatLng(p.latitude, p.longitude)).toList();

    final bounds = LatLngBounds.fromPoints(latLngPoints);

    // Calculate center
    final center = latlng.LatLng(
      (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
      (bounds.southWest.longitude + bounds.northEast.longitude) / 2,
    );

    // Calculate zoom level based on bounds span
    final latSpan = bounds.northEast.latitude - bounds.southWest.latitude;
    final lngSpan = bounds.northEast.longitude - bounds.southWest.longitude;
    final maxSpan = latSpan > lngSpan ? latSpan : lngSpan;

    // Approximate zoom calculation
    double zoom = 12.0;
    if (maxSpan > 0) {
      zoom = (16 - (maxSpan * 10)).clamp(2.0, 18.0);
    }

    mapController.updateCamera(target: center, zoom: zoom);
  }

  void dispose() {
    fitCameraLayer?.dispose();
    locationLayer?.dispose();
    mapController.dispose();
  }
}
