import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Convert meters to pixels at a given latitude and zoom level.
/// Based on Web Mercator projection.
double _metersToPixels(double meters, double latitude, double zoom) {
  // Earth's circumference at equator in meters
  const earthCircumference = 40075016.686;
  // Pixels per tile
  const tileSize = 256.0;

  // Ground resolution (meters per pixel) at given latitude and zoom
  final groundResolution = (earthCircumference * math.cos(latitude * math.pi / 180)) /
      (tileSize * math.pow(2, zoom));

  return meters / groundResolution;
}

class TrufiFlutterMap extends StatefulWidget implements TrufiMap {
  const TrufiFlutterMap({
    super.key,
    required this.controller,
    this.onMapClick,
    this.onMapLongClick,
    required this.tileUrl,
    this.userAgentPackageName,
    this.useDarkModeFilter = false,
  });

  @override
  final TrufiMapController controller;
  @override
  final void Function(latlng.LatLng)? onMapClick;
  @override
  final void Function(latlng.LatLng)? onMapLongClick;

  final String tileUrl;
  final String? userAgentPackageName;

  /// Whether to apply a dark mode color filter to tiles.
  final bool useDarkModeFilter;

  @override
  State<TrufiFlutterMap> createState() => _TrufiFlutterMapState();
}

class _TrufiFlutterMapState extends State<TrufiFlutterMap> {
  final fm.MapController _mapCtl = fm.MapController();
  bool _mapReady = false;
  bool _suppressSync = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    if (!_mapReady) return;
    final camera = widget.controller.cameraPositionNotifier.value;
    _suppressSync = true;
    _mapCtl.moveAndRotate(camera.target, camera.zoom, camera.bearing);
  }

  void _layersListener() {
    setState(() {});
  }

  void _onPositionChanged(fm.MapCamera pos, bool hasGesture) {
    if (_suppressSync) {
      _suppressSync = false;
      return;
    }
    final fb = pos.visibleBounds;
    final vr = LatLngBounds(fb.southWest, fb.northEast);
    widget.controller.updateCamera(
      target: pos.center,
      zoom: pos.zoom,
      bearing: pos.rotation,
      visibleRegion: vr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final camera = widget.controller.cameraPositionNotifier.value;
    final visibleLayers = widget.controller.visibleLayers;

    return fm.FlutterMap(
      mapController: _mapCtl,
      options: fm.MapOptions(
        initialCenter: camera.target,
        initialZoom: camera.zoom,
        initialRotation: camera.bearing,
        backgroundColor: Colors.transparent,
        interactionOptions: const fm.InteractionOptions(
          flags: fm.InteractiveFlag.all & ~fm.InteractiveFlag.rotate,
        ),
        onMapReady: () {
          setState(() => _mapReady = true);
          _suppressSync = true;
          _mapCtl.moveAndRotate(camera.target, camera.zoom, camera.bearing);
        },
        onPositionChanged: _onPositionChanged,
        onTap: (_, position) => widget.onMapClick?.call(position),
        onLongPress: (_, position) => widget.onMapLongClick?.call(position),
      ),
      children: [
        fm.TileLayer(
          urlTemplate: widget.tileUrl,
          userAgentPackageName:
              widget.userAgentPackageName ?? 'com.example.trufi_core_maps',
          tileBuilder: widget.useDarkModeFilter ? fm.darkModeTileBuilder : null,
        ),
        // Polylines rendered first (below markers)
        fm.PolylineLayer(
          polylines: [
            for (final layer in visibleLayers)
              for (final line in layer.lines)
                fm.Polyline(
                  points: line.position,
                  strokeWidth: line.lineWidth.toDouble(),
                  color: line.color,
                  pattern: line.activeDots
                      ? fm.StrokePattern.dotted()
                      : fm.StrokePattern.solid(),
                ),
          ],
        ),
        // Markers sorted by layerLevel (lower levels rendered first/below)
        for (final layer in visibleLayers)
          fm.MarkerLayer(
            markers: [
              for (final marker
                  in (layer.markers.toList()
                    ..sort((a, b) => a.layerLevel.compareTo(b.layerLevel))))
                () {
                  // Calculate size based on metersRadius if provided
                  double width = marker.size.width;
                  double height = marker.size.height;
                  if (marker.metersRadius != null) {
                    final pixels = _metersToPixels(
                      marker.metersRadius!,
                      marker.position.latitude,
                      camera.zoom,
                    );
                    width = pixels * 2;
                    height = pixels * 2;
                  }
                  return fm.Marker(
                    point: marker.position,
                    width: width,
                    height: height,
                    rotate: true,
                    alignment: marker.alignment,
                    child: marker.widget,
                  );
                }(),
            ],
          ),
      ],
    );
  }
}
