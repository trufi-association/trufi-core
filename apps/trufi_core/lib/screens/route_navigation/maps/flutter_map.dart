import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/screens/route_navigation/maps/maplibre_gl.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart'
    as trufi;

class TrufiFlutterMap extends StatefulWidget implements TrufiMapRender {
  const TrufiFlutterMap({
    super.key,
    required this.controller,
    this.onMapClick,
    this.onMapLongClick,
    required this.tileUrl,
  });

  @override
  final trufi.TrufiMapController controller;
  @override
  final void Function(latlng.LatLng)? onMapClick;
  @override
  final void Function(latlng.LatLng)? onMapLongClick;

  final String tileUrl;

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
    final vr = trufi.LatLngBounds(fb.southWest, fb.northEast);
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
        Opacity(opacity: 1, child: fm.TileLayer(urlTemplate: widget.tileUrl)),
        for (final layer in visibleLayers)
          fm.MarkerLayer(
            markers: [
              for (final marker in layer.markers)
                fm.Marker(
                  point: marker.position,
                  width: marker.size.width,
                  height: marker.size.height,
                  rotate: true,
                  alignment: marker.alignment,
                  child: marker.widget,
                ),
            ],
          ),
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
      ],
    );
  }
}
