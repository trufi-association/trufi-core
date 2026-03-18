import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../entities/bounds.dart';
import '../entities/camera.dart';
import '../entities/marker.dart';
import '../entities/line.dart';
import '../../presentation/utils/trufi_camera_fit.dart';

/// Utility for fitting the camera to a set of points and detecting out-of-focus state.
///
/// Unlike the old abstract-layer approach, this is a pure computation class.
/// Use it to compute camera positions and debug overlays declaratively:
///
/// ```dart
/// final fitCamera = FitCameraUtil(padding: EdgeInsets.all(40));
///
/// // Compute camera that fits all points
/// final newCam = fitCamera.cameraForPoints(points, currentCamera);
///
/// // Check if points are visible
/// final outOfFocus = fitCamera.isOutOfFocus(currentCamera, points);
///
/// // Get debug overlay layers (optional)
/// final debugLayer = fitCamera.debugLayer(currentCamera);
/// ```
class FitCameraUtil {
  FitCameraUtil({
    this.padding = EdgeInsets.zero,
    this.showCornerDots = false,
    this.debugFlag = false,
    this.focusSlackCss = 4.0,
  });

  EdgeInsets padding;
  EdgeInsets _viewPadding = EdgeInsets.zero;
  bool showCornerDots;
  bool debugFlag;
  double focusSlackCss;

  Size _viewportLogical = Size.zero;
  _FitBounds? _fitBounds;

  static const double _maxLat = 85.05112878;
  final double tileSize = 256;

  void updateViewport(Size logicalSize, EdgeInsets viewPadding) {
    if (logicalSize.width <= 0 || logicalSize.height <= 0) return;
    _viewportLogical = logicalSize;
    _viewPadding = viewPadding;
  }

  void updatePadding(EdgeInsets newPadding) {
    padding = newPadding;
  }

