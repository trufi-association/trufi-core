import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// FlutterMap (OpenStreetMap raster tiles) engine.
///
/// Uses the flutter_map package to render raster tiles with the
/// same declarative API as MapLibreEngine.
class FlutterMapEngine implements ITrufiMapEngine {
  final String tileUrl;
  final String? darkTileUrl;
  final String? userAgentPackageName;
  final String? displayName;
  final String? displayDescription;
  final Widget? preview;

  const FlutterMapEngine({
    this.tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.darkTileUrl,
    this.userAgentPackageName,
    this.displayName,
    this.displayDescription,
    this.preview,
  });

  @override
  String get id => 'fluttermap';

  @override
  String get name => displayName ?? 'OSM (Raster)';

  @override
  String get description =>
      displayDescription ?? 'Classic OpenStreetMap with raster tiles';

  @override
  Widget? get previewWidget =>
      preview ??
      Container(
        color: Colors.green.shade100,
        child: const Center(
          child: Icon(Icons.map_outlined, size: 40, color: Colors.green),
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
    return _FlutterMapWidget(
      key: ValueKey(id),
      tileUrl: tileUrl,
      userAgentPackageName: userAgentPackageName,
      controller: controller,
      initialCamera: initialCamera,
      camera: camera,
      onCameraChanged: onCameraChanged,
      onMapClick: onMapClick,
      onMapLongClick: onMapLongClick,
      layers: layers,
      widgetMarkers: widgetMarkers,
    );
  }
}

class _FlutterMapWidget extends StatefulWidget {
  const _FlutterMapWidget({
    super.key,
    required this.tileUrl,
    this.userAgentPackageName,
    this.controller,
    required this.initialCamera,
    this.camera,
    this.onCameraChanged,
    this.onMapClick,
    this.onMapLongClick,
    this.layers = const [],
    this.widgetMarkers = const [],
  });

  final String tileUrl;
  final String? userAgentPackageName;
  final TrufiMapController? controller;
  final TrufiCameraPosition initialCamera;
  final TrufiCameraPosition? camera;
  final ValueChanged<TrufiCameraPosition>? onCameraChanged;
  final void Function(LatLng)? onMapClick;
  final void Function(LatLng)? onMapLongClick;
  final List<TrufiLayer> layers;
  final List<WidgetMarker> widgetMarkers;

  @override
  State<_FlutterMapWidget> createState() => _FlutterMapWidgetState();
}

class _FlutterMapWidgetState extends State<_FlutterMapWidget>
    implements TrufiMapDelegate {
  late final fm.MapController _mapCtl;
  late TrufiCameraPosition _currentCamera;
  bool _suppressCameraCallback = false;

  // Spatial indices for marker picking
  final Map<String, MarkerIndex> _markerIndices = {};

  @override
  void initState() {
    super.initState();
    _mapCtl = fm.MapController();
    _currentCamera = widget.camera ?? widget.initialCamera;
    widget.controller?.attach(this);
  }

  @override
  void didUpdateWidget(_FlutterMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(this);
    }

    // Controlled camera mode
    if (widget.camera != null && widget.camera != _currentCamera) {
      _moveCameraTo(widget.camera!);
    }

    // Rebuild spatial indices
    _rebuildIndices();
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _mapCtl.dispose();
    super.dispose();
  }

  void _rebuildIndices() {
    for (final layer in widget.layers) {
      if (!layer.visible) continue;
      final index = _markerIndices.putIfAbsent(layer.id, () => MarkerIndex());
      index.rebuild(layer.markers);
    }
  }

  // ──────────────────────────────────────────────
  // TrufiMapDelegate implementation
  // ──────────────────────────────────────────────

  @override
  TrufiCameraPosition get cameraPosition => _currentCamera;

  @override
  void moveCamera(TrufiCameraPosition position) => _moveCameraTo(position);

