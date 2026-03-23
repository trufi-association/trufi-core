import 'dart:async';
import 'dart:math' as math;
import 'dart:math' show Point;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide LatLngBounds;
import 'package:latlong2/latlong.dart' as latlng;

import '../../data/spatial/marker_index.dart';
import '../../data/utils/color_utils.dart';
import '../../data/utils/image_tool.dart';
import '../../domain/controller/map_controller.dart';
import '../../domain/entities/bounds.dart';
import '../../domain/entities/camera.dart';
import '../../domain/entities/marker.dart';
import '../../domain/entities/widget_marker.dart';
import '../../domain/layers/trufi_layer.dart';
import '../utils/trufi_camera_fit.dart';

/// Declarative map widget backed by MapLibre.
///
/// Pass layers and markers as data — all synchronization with the native
/// map engine is handled internally.
///
/// ```dart
/// TrufiMap(
///   styleString: 'https://tiles.openfreemap.org/styles/liberty',
///   initialCamera: TrufiCameraPosition(target: LatLng(-17.39, -66.15), zoom: 14),
///   onCameraChanged: (cam) => setState(() => _camera = cam),
///   onMapClick: (latLng) => print('Tapped $latLng'),
///   layers: [
///     TrufiLayer(id: 'route', markers: routeMarkers, lines: routeLines),
///     TrufiLayer(id: 'pois', markers: poiMarkers),
///   ],
///   widgetMarkers: [
///     WidgetMarker(id: 'bus', position: busPos, child: BusIcon()),
///   ],
/// )
/// ```
class TrufiMap extends StatefulWidget {
  const TrufiMap({
    super.key,
    required this.styleString,
    this.initialCamera = const TrufiCameraPosition(
      target: latlng.LatLng(0, 0),
    ),
    this.camera,
    this.controller,
    this.onCameraChanged,
    this.onMapClick,
    this.onMapLongClick,
    this.layers = const [],
    this.widgetMarkers = const [],
  });

  /// MapLibre style URL or local path.
  final String styleString;

  /// Initial camera position (used only when uncontrolled).
  final TrufiCameraPosition initialCamera;

  /// Controlled camera position. When non-null, the map tracks this value.
  final TrufiCameraPosition? camera;

  /// Optional controller for imperative operations (moveCamera, fitBounds, pickMarkers).
  final TrufiMapController? controller;

  /// Called when the user moves the camera (pan/zoom/rotate).
  final ValueChanged<TrufiCameraPosition>? onCameraChanged;

  /// Called when the map is tapped.
  final void Function(latlng.LatLng)? onMapClick;

  /// Called when the map is long-pressed.
  final void Function(latlng.LatLng)? onMapLongClick;

  /// Layers with markers and lines rendered natively by MapLibre.
  /// Markers are converted to PNG for GPU-accelerated rendering.
  final List<TrufiLayer> layers;

  /// Flutter widgets rendered as overlays on the map.
  /// Use for interactive/animated markers (limited quantity).
  final List<WidgetMarker> widgetMarkers;

  @override
  State<TrufiMap> createState() => _TrufiMapState();
}

class _TrufiMapState extends State<TrufiMap> implements TrufiMapDelegate {
  MapLibreMapController? _mapCtl;
  bool _mapReady = false;
  bool _suppressCameraCallback = false;
  bool _syncInProgress = false;
  bool _syncPending = false;

  late TrufiCameraPosition _currentCamera;

  // Image caching
  final Set<String> _loadedImages = {};
  final Map<String, Future<void>> _imageLoaders = {};

  // Source tracking
  final Set<String> _initializedSources = {};
  final Map<String, Future<void>> _sourceInit = {};

  // Spatial indices for marker picking
  final Map<String, MarkerIndex> _markerIndices = {};

  static const int _maxConcurrentImageLoads = 5;