  /// Compute a camera position that fits the given points.
  /// Returns null if viewport is not set or points are empty.
  TrufiCameraPosition? cameraForPoints(
    List<latlng.LatLng> points,
    TrufiCameraPosition currentCamera, {
    double minZoom = 2.0,
    double maxZoom = 20.0,
  }) {
    if (points.isEmpty || _viewportLogical == Size.zero) return null;
    _fitBounds = _computeBounds(points);
    if (_fitBounds == null) return null;
    return _applyCameraForBounds(
      _fitBounds!,
      currentCamera,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
  }

  /// Re-fit to the last set of points.
  TrufiCameraPosition? reFitCamera(
    TrufiCameraPosition currentCamera, {
    double minZoom = 2.0,
    double maxZoom = 20.0,
  }) {
    if (_fitBounds == null) return null;
    return _applyCameraForBounds(
      _fitBounds!,
      currentCamera,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
  }

  /// Check if the fit bounds are outside the visible viewport.
  bool isOutOfFocus(TrufiCameraPosition camera) {
    if (_fitBounds == null || _viewportLogical == Size.zero) return false;

    final combinedInset = _combinedInset();
    final center = camera.target;
    final zoom = camera.zoom;
    final theta = camera.bearing * math.pi / 180.0;
    final cosT = math.cos(theta);
    final sinT = math.sin(theta);

    final wCss = math.max(
      1.0,
      _viewportLogical.width - combinedInset.left - combinedInset.right,
    );
    final hCss = math.max(
      1.0,
      _viewportLogical.height - combinedInset.top - combinedInset.bottom,
    );

    final cx0 = _lngToMercX(center.longitude);
    final cy0 = _latToMercY(center.latitude);
    final worldPx = tileSize * math.pow(2.0, zoom);
    final mercPerCssPx = 1.0 / worldPx;

    final shiftMercXLocal =
        ((combinedInset.left - combinedInset.right) * 0.5) * mercPerCssPx;
    final shiftMercYLocal =
        ((combinedInset.top - combinedInset.bottom) * 0.5) * mercPerCssPx;
    final shiftMercX = shiftMercXLocal * cosT - shiftMercYLocal * sinT;
    final shiftMercY = shiftMercXLocal * sinT + shiftMercYLocal * cosT;

    final cx = cx0 + shiftMercX;
    final cy = cy0 + shiftMercY;
    final halfW = (wCss / 2.0) * mercPerCssPx;
    final halfH = (hCss / 2.0) * mercPerCssPx;

    final cornersLocal = <Offset>[
      Offset(-halfW, -halfH),
      Offset(halfW, -halfH),
      Offset(halfW, halfH),
      Offset(-halfW, halfH),
    ];

    latlng.LatLng toLatLng(Offset d) {
      final rx = d.dx * cosT - d.dy * sinT;
      final ry = d.dx * sinT + d.dy * cosT;
      return latlng.LatLng(_mercYToLat(cy + ry), _mercXToLng(cx + rx));
    }

    final bl = toLatLng(cornersLocal[3]);
    final tr = toLatLng(cornersLocal[1]);

    return _isBBoxOutside(viewportSW: bl, viewportNE: tr);
  }

  /// Get debug markers and lines for visualization. Returns a TrufiLayer.
  ({List<TrufiMarker> markers, List<TrufiLine> lines}) debugOverlay(
    TrufiCameraPosition camera, {
    int layerLevel = 9,
  }) {
    if (!debugFlag || _viewportLogical == Size.zero) {
      return (markers: const [], lines: const []);
    }

    final combinedInset = _combinedInset();
    final center = camera.target;
    final zoom = camera.zoom;
    final theta = camera.bearing * math.pi / 180.0;
    final cosT = math.cos(theta);
    final sinT = math.sin(theta);

    final wCss = math.max(
      1.0,
      _viewportLogical.width - combinedInset.left - combinedInset.right,
    );
    final hCss = math.max(
      1.0,
      _viewportLogical.height - combinedInset.top - combinedInset.bottom,
    );

    final cx0 = _lngToMercX(center.longitude);
    final cy0 = _latToMercY(center.latitude);
    final worldPx = tileSize * math.pow(2.0, zoom);
    final mercPerCssPx = 1.0 / worldPx;

    final shiftMercXLocal =
        ((combinedInset.left - combinedInset.right) * 0.5) * mercPerCssPx;
    final shiftMercYLocal =
        ((combinedInset.top - combinedInset.bottom) * 0.5) * mercPerCssPx;
    final shiftMercX = shiftMercXLocal * cosT - shiftMercYLocal * sinT;
    final shiftMercY = shiftMercXLocal * sinT + shiftMercYLocal * cosT;

    final cx = cx0 + shiftMercX;
    final cy = cy0 + shiftMercY;
    final halfW = (wCss / 2.0) * mercPerCssPx;
    final halfH = (hCss / 2.0) * mercPerCssPx;

    final cornersLocal = <Offset>[
      Offset(-halfW, -halfH),
      Offset(halfW, -halfH),
      Offset(halfW, halfH),
      Offset(-halfW, halfH),
    ];

    latlng.LatLng toLatLng(Offset d) {
      final rx = d.dx * cosT - d.dy * sinT;
      final ry = d.dx * sinT + d.dy * cosT;
      return latlng.LatLng(_mercYToLat(cy + ry), _mercXToLng(cx + rx));
    }

    final tl = toLatLng(cornersLocal[0]);
    final tr = toLatLng(cornersLocal[1]);
    final br = toLatLng(cornersLocal[2]);
    final bl = toLatLng(cornersLocal[3]);
    final rect = <latlng.LatLng>[bl, tl, tr, br, bl];

    final lines = <TrufiLine>[
      TrufiLine(
        id: 'fit-camera:viewport-rect',
        position: rect,
        color: Colors.green.withValues(alpha: 0.9),
        lineWidth: 8,
        layerLevel: layerLevel,
      ),
      if (_fitBounds != null)
        TrufiLine(
          id: 'fit-camera:fit-bbox',
          position: [
            _fitBounds!.corners[0],
            _fitBounds!.corners[1],
            _fitBounds!.corners[2],
            _fitBounds!.corners[3],
            _fitBounds!.corners[0],
          ],
          color: Colors.pink.withValues(alpha: 0.9),
          lineWidth: 6,
          layerLevel: layerLevel,
        ),
    ];

    final markers = <TrufiMarker>[
      if (showCornerDots) ...[
        for (final entry in [
          ('tl', tl),
          ('tr', tr),
          ('br', br),
          ('bl', bl),
        ])
          TrufiMarker(
            id: 'fit-camera:${entry.$1}',
            position: entry.$2,
            widget: _dot(Colors.amber),
            layerLevel: layerLevel,
            size: const Size(10, 10),
          ),
      ],
      if (_fitBounds != null)
        for (int i = 0; i < 4; i++)
          TrufiMarker(
            id: 'fit-camera:fitCorner:$i',
            position: _fitBounds!.corners[i],
            widget: _fitDot,
            layerLevel: layerLevel,
            size: const Size(10, 10),
          ),
    ];

    return (markers: markers, lines: lines);
  }

  void clearFitPoints() => _fitBounds = null;

  // ─── Private helpers ───

  EdgeInsets _combinedInset() => EdgeInsets.only(
        top: _viewPadding.top + padding.top,
        right: _viewPadding.right + padding.right,
        bottom: _viewPadding.bottom + padding.bottom,
        left: _viewPadding.left + padding.left,
      );

  TrufiCameraPosition _applyCameraForBounds(
    _FitBounds fb,
    TrufiCameraPosition currentCamera, {
    required double minZoom,
    required double maxZoom,
  }) {
    final bounds = LatLngBounds(fb.corners[0], fb.corners[2]);
    final combinedPadding = _combinedInset();
    final newCam = TrufiCameraFit.fitBoundsOnCamera(
      camera: currentCamera.copyWith(viewportSize: _viewportLogical),
      bounds: bounds,
      padding: combinedPadding,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    return newCam;
  }

  bool _isBBoxOutside({
    required latlng.LatLng viewportSW,
    required latlng.LatLng viewportNE,
  }) {
    if (_fitBounds == null) return false;
    final fitSW = _fitBounds!.corners[0];
    final fitNE = _fitBounds!.corners[2];
    final slackLat = focusSlackCss * 0.0001;
    final slackLng = focusSlackCss * 0.0001;
    final containsLat = fitSW.latitude >= (viewportSW.latitude - slackLat) &&
        fitNE.latitude <= (viewportNE.latitude + slackLat);
    final containsLng =
        fitSW.longitude >= (viewportSW.longitude - slackLng) &&
        fitNE.longitude <= (viewportNE.longitude + slackLng);
    return !(containsLat && containsLng);
  }

  _FitBounds? _computeBounds(List<latlng.LatLng> points) {
    if (points.isEmpty) return null;
    double xMin = double.infinity, xMax = -double.infinity;
    double yMin = double.infinity, yMax = -double.infinity;
    final xs = <double>[], ys = <double>[];
    for (final p in points) {
      final x = _lngToMercX(p.longitude);
      final y = _latToMercY(p.latitude);
      xs.add(x);
      ys.add(y);
      if (x < xMin) xMin = x;
      if (x > xMax) xMax = x;
      if (y < yMin) yMin = y;
      if (y > yMax) yMax = y;
    }
    double spanX = xMax - xMin;
    double cx, dx;
    if (spanX <= 0.5) {
      dx = math.max(spanX, 1e-12);
      cx = (xMin + xMax) / 2.0;
    } else {
      double xMin2 = double.infinity, xMax2 = -double.infinity;
      for (final x in xs) {
        final xx = x < 0.5 ? x + 1.0 : x;
        if (xx < xMin2) xMin2 = xx;
        if (xx > xMax2) xMax2 = xx;
      }
      dx = math.max(xMax2 - xMin2, 1e-12);
      cx = _norm01((xMin2 + xMax2) / 2.0);
    }
    final dy = math.max(yMax - yMin, 1e-12);
    final cy = (yMin + yMax) / 2.0;
    final double leftX = _norm01(cx - dx / 2.0);
    final double rightX = _norm01(cx + dx / 2.0);
    final double botY = cy - dy / 2.0;
    final double topY = cy + dy / 2.0;
    final corners = <latlng.LatLng>[
      latlng.LatLng(_mercYToLat(botY), _mercXToLng(leftX)),
      latlng.LatLng(_mercYToLat(topY), _mercXToLng(leftX)),
      latlng.LatLng(_mercYToLat(topY), _mercXToLng(rightX)),
      latlng.LatLng(_mercYToLat(botY), _mercXToLng(rightX)),
    ];
    return _FitBounds(cx, cy, dx, dy, corners);
  }

  double _clamp(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);
  double _lngToMercX(double lngDeg) => (lngDeg + 180.0) / 360.0;
  double _latToMercY(double latDeg) {
    final lat = _clamp(latDeg, -_maxLat, _maxLat);
    final phi = lat * math.pi / 180.0;
    final s = math.tan(phi) + 1 / math.cos(phi);
    return (1 - (math.log(s) / math.pi)) / 2;
  }

  double _mercXToLng(double x) => x * 360.0 - 180.0;
  double _mercYToLat(double y) {
    final n = math.pi - 2.0 * math.pi * y;
    return 180.0 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
  }

  double _norm01(double v) {
    v = v % 1.0;
    if (v < 0) v += 1.0;
    return v;
  }

  static Widget _dot(Color c) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              offset: Offset(0, 1),
              color: Colors.black26,
            ),
          ],
        ),
      );

  static final Widget _fitDot = Container(
    width: 10,
    height: 10,
    decoration: const BoxDecoration(
      color: Colors.pink,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          blurRadius: 4,
          offset: Offset(0, 1),
          color: Colors.black26,
        ),
      ],
    ),
  );
}

class _FitBounds {
  final double cx, cy;
  final double dx, dy;
  final List<latlng.LatLng> corners;
  const _FitBounds(this.cx, this.cy, this.dx, this.dy, this.corners);
}