  @override
  void fitBounds(
    LatLngBounds bounds, {
    EdgeInsets padding = EdgeInsets.zero,
    double minZoom = 2.0,
    double maxZoom = 20.0,
  }) {
    final newCam = TrufiCameraFit.fitBoundsOnCamera(
      camera: _currentCamera.copyWith(
        viewportSize: _currentCamera.viewportSize,
      ),
      bounds: bounds,
      padding: padding,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    _moveCameraTo(newCam);
  }

  @override
  List<TrufiMarker> pickMarkersAt(
    LatLng tap, {
    double hitboxPx = 24.0,
    int? perLayerLimit,
    int? globalLimit,
  }) {
    // flutter_map uses Leaflet zoom directly; hitboxPxToMeters expects maplibre zoom
    final mapLibreZoom = _currentCamera.zoom - 1.0;
    final radiusMeters = hitboxPxToMeters(
      centerLatDeg: tap.latitude,
      zoomMapLibre: mapLibreZoom,
      hitboxPx: hitboxPx,
    );
    final dist = const Distance();
    final all = <TrufiMarker>[];
    for (final layer in widget.layers) {
      if (!layer.visible) continue;
      final index = _markerIndices[layer.id];
      if (index == null || index.isEmpty) continue;
      final local = index.getMarkers(tap, radiusMeters, limit: perLayerLimit);
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

  // ──────────────────────────────────────────────
  // Camera
  // ──────────────────────────────────────────────

  void _moveCameraTo(TrufiCameraPosition position) {
    _currentCamera = position;
    _suppressCameraCallback = true;
    _mapCtl.move(position.target, position.zoom);
  }

  void _handlePositionChanged(fm.MapCamera camera, bool hasGesture) {
    if (_suppressCameraCallback) {
      _suppressCameraCallback = false;
      return;
    }

    final newCamera = TrufiCameraPosition(
      target: camera.center,
      zoom: camera.zoom,
      bearing: camera.rotation,
      viewportSize: camera.nonRotatedSize,
      visibleRegion: LatLngBounds(
        camera.visibleBounds.southWest,
        camera.visibleBounds.northEast,
      ),
    );

    _currentCamera = newCamera;
    widget.onCameraChanged?.call(newCamera);
  }

  // ──────────────────────────────────────────────
  // Build flutter_map layers from TrufiLayers
  // ──────────────────────────────────────────────

  List<Widget> _buildFlutterMapLayers() {
    final visibleLayers = widget.layers
        .where((l) => l.visible)
        .toList()
      ..sort((a, b) => a.layerLevel.compareTo(b.layerLevel));

    final result = <Widget>[];

    for (final layer in visibleLayers) {
      // Lines (polylines)
      if (layer.lines.isNotEmpty) {
        final polylines = <fm.Polyline>[];
        for (final line in layer.lines) {
          if (!line.visible || line.position.length < 2) continue;
          polylines.add(fm.Polyline(
            points: line.position,
            color: line.color,
            strokeWidth: line.lineWidth,
            pattern: line.activeDots
                ? const fm.StrokePattern.dotted()
                : const fm.StrokePattern.solid(),
          ));
        }
        if (polylines.isNotEmpty) {
          result.add(fm.PolylineLayer(polylines: polylines));
        }
      }

      // Markers
      if (layer.markers.isNotEmpty) {
        final markers = <fm.Marker>[];
        for (final m in layer.markers) {
          markers.add(fm.Marker(
            point: m.position,
            width: m.size.width,
            height: m.size.height,
            alignment: m.alignment,
            rotate: true,
            child: Transform.rotate(
              angle: m.rotation * math.pi / 180.0,
              child: m.widget,
            ),
          ));
        }
        result.add(fm.MarkerLayer(markers: markers));
      }
    }

    return result;
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    Widget result = fm.FlutterMap(
      mapController: _mapCtl,
      options: fm.MapOptions(
        initialCenter: widget.initialCamera.target,
        initialZoom: widget.initialCamera.zoom,
        initialRotation: widget.initialCamera.bearing,
        interactionOptions: const fm.InteractionOptions(
          flags: fm.InteractiveFlag.all & ~fm.InteractiveFlag.rotate,
        ),
        onPositionChanged: _handlePositionChanged,
        onTap: widget.onMapClick != null
            ? (tapPos, latLng) => widget.onMapClick!(latLng)
            : null,
        onLongPress: widget.onMapLongClick != null
            ? (tapPos, latLng) => widget.onMapLongClick!(latLng)
            : null,
      ),
      children: [
        fm.TileLayer(
          urlTemplate: widget.tileUrl,
          userAgentPackageName: widget.userAgentPackageName ?? '',
          tileProvider: fm.NetworkTileProvider(),
        ),
        ..._buildFlutterMapLayers(),
      ],
    );

    // Widget marker overlay
    if (widget.widgetMarkers.isNotEmpty) {
      result = Stack(
        children: [
          result,
          _WidgetMarkerOverlay(
            markers: widget.widgetMarkers,
            camera: _currentCamera,
          ),
        ],
      );
    }

    return result;
  }
}

// ──────────────────────────────────────────────
// Widget Marker Overlay (same as TrufiMap)
// ──────────────────────────────────────────────

class _WidgetMarkerOverlay extends StatelessWidget {
  const _WidgetMarkerOverlay({
    required this.markers,
    required this.camera,
  });

  final List<WidgetMarker> markers;
  final TrufiCameraPosition camera;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: markers.map((marker) {
              final screenPos = _latLngToScreen(
                marker.position,
                camera,
                viewSize,
              );
              if (screenPos == null) return const SizedBox.shrink();

              final dx = screenPos.dx -
                  (marker.size.width / 2) * (1 + marker.alignment.x);
              final dy = screenPos.dy -
                  (marker.size.height / 2) * (1 + marker.alignment.y);

              return Positioned(
                left: dx,
                top: dy,
                width: marker.size.width,
                height: marker.size.height,
                child: marker.child,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Offset? _latLngToScreen(
    LatLng position,
    TrufiCameraPosition camera,
    Size viewSize,
  ) {
    const tileSize = 256.0;
    const maxLat = 85.05112878;
    final zoom = camera.zoom;

    double lngToX(double lng) => (lng + 180.0) / 360.0;
    double latToY(double lat) {
      final clamped = lat.clamp(-maxLat, maxLat);
      final phi = clamped * math.pi / 180.0;
      final s = math.tan(phi) + 1 / math.cos(phi);
      return (1 - (math.log(s) / math.pi)) / 2;
    }

    final worldPx = tileSize * math.pow(2.0, zoom);

    final cx = lngToX(camera.target.longitude) * worldPx;
    final cy = latToY(camera.target.latitude) * worldPx;

    final px = lngToX(position.longitude) * worldPx;
    final py = latToY(position.latitude) * worldPx;

    final dx = px - cx + viewSize.width / 2;
    final dy = py - cy + viewSize.height / 2;

    if (dx < -100 ||
        dy < -100 ||
        dx > viewSize.width + 100 ||
        dy > viewSize.height + 100) {
      return null;
    }

    return Offset(dx, dy);
  }
}
