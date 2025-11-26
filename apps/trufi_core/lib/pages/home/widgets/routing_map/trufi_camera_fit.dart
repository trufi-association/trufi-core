import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class TrufiCameraFit {
  static const double _tileSize = 256.0;
  static const double _maxLat = 85.05112878;

  static Offset _project(latlng.LatLng llg, double zoom) {
    final lat = llg.latitude.clamp(-_maxLat, _maxLat);
    final lon = llg.longitude;
    final x = (lon + 180.0) / 360.0;
    final s = math.sin(lat * math.pi / 180.0);
    final y = 0.5 - math.log((1 + s) / (1 - s)) / (4 * math.pi);
    final scale = _tileSize * math.pow(2.0, zoom);
    return Offset(x * scale, y * scale);
  }

  static latlng.LatLng _unproject(Offset p, double zoom) {
    final scale = _tileSize * math.pow(2.0, zoom);
    final x = (p.dx / scale) - 0.5;
    final y = 0.5 - (p.dy / scale);
    final lat =
        90.0 - 360.0 * math.atan(math.exp(-y * 2.0 * math.pi)) / math.pi;
    final lon = 360.0 * x;
    return latlng.LatLng(lat, lon);
  }

  static double _getScaleZoom(double baseZoom, double scale) {
    return baseZoom + math.log(scale) / math.ln2;
  }

  static LatLngBounds computeVisibleRegion(TrufiCameraPosition cam) {
    final size = cam.viewportSize!;
    final halfW = size.width / 2.0;
    final halfH = size.height / 2.0;
    final centerPx = _project(cam.target, cam.zoom);

    final topLeft = centerPx + Offset(-halfW, -halfH);
    final bottomRight = centerPx + Offset(halfW, halfH);

    final sw = _unproject(Offset(topLeft.dx, bottomRight.dy), cam.zoom);
    final ne = _unproject(Offset(bottomRight.dx, topLeft.dy), cam.zoom);
    return LatLngBounds(sw, ne);
  }

  static _FitResult _fitBounds({
    required Size viewportSizePx,
    required latlng.LatLng southWest,
    required latlng.LatLng northEast,
    required double baseZoomForCalc,
    EdgeInsets padding = EdgeInsets.zero,
    double minZoom = 0,
    double? maxZoom,
    bool forceIntZoom = false,
  }) {
    final effW = math.max(
      0.0,
      viewportSizePx.width - padding.left - padding.right,
    );
    final effH = math.max(
      0.0,
      viewportSizePx.height - padding.top - padding.bottom,
    );

    final pSW = _project(southWest, baseZoomForCalc);
    final pNE = _project(northEast, baseZoomForCalc);

    final left = math.min(pSW.dx, pNE.dx);
    final right = math.max(pSW.dx, pNE.dx);
    final top = math.min(pSW.dy, pNE.dy);
    final bottom = math.max(pSW.dy, pNE.dy);
    final bb = Rect.fromLTRB(left, top, right, bottom);

    final bw = math.max(1.0, bb.width);
    final bh = math.max(1.0, bb.height);

    final scaleX = effW / bw;
    final scaleY = effH / bh;
    final scale = math.min(scaleX, scaleY);

    var newZoom = _getScaleZoom(baseZoomForCalc, scale);
    if (forceIntZoom) newZoom = newZoom.floorToDouble();
    if (maxZoom != null) newZoom = math.min(newZoom, maxZoom);
    newZoom = math.max(minZoom, newZoom);

    final pSWz = _project(southWest, newZoom);
    final pNEz = _project(northEast, newZoom);
    final centerPx = Offset(
      (pSWz.dx + pNEz.dx) / 2.0 + (padding.right - padding.left) / 2.0,
      (pSWz.dy + pNEz.dy) / 2.0 + (padding.bottom - padding.top) / 2.0,
    );
    final center = _unproject(centerPx, newZoom);

    return _FitResult(center, newZoom);
  }

  static TrufiCameraPosition fitBoundsOnCamera({
    required TrufiCameraPosition camera,
    required LatLngBounds bounds,
    EdgeInsets padding = EdgeInsets.zero,
    double minZoom = 0,
    double? maxZoom,
    bool forceIntZoom = false,
  }) {
    if (camera.viewportSize == null) {
      final center = latlng.LatLng(
        (bounds.southWest.latitude + bounds.northEast.latitude) / 2.0,
        (bounds.southWest.longitude + bounds.northEast.longitude) / 2.0,
      );
      return camera.copyWith(target: center);
    }

    final fit = _fitBounds(
      viewportSizePx: camera.viewportSize!,
      southWest: bounds.southWest,
      northEast: bounds.northEast,
      baseZoomForCalc: camera.zoom,
      padding: padding,
      minZoom: minZoom,
      maxZoom: maxZoom,
      forceIntZoom: forceIntZoom,
    );

    return camera.copyWith(target: fit.target, zoom: fit.zoom);
  }
}

class _FitResult {
  final latlng.LatLng target;
  final double zoom;
  const _FitResult(this.target, this.zoom);
}
