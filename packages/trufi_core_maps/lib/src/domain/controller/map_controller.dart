import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../entities/bounds.dart';
import '../entities/camera.dart';
import '../entities/marker.dart';
import '../layers/trufi_layer.dart';

class TrufiMapController {
  TrufiMapController({required TrufiCameraPosition initialCameraPosition})
    : cameraPositionNotifier = ValueNotifier(initialCameraPosition),
      layersNotifier = ValueNotifier(<String, TrufiLayer>{});

  final ValueNotifier<TrufiCameraPosition> cameraPositionNotifier;
  final ValueNotifier<Map<String, TrufiLayer>> layersNotifier;
  bool _mutateScheduled = false;
  bool _isDisposed = false;

  List<TrufiLayer> get visibleLayers => layersNotifier.value.values
      .where((l) => l.visible)
      .toList(growable: false);

  bool setCameraPosition(TrufiCameraPosition position) {
    final prev = cameraPositionNotifier.value;
    if (position == prev) return false;
    final sameTarget = prev.target == position.target;
    final sameBearing = prev.bearing == position.bearing;
    final sameIntZoom = prev.zoom.floor() == position.zoom.floor();
    final tinyZoomDiff = (prev.zoom - position.zoom).abs() < 0.001;
    final sameVisibleRegion = prev.visibleRegion == position.visibleRegion;
    if (sameTarget &&
        sameBearing &&
        sameIntZoom &&
        tinyZoomDiff &&
        sameVisibleRegion) {
      return false;
    }

    // Debug zoom changes
    if (prev.zoom != position.zoom) {
      debugPrint('🔍 Zoom changed: ${prev.zoom.toStringAsFixed(2)} → ${position.zoom.toStringAsFixed(2)}');
    }

    cameraPositionNotifier.value = position;

    return true;
  }

  bool setViewportSize(Size size) {
    final cur = cameraPositionNotifier.value;
    if (cur.viewportSize == size) return false;
    return setCameraPosition(cur.copyWith(viewportSize: size));
  }

  bool updateCamera({
    latlng.LatLng? target,
    double? zoom,
    double? bearing,
    LatLngBounds? visibleRegion,
  }) {
    final next = cameraPositionNotifier.value.copyWith(
      target: target,
      zoom: zoom,
      bearing: bearing != null ? bearing % 360 : null,
      visibleRegion: visibleRegion,
    );
    return setCameraPosition(next);
  }

  void mutateLayers() {
    // Debounce: only schedule one callback per frame
    if (_mutateScheduled || _isDisposed) return;
    _mutateScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mutateScheduled = false;
      // Skip if disposed while waiting for the callback
      if (_isDisposed) return;
      // Create a new map reference from the current state to trigger listeners
      layersNotifier.value = Map<String, TrufiLayer>.from(layersNotifier.value);
    });
  }

  bool addLayer(TrufiLayer layer) {
    final layers = Map<String, TrufiLayer>.from(layersNotifier.value);
    if (layers.containsKey(layer.id)) return false;
    layers[layer.id] = layer;
    layersNotifier.value = layers;
    return true;
  }

  TrufiLayer? getLayerById(String layerId) => layersNotifier.value[layerId];

  bool removeLayer(String layerId) {
    final layers = Map<String, TrufiLayer>.from(layersNotifier.value);
    final layer = layers[layerId];
    if (layer == null) return false;
    layer.dispose();
    layers.remove(layerId);
    layersNotifier.value = layers;
    return true;
  }

  bool toggleLayer(String layerId, bool visible) {
    final layers = Map<String, TrufiLayer>.from(layersNotifier.value);
    final layer = layers[layerId];
    if (layer == null || layer.visible == visible) return false;
    layer.visible = visible;
    layersNotifier.value = layers;
    return true;
  }

  List<TrufiMarker> pickMarkersAt(
    latlng.LatLng tap, {
    double hitboxPx = 24.0,
    int? perLayerLimit,
    int? globalLimit,
  }) {
    final leafletZoom = cameraPositionNotifier.value.zoom;
    // Flutter Map zoom = MapLibre zoom + 1 (for same visual scale)
    final mapLibreZoom = leafletZoom - 1.0;
    final radiusMeters = _hitboxPxToMeters(
      centerLatDeg: tap.latitude,
      zoomMapLibre: mapLibreZoom,
      hitboxPx: hitboxPx,
    );
    final dist = const latlng.Distance();
    final all = <TrufiMarker>[];
    for (final layer in visibleLayers) {
      final local = layer.markerIndex.getMarkers(
        tap,
        radiusMeters,
        limit: perLayerLimit,
      );
      all.addAll(local);
    }
    if (all.isEmpty) return const [];
    all.sort(
      (a, b) => dist
          .distance(tap, a.position)
          .compareTo(dist.distance(tap, b.position)),
    );
    if (globalLimit != null && globalLimit > 0 && all.length > globalLimit) {
      return all.take(globalLimit).toList(growable: false);
    }
    return all;
  }

  TrufiMarker? pickNearestMarkerAt(
    latlng.LatLng tap, {
    double hitboxPx = 24.0,
  }) {
    final picks = pickMarkersAt(tap, hitboxPx: hitboxPx, globalLimit: 1);
    return picks.isEmpty ? null : picks.first;
  }

  double _hitboxPxToMeters({
    required double centerLatDeg,
    required double zoomMapLibre,
    required double hitboxPx,
  }) {
    const earthCircumference = 40075016.68557849;
    final metersPerPixel =
        (earthCircumference * math.cos(centerLatDeg * math.pi / 180.0)) /
        (256.0 * math.pow(2.0, zoomMapLibre));
    return metersPerPixel * (hitboxPx * 0.5);
  }

  void dispose() {
    _isDisposed = true;
    for (final layer in layersNotifier.value.values.toList()) {
      layer.dispose();
    }
    cameraPositionNotifier.dispose();
    layersNotifier.dispose();
  }
}