  // ──────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.camera ?? widget.initialCamera;
    widget.controller?.attach(this);
  }

  @override
  void didUpdateWidget(TrufiMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(this);
    }

    // Controlled camera mode
    if (widget.camera != null && widget.camera != _currentCamera) {
      _moveCameraTo(widget.camera!);
    }

    // Always schedule sync on rebuild — internally we check if work is needed
    _scheduleSync();
  }

  @override
  void dispose() {
    widget.controller?.detach();
    super.dispose();
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
    latlng.LatLng tap, {
    double hitboxPx = 24.0,
    int? perLayerLimit,
    int? globalLimit,
  }) {
    final leafletZoom = _currentCamera.zoom;
    final mapLibreZoom = leafletZoom - 1.0;
    final radiusMeters = hitboxPxToMeters(
      centerLatDeg: tap.latitude,
      zoomMapLibre: mapLibreZoom,
      hitboxPx: hitboxPx,
    );
    final dist = const latlng.Distance();
    final all = <TrufiMarker>[];
    for (final layer in widget.layers) {
      if (!layer.visible) continue;
      final index = _markerIndices[layer.id];
      if (index == null || index.isEmpty) continue;
      final local = index.getMarkers(
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

  // ──────────────────────────────────────────────
  // Camera
  // ──────────────────────────────────────────────

  void _moveCameraTo(TrufiCameraPosition position) {
    _currentCamera = position;
    if (_mapReady && _mapCtl != null) {
      _suppressCameraCallback = true;
      _mapCtl!.moveCamera(
        CameraUpdate.newCameraPosition(_toCameraPosition(position)),
      );
    }
  }

  Future<void> _handleCameraIdle() async {
    if (_suppressCameraCallback) {
      _suppressCameraCallback = false;
      return;
    }
    final ctl = _mapCtl;
    if (ctl == null) return;
    final cam = ctl.cameraPosition;
    if (cam == null) return;
    final visibleRegion = await ctl.getVisibleRegion();
    final newCamera = _currentCamera.copyWith(
      target: latlng.LatLng(cam.target.latitude, cam.target.longitude),
      zoom: _toLeafletZoom(cam.zoom),
      bearing: _toLeafletBearing(cam.bearing),
      visibleRegion: LatLngBounds(
        latlng.LatLng(
          visibleRegion.southwest.latitude,
          visibleRegion.southwest.longitude,
        ),
        latlng.LatLng(
          visibleRegion.northeast.latitude,
          visibleRegion.northeast.longitude,
        ),
      ),
    );

    _currentCamera = newCamera;
    widget.onCameraChanged?.call(newCamera);

    // Rebuild for widget marker overlay repositioning
    if (widget.widgetMarkers.isNotEmpty && mounted) {
      setState(() {});
    }
  }

  // ──────────────────────────────────────────────
  // Layer synchronization
  // ──────────────────────────────────────────────

  void _scheduleSync() {
    if (!_mapReady || _mapCtl == null) return;
    if (_syncInProgress) {
      _syncPending = true;
      return;
    }
    _runSync();
  }

  Future<void> _runSync() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    _syncPending = false;

    try {
      final visibleLayers =
          widget.layers.where((l) => l.visible).toList(growable: false);
      await _syncLayers(visibleLayers);
    } finally {
      _syncInProgress = false;
      if (_syncPending && mounted) {
        _syncPending = false;
        _runSync();
      }
    }
  }

  Future<void> _syncLayers(List<TrufiLayer> visibleLayers) async {
    final ctl = _mapCtl;
    if (ctl == null) return;

    final sorted = [...visibleLayers]
      ..sort((a, b) => a.layerLevel.compareTo(b.layerLevel));

    final currentLayerIds = sorted.map((l) => l.id).toSet();

    // Remove layers that no longer exist
    final removedSources = _initializedSources
        .where((id) => !currentLayerIds.contains(id))
        .toList();
    for (final sourceId in removedSources) {
      await _removeMapLibreLayer(sourceId, ctl);
    }

    for (final layer in sorted) {
      await _ensureLayerInitialized(layer, ctl);
    }

    await Future.wait(
      sorted.map((l) => _updateLayerData(l, ctl)),
      eagerError: true,
    );
  }

  Future<void> _removeMapLibreLayer(
    String sourceId,
    MapLibreMapController ctl,
  ) async {
    try {
      await ctl.removeLayer('${sourceId}_marker_overlap');
      await ctl.removeLayer('${sourceId}_marker_no_overlap');
      await ctl.removeLayer('${sourceId}_solid');
      await ctl.removeLayer('${sourceId}_dotted');
      await ctl.removeSource(sourceId);
    } catch (_) {}
    _initializedSources.remove(sourceId);
    _markerIndices.remove(sourceId);
  }

  Future<void> _ensureLayerInitialized(
    TrufiLayer layer,
    MapLibreMapController ctl,
  ) async {
    final sourceId = layer.id;
    if (_initializedSources.contains(sourceId)) return;

    final inFlight = _sourceInit[sourceId];
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = () async {
      await ctl.addGeoJsonSource(sourceId, const {
        "type": "FeatureCollection",
        "features": [],
      });

      await ctl.addLineLayer(
        sourceId,
        "${sourceId}_dotted",
        LineLayerProperties(
          lineColor: ["get", "color"],
          lineWidth: ["get", "width"],
          lineSortKey: ["get", "layerLevel"],
          lineDasharray: [2, 1],
          lineJoin: "round",
        ),
        filter: [
          "==",
          ["get", "dotted"],
          true,
        ],
        enableInteraction: false,
      );

      await ctl.addLineLayer(
        sourceId,
        "${sourceId}_solid",
        LineLayerProperties(
          lineColor: ["get", "color"],
          lineWidth: ["get", "width"],
          lineSortKey: ["get", "layerLevel"],
          lineJoin: "round",
          lineCap: "round",
        ),
        filter: [
          "==",
          ["get", "dotted"],
          false,
        ],
        enableInteraction: false,
      );

      await ctl.addSymbolLayer(
        sourceId,
        "${sourceId}_marker_no_overlap",
        SymbolLayerProperties(
          iconImage: ["get", "icon"],
          iconSize: 1.0,
          iconAllowOverlap: false,
          iconOffset: ["get", "offset"],
          iconRotate: ["get", "rotate"],
          symbolSortKey: ["get", "layerLevel"],
        ),
        filter: [
          "==",
          ["get", "allowOverlap"],
          false,
        ],
        enableInteraction: false,
      );

      await ctl.addSymbolLayer(
        sourceId,
        "${sourceId}_marker_overlap",
        SymbolLayerProperties(
          iconImage: ["get", "icon"],
          iconSize: 1.0,
          iconAllowOverlap: true,
          iconOffset: ["get", "offset"],
          iconRotate: ["get", "rotate"],
          symbolSortKey: ["get", "layerLevel"],
        ),
        filter: [
          "==",
          ["get", "allowOverlap"],
          true,
        ],
        enableInteraction: false,
      );

      _initializedSources.add(sourceId);
    }();

    _sourceInit[sourceId] = future;
    try {
      await future;
    } finally {
      _sourceInit.remove(sourceId);
    }
  }

  Future<void> _updateLayerData(
    TrufiLayer layer,
    MapLibreMapController ctl,
  ) async {
    final geojson = await _buildGeoJsonForLayer(layer, ctl);

    final features = geojson['features'] as List;
    if (features.isEmpty) {
      await ctl.setGeoJsonSource(layer.id, geojson);
      await SchedulerBinding.instance.endOfFrame;
    }
    await ctl.setGeoJsonSource(layer.id, geojson);

    // Rebuild spatial index for picking
    final index = _markerIndices.putIfAbsent(layer.id, () => MarkerIndex());
    index.rebuild(layer.markers);
  }

  // ──────────────────────────────────────────────
  // GeoJSON building
  // ──────────────────────────────────────────────

  List<double> _alignmentOffsetPx(Alignment a, Size s) {
    final dx = (a.x) * (s.width / 2.0);
    final dy = (a.y) * (s.height / 2.0);
    return [dx, dy];
  }

  Future<Map<String, dynamic>> _buildGeoJsonForLayer(
    TrufiLayer layer,
    MapLibreMapController ctl,
  ) async {
    final markers = [...layer.markers];

    await _loadImagesInBatches(markers, ctl);

    final features = <Map<String, dynamic>>[];
    for (final marker in markers) {
      final imageId = marker.imageCacheKey ?? '${marker.widget.hashCode}';
      final offset = _alignmentOffsetPx(marker.alignment, marker.size);

      features.add({
        "type": "Feature",
        "id": marker.id,
        "geometry": {
          "type": "Point",
          "coordinates": [marker.position.longitude, marker.position.latitude],
        },
        "properties": {
          "type": "marker",
          "icon": imageId,
          "markerId": marker.id,
          "offset": offset,
          "rotate": marker.rotation,
          "layerLevel": marker.layerLevel,
          "allowOverlap": marker.allowOverlap,
        },
      });
    }

    for (final line in layer.lines) {
      features.add({
        "type": "Feature",
        "id": line.id,
        "geometry": {
          "type": "LineString",
          "coordinates":
              line.position.map((e) => [e.longitude, e.latitude]).toList(),
        },
        "properties": {
          "color": decodeFillColor(line.color),
          "width": line.lineWidth,
          "layerLevel": line.layerLevel,
          "dotted": line.activeDots,
        },
      });
    }

    return {"type": "FeatureCollection", "features": features};
  }

  // ──────────────────────────────────────────────
  // Image loading
  // ──────────────────────────────────────────────

  Future<void> _loadImagesInBatches(
    List<TrufiMarker> markers,
    MapLibreMapController ctl,
  ) async {
    if (!mounted) return;

    final toLoad = <(String, TrufiMarker)>[];
    for (final marker in markers) {
      final imageId = marker.imageCacheKey ?? '${marker.widget.hashCode}';
      if (!_loadedImages.contains(imageId) &&
          !_imageLoaders.containsKey(imageId) &&
          !toLoad.any((e) => e.$1 == imageId)) {
        toLoad.add((imageId, marker));
      }
    }

    if (toLoad.isEmpty) return;

    for (var i = 0; i < toLoad.length; i += _maxConcurrentImageLoads) {
      if (!mounted) return;
      final batch = toLoad.skip(i).take(_maxConcurrentImageLoads);
      await Future.wait(
        batch.map((entry) => _loadSingleImage(entry.$1, entry.$2, ctl)),
        eagerError: false,
      );
    }
  }

  Future<void> _loadSingleImage(
    String imageId,
    TrufiMarker marker,
    MapLibreMapController ctl,
  ) async {
    await _ensureImageLoaded(imageId, () async {
      if (!mounted) return;
      final bytes =
          marker.widgetBytes ?? await ImageTool.widgetToBytes(marker, context);
      await ctl.addImage(imageId, bytes);
    });
  }

  Future<void> _ensureImageLoaded(
    String imageId,
    Future<void> Function() loader,
  ) async {
    if (_loadedImages.contains(imageId)) return;
    final inFlight = _imageLoaders[imageId];
    if (inFlight != null) {
      await inFlight;
      return;
    }
    final future = loader()
        .then((_) {
          _loadedImages.add(imageId);
          _imageLoaders.remove(imageId);
        })
        .catchError((e, st) {
          _imageLoaders.remove(imageId);
          throw e;
        });
    _imageLoaders[imageId] = future;
    await future;
  }

  // ──────────────────────────────────────────────
  // Web long-press workaround
  // ──────────────────────────────────────────────

  Future<void> _handleWebLongPress(Offset localPosition) async {
    final ctl = _mapCtl;
    if (ctl == null) return;
    final point = Point(localPosition.dx, localPosition.dy);
    final coordinates = await ctl.toLatLng(point);
    widget.onMapLongClick?.call(
      latlng.LatLng(coordinates.latitude, coordinates.longitude),
    );
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    Widget result = MapLibreMap(
      initialCameraPosition: _toCameraPosition(_currentCamera),
      styleString: widget.styleString,
      trackCameraPosition: true,
      rotateGesturesEnabled: false,
      compassEnabled: false,
      onMapCreated: (ctl) async {
        _mapCtl = ctl;
      },
      onStyleLoadedCallback: () async {
        _mapReady = true;
        _initializedSources.clear();
        _imageLoaders.clear();
        _loadedImages.clear();
        _sourceInit.clear();
        _scheduleSync();
        // Retry sync after a delay to handle race conditions in profile/release
        // where widget-to-image rasterization may fail on first attempt
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && _mapReady) {
            _loadedImages.clear();
            _imageLoaders.clear();
            _scheduleSync();
          }
        });
      },
      onCameraIdle: _handleCameraIdle,
      onMapLongClick: kIsWeb
          ? null
          : (point, coordinates) {
              widget.onMapLongClick?.call(
                latlng.LatLng(coordinates.latitude, coordinates.longitude),
              );
            },
      onMapClick: (points, coordinates) {
        widget.onMapClick?.call(
          latlng.LatLng(coordinates.latitude, coordinates.longitude),
        );
      },
    );

    // Widget marker overlay
    if (widget.widgetMarkers.isNotEmpty) {
      result = Stack(
        children: [
          result,
          _WidgetMarkerOverlay(
            markers: widget.widgetMarkers,
            camera: _currentCamera,
            mapController: _mapCtl,
          ),
        ],
      );
    }

    // Web long-press workaround
    if (kIsWeb && widget.onMapLongClick != null) {
      result = GestureDetector(
        onLongPressStart: (details) =>
            _handleWebLongPress(details.localPosition),
        child: result,
      );
    }

    return result;
  }

  // ──────────────────────────────────────────────
  // Zoom/bearing conversions (Leaflet ↔ MapLibre)
  // ──────────────────────────────────────────────

  CameraPosition _toCameraPosition(TrufiCameraPosition cam) => CameraPosition(
        target: LatLng(cam.target.latitude, cam.target.longitude),
        zoom: _toMapLibreZoom(cam.zoom),
        bearing: _toMapLibreBearing(cam.bearing),
      );

  double _toMapLibreZoom(double leafletZoom) => leafletZoom - 1.0;
  double _toLeafletZoom(double mapLibreZoom) => mapLibreZoom + 1.0;
  double _toMapLibreBearing(double leafletBearing) =>
      (360 - leafletBearing) % 360;
  double _toLeafletBearing(double mapLibreBearing) =>
      (360 - mapLibreBearing) % 360;
}

// ──────────────────────────────────────────────
// Widget Marker Overlay
// ──────────────────────────────────────────────

class _WidgetMarkerOverlay extends StatelessWidget {
  const _WidgetMarkerOverlay({
    required this.markers,
    required this.camera,
    required this.mapController,
  });

  final List<WidgetMarker> markers;
  final TrufiCameraPosition camera;
  final MapLibreMapController? mapController;

  @override
  Widget build(BuildContext context) {
    if (mapController == null) return const SizedBox.shrink();

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

              // Apply alignment offset
              final dx =
                  screenPos.dx - (marker.size.width / 2) * (1 + marker.alignment.x);
              final dy =
                  screenPos.dy - (marker.size.height / 2) * (1 + marker.alignment.y);

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
    latlng.LatLng position,
    TrufiCameraPosition camera,
    Size viewSize,
  ) {
    // WebMercator projection
    const tileSize = 256.0;
    const maxLat = 85.05112878;
    final zoom = camera.zoom; // Leaflet zoom

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

    // Cull off-screen markers
    if (dx < -100 ||
        dy < -100 ||
        dx > viewSize.width + 100 ||
        dy > viewSize.height + 100) {
      return null;
    }

    return Offset(dx, dy);
  }
}
