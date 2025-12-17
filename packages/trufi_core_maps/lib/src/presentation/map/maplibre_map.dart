import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide LatLngBounds;
import 'package:latlong2/latlong.dart' as latlng;

import '../../domain/entities/bounds.dart';
import '../../domain/entities/camera.dart';
import '../../domain/layers/trufi_layer.dart';
import '../../domain/controller/map_controller.dart';
import '../../data/utils/color_utils.dart';
import '../../data/utils/image_tool.dart';
import '../../data/spatial/marker_index.dart';
import 'trufi_map.dart';

class TrufiMapLibreMap extends StatefulWidget implements TrufiMap {
  const TrufiMapLibreMap({
    super.key,
    required this.controller,
    this.onMapClick,
    this.onMapLongClick,
    required this.styleString,
  });

  @override
  final TrufiMapController controller;
  @override
  final void Function(latlng.LatLng)? onMapClick;
  @override
  final void Function(latlng.LatLng)? onMapLongClick;

  final String styleString;

  @override
  State<TrufiMapLibreMap> createState() => _TrufiMapLibreMapState();
}

class _TrufiMapLibreMapState extends State<TrufiMapLibreMap> {
  MapLibreMapController? _mapCtl;
  bool _mapReady = false;
  bool _suppressSync = false;
  bool _syncInProgress = false;
  bool _syncPending = false;

  final Set<String> _loadedImages = {};
  final Map<String, Future<void>> _imageLoaders = {};
  final MarkersContainer _markers = MarkersContainer();

  final Set<String> _initializedSources = {};
  final Map<String, Future<void>> _sourceInit = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.controller.cameraPositionNotifier.addListener(_cameraListener);
      widget.controller.layersNotifier.addListener(_layersListener);
    });
  }

  @override
  void dispose() {
    widget.controller.cameraPositionNotifier.removeListener(_cameraListener);
    widget.controller.layersNotifier.removeListener(_layersListener);
    super.dispose();
  }

  void _cameraListener() {
    final camera = widget.controller.cameraPositionNotifier.value;
    if (_mapReady && _mapCtl != null) {
      _suppressSync = true;
      _mapCtl!.moveCamera(
        CameraUpdate.newCameraPosition(_toCameraPosition(camera)),
      );
    }
  }

  void _layersListener() {
    if (!_mapReady || _mapCtl == null) return;

    // If sync is already in progress, mark as pending and return
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
      final visibleLayers = widget.controller.visibleLayers;
      await _syncLayers(visibleLayers);
    } finally {
      _syncInProgress = false;

      // If another sync was requested while we were busy, run it now
      if (_syncPending && mounted) {
        _syncPending = false;
        _runSync();
      }
    }
  }

  Future<void> _handleCameraIdle() async {
    if (_suppressSync) {
      _suppressSync = false;
      return;
    }
    final ctl = _mapCtl;
    if (ctl == null) return;
    final cam = ctl.cameraPosition;
    if (cam == null) return;
    final visibleRegion = await ctl.getVisibleRegion();
    widget.controller.updateCamera(
      target: latlng.LatLng(cam.target.latitude, cam.target.longitude),
      zoom: toLeafletZoom(cam.zoom),
      bearing: toLeafletBearing(cam.bearing),
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
  }

  Future<void> _syncLayers(List<TrufiLayer> visibleLayers) async {
    final ctl = _mapCtl;
    if (ctl == null) return;

    final sorted = [...visibleLayers]
      ..sort((a, b) => a.layerLevel.compareTo(b.layerLevel));

    // Get the set of current layer IDs
    final currentLayerIds = sorted.map((l) => l.id).toSet();

    // Find and remove layers that no longer exist
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
      // Remove the three layers associated with this source
      await ctl.removeLayer('${sourceId}_marker');
      await ctl.removeLayer('${sourceId}_solid');
      await ctl.removeLayer('${sourceId}_dotted');
      // Remove the source
      await ctl.removeSource(sourceId);
    } catch (_) {
      // Ignore errors if layers/source don't exist
    }
    _initializedSources.remove(sourceId);
    _markers.clearLayer(sourceId);
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
        "${sourceId}_marker",
        SymbolLayerProperties(
          iconImage: ["get", "icon"],
          iconSize: 1.0,
          iconAllowOverlap: true,
          iconOffset: ["get", "offset"],
          iconRotate: ["get", "rotate"],
          symbolSortKey: ["get", "layerLevel"],
        ),
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

    // MapLibre GL sometimes doesn't properly clear symbols when updating to
    // an empty FeatureCollection. Force a double-update to ensure clearing.
    final features = geojson['features'] as List;
    if (features.isEmpty) {
      // First set empty, then set again to force refresh
      await ctl.setGeoJsonSource(layer.id, geojson);
      // Small delay to allow MapLibre to process the empty source
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    await ctl.setGeoJsonSource(layer.id, geojson);
    _markers.setLayerMarkers(layer.id, layer.markers);
  }

  List<double> _alignmentOffsetPx(Alignment a, Size s) {
    final dx = (a.x) * (s.width / 2.0);
    final dy = (a.y) * (s.height / 2.0);
    return [dx, dy];
  }

  Future<Map<String, dynamic>> _buildGeoJsonForLayer(
    TrufiLayer layer,
    MapLibreMapController ctl,
  ) async {
    final features = <Map<String, dynamic>>[];
    final markers = [...layer.markers];
    for (final marker in markers) {
      // Use imageKey if provided, otherwise fall back to widget.hashCode
      final imageId = marker.imageKey ?? '${marker.widget.hashCode}';

      await _ensureImageLoaded(imageId, () async {
        if (!mounted) return;
        final bytes =
            marker.widgetBytes ??
            await ImageTool.widgetToBytes(marker, context);
        await ctl.addImage(imageId, bytes);
      });

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
        },
      });
    }

    for (final line in layer.lines) {
      features.add({
        "type": "Feature",
        "id": line.id,
        "geometry": {
          "type": "LineString",
          "coordinates": line.position
              .map((e) => [e.longitude, e.latitude])
              .toList(),
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

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      initialCameraPosition: _toCameraPosition(
        widget.controller.cameraPositionNotifier.value,
      ),
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

        final layers = widget.controller.visibleLayers;
        await _syncLayers(layers);
      },
      onCameraIdle: _handleCameraIdle,
      onMapLongClick: (point, coordinates) {
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
  }

  CameraPosition _toCameraPosition(TrufiCameraPosition cam) => CameraPosition(
    target: LatLng(cam.target.latitude, cam.target.longitude),
    zoom: toMapLibreZoom(cam.zoom),
    bearing: toMapLibreBearing(cam.bearing),
  );

  double toMapLibreZoom(double leafletZoom) => leafletZoom - 1.0;
  double toLeafletZoom(double mapLibreZoom) => mapLibreZoom + 1.0;

  double toMapLibreBearing(double leafletBearing) =>
      (360 - leafletBearing) % 360;
  double toLeafletBearing(double mapLibreBearing) =>
      (360 - mapLibreBearing) % 360;
}
