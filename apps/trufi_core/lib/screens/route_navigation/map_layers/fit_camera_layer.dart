import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

abstract class IFitCameraLayer extends TrufiLayer {
  IFitCameraLayer(
    super.controller, {
    required super.id,
    required super.layerLevel,
  });
  void updateViewport(Size logicalSize, EdgeInsets viewPadding);
  void fitBoundsOnCamera(List<latlng.LatLng> points);
  void updatePadding(EdgeInsets padding, {bool recenter = true});
  void reFitCamera();

  final double minZoom = 2.0;
  final double maxZoom = 20.0;
  final ValueNotifier<bool> outOfFocusNotifier = ValueNotifier<bool>(false);
}

class FitCameraLayer extends IFitCameraLayer {
  static const String layerId = 'fit-camera-layer';

  final double tileSize = 256;
  EdgeInsets _padding;
  EdgeInsets _viewPadding = EdgeInsets.zero;
  bool showCornerDots;
  bool debugFlag;

  /// Device pixel ratio (logical -> CSS px). Si luego expones DPR, actualiza aquí.
  final double _dpr = 1.0;
  Size _viewportLogical = Size.zero;

  /// BBox actual a encuadrar (máximo 4 esquinas).
  _FitBounds? _fitBounds;

  /// Margen anti-parpadeo en px (CSS) para el test de dentro/fuera
  double focusSlackCss = 4.0;

  late final VoidCallback _cameraListener;

  FitCameraLayer(
    super.controller, {
    EdgeInsets padding = EdgeInsets.zero,
    this.showCornerDots = false,
    this.debugFlag = false,
  }) : _padding = padding,
       super(id: layerId, layerLevel: 9) {
    _cameraListener = _computeAndRender;
    controller.cameraPositionNotifier.addListener(_cameraListener);
    _computeAndRender();
  }

  @override
  void dispose() {
    controller.cameraPositionNotifier.removeListener(_cameraListener);
    outOfFocusNotifier.dispose();
    super.dispose();
  }

  /// === API pública de conveniencia ===
  /// Reemplaza los puntos y (opcional) re-centra la cámara a su bbox.
  void setFitPoints(
    List<latlng.LatLng> points, {
    bool recenter = true,
    double minZoom = 2.0,
    double maxZoom = 20.0,
  }) {
    _fitBounds = _computeBounds(points);
    if (recenter && _fitBounds != null) {
      _applyCameraForBounds(_fitBounds!, minZoom: minZoom, maxZoom: maxZoom);
    } else {
      _computeAndRender();
    }
  }

  /// Re-encuadra la cámara al bbox actual (si existe).
  @override
  void reFitCamera({double minZoom = 2.0, double maxZoom = 20.0}) {
    if (_fitBounds == null) return;
    _applyCameraForBounds(_fitBounds!, minZoom: minZoom, maxZoom: maxZoom);
  }

  @override
  void updateViewport(Size logicalSize, EdgeInsets viewPadding) {
    if (logicalSize.width <= 0 || logicalSize.height <= 0) return;
    _viewportLogical = logicalSize;
    _viewPadding = viewPadding;
    controller.setViewportSize(logicalSize);
    _computeAndRender();
  }

  @override
  void updatePadding(EdgeInsets padding, {bool recenter = true}) {
    if (_padding == padding) return;

    _padding = padding;
    if (recenter && _fitBounds != null && !outOfFocusNotifier.value) {
      reFitCamera();
    }
  }

  void clearFitPoints() {
    _fitBounds = null;
    _computeAndRender();
  }

  // ======= Utilidades de proyección WebMercator =======
  static const _maxLat = 85.05112878;

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

  Widget _dot(Color c) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: c,
      shape: BoxShape.circle,
      boxShadow: const [
        BoxShadow(blurRadius: 4, offset: Offset(0, 1), color: Colors.black26),
      ],
    ),
  );

  final Widget _fitDot = Container(
    width: 10,
    height: 10,
    decoration: const BoxDecoration(
      color: Colors.pink,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(blurRadius: 4, offset: Offset(0, 1), color: Colors.black26),
      ],
    ),
  );

  // ======= Render principal =======
  void _computeAndRender() {
    final cam = controller.cameraPositionNotifier.value;
    if (_viewportLogical == Size.zero) {
      setLines(const []);
      setMarkers(const []);
      _updateOutOfFocusAsync(false);
      return;
    }

    final combinedInset = EdgeInsets.only(
      top: _viewPadding.top + _padding.top,
      right: _viewPadding.right + _padding.right,
      bottom: _viewPadding.bottom + _padding.bottom,
      left: _viewPadding.left + _padding.left,
    );

    final center = cam.target;
    final zoom = cam.zoom;
    final theta = cam.bearing * math.pi / 180.0;
    final cosT = math.cos(theta);
    final sinT = math.sin(theta);

    final Wcss = math.max(
      1.0,
      (_viewportLogical.width - combinedInset.left - combinedInset.right) *
          _dpr,
    );
    final Hcss = math.max(
      1.0,
      (_viewportLogical.height - combinedInset.top - combinedInset.bottom) *
          _dpr,
    );

    final cx0 = _lngToMercX(center.longitude);
    final cy0 = _latToMercY(center.latitude);

    final worldPx = tileSize * math.pow(2.0, zoom);
    final mercPerCssPx = 1.0 / worldPx;

    final shiftMercXLocal =
        ((combinedInset.left - combinedInset.right) * 0.5 * _dpr) *
        mercPerCssPx;
    final shiftMercYLocal =
        ((combinedInset.top - combinedInset.bottom) * 0.5 * _dpr) *
        mercPerCssPx;

    final shiftMercX = shiftMercXLocal * cosT - shiftMercYLocal * sinT;
    final shiftMercY = shiftMercXLocal * sinT + shiftMercYLocal * cosT;

    final cx = cx0 + shiftMercX;
    final cy = cy0 + shiftMercY;

    final halfW = (Wcss / 2.0) * mercPerCssPx;
    final halfH = (Hcss / 2.0) * mercPerCssPx;

    // Esquinas del rectángulo visible (para debug)
    final cornersLocal = <Offset>[
      Offset(-halfW, -halfH),
      Offset(halfW, -halfH),
      Offset(halfW, halfH),
      Offset(-halfW, halfH),
    ];

    latlng.LatLng toLatLng(Offset d) {
      final rx = d.dx * cosT - d.dy * sinT;
      final ry = d.dx * sinT + d.dy * cosT;
      final x = cx + rx;
      final y = cy + ry;
      return latlng.LatLng(_mercYToLat(y), _mercXToLng(x));
    }

    final tl = toLatLng(cornersLocal[0]);
    final tr = toLatLng(cornersLocal[1]);
    final br = toLatLng(cornersLocal[2]);
    final bl = toLatLng(cornersLocal[3]);

    final rect = <latlng.LatLng>[bl, tl, tr, br, bl];

    // Estado de foco (si hay bbox activo)
    final bool anyOutside = _isBBoxOutside(
      cx: cx,
      cy: cy,
      cosT: cosT,
      sinT: sinT,
      halfW: halfW,
      halfH: halfH,
      mercPerCssPx: mercPerCssPx,
    );
    _updateOutOfFocusAsync(anyOutside);

    // Debug draw
    if (debugFlag) {
      final lines = <TrufiLine>[
        TrufiLine(
          id: '$id:viewport-rect',
          position: rect,
          color: Colors.cyan.withOpacity(0.9),
          lineWidth: 3,
          layerLevel: layerLevel,
        ),
        if (_fitBounds != null)
          TrufiLine(
            id: '$id:fit-bbox',
            position: [
              _fitBounds!.corners[0], // bl
              _fitBounds!.corners[1], // tl
              _fitBounds!.corners[2], // tr
              _fitBounds!.corners[3], // br
              _fitBounds!.corners[0], // bl
            ],
            color: Colors.pink.withOpacity(0.7),
            lineWidth: 2,
            layerLevel: layerLevel,
          ),
      ];

      final markers = <TrufiMarker>[
        if (showCornerDots) ...[
          TrufiMarker(
            id: '$id:tl',
            position: tl,
            widget: _dot(Colors.amber),
            layerLevel: layerLevel,
            size: const Size(10, 10),
          ),
          TrufiMarker(
            id: '$id:tr',
            position: tr,
            widget: _dot(Colors.amber),
            layerLevel: layerLevel,
            size: const Size(10, 10),
          ),
          TrufiMarker(
            id: '$id:br',
            position: br,
            widget: _dot(Colors.amber),
            layerLevel: layerLevel,
            size: const Size(10, 10),
          ),
          TrufiMarker(
            id: '$id:bl',
            position: bl,
            widget: _dot(Colors.amber),
            layerLevel: layerLevel,
            size: const Size(10, 10),
          ),
        ],
        if (_fitBounds != null)
          for (int i = 0; i < 4; i++)
            TrufiMarker(
              id: '$id:fitCorner:$i',
              position: _fitBounds!.corners[i],
              widget: _fitDot,
              layerLevel: layerLevel,
              size: const Size(10, 10),
            ),
      ];

      setLines(lines);
      setMarkers(markers);
    } else {
      setLines(const []);
      setMarkers(const []);
    }
  }

  // ======= Lógica de “fuera de foco” usando solo las 4 esquinas del bbox =======
  bool _isBBoxOutside({
    required double cx,
    required double cy,
    required double cosT,
    required double sinT,
    required double halfW,
    required double halfH,
    required double mercPerCssPx,
  }) {
    if (_fitBounds == null) return false;

    final double slackMerc = (focusSlackCss * _dpr) * mercPerCssPx;

    bool testLatLng(latlng.LatLng p) {
      final x = _lngToMercX(p.longitude);
      final y = _latToMercY(p.latitude);

      double dx = x - cx;
      if (dx > 0.5) dx -= 1.0; // wrap antimeridiano
      if (dx < -0.5) dx += 1.0;
      final dy = y - cy;

      // coords locales (des-rotadas)
      final localX = dx * cosT + dy * sinT;
      final localY = -dx * sinT + dy * cosT;

      final insideX =
          (localX >= -halfW - slackMerc) && (localX <= halfW + slackMerc);
      final insideY =
          (localY >= -halfH - slackMerc) && (localY <= halfH + slackMerc);
      return insideX && insideY;
    }

    // Si alguna esquina del bbox está fuera, marcamos fuera de foco.
    for (final corner in _fitBounds!.corners) {
      if (!testLatLng(corner)) return true;
    }
    return false;
  }

  // ======= Encadre de cámara usando solo bbox =======
  @override
  void fitBoundsOnCamera(
    List<latlng.LatLng> points, {
    double minZoom = 2.0,
    double maxZoom = 20.0,
  }) {
    if (points.isEmpty || _viewportLogical == Size.zero) {
      _fitBounds = null;
      _computeAndRender();
      return;
    }
    _fitBounds = _computeBounds(points);
    _applyCameraForBounds(_fitBounds!, minZoom: minZoom, maxZoom: maxZoom);
  }

  void _applyCameraForBounds(
    _FitBounds fb, {
    required double minZoom,
    required double maxZoom,
  }) {
    final cam = controller.cameraPositionNotifier.value;
    final theta = cam.bearing * math.pi / 180.0;
    final absCos = math.cos(theta).abs();
    final absSin = math.sin(theta).abs();

    final combinedInset = EdgeInsets.only(
      top: _viewPadding.top + _padding.top,
      right: _viewPadding.right + _padding.right,
      bottom: _viewPadding.bottom + _padding.bottom,
      left: _viewPadding.left + _padding.left,
    );

    final Wcss = math.max(
      1.0,
      (_viewportLogical.width - combinedInset.left - combinedInset.right) *
          _dpr,
    );
    final Hcss = math.max(
      1.0,
      (_viewportLogical.height - combinedInset.top - combinedInset.bottom) *
          _dpr,
    );

    // Proyección del viewport rotado al bbox axis-aligned
    final Wproj = Wcss * absCos + Hcss * absSin;
    final Hproj = Wcss * absSin + Hcss * absCos;

    final zX = math.log(Wproj / (tileSize * fb.dx)) / math.ln2;
    final zY = math.log(Hproj / (tileSize * fb.dy)) / math.ln2;
    final zoom = _zoomClamp(
      (zX.isFinite && zY.isFinite) ? math.min(zX, zY) : cam.zoom,
      minZoom,
      maxZoom,
    );

    final worldPx = tileSize * math.pow(2.0, zoom);
    final mercPerCssPx = 1.0 / worldPx;

    final shiftXLocal =
        ((combinedInset.left - combinedInset.right) * 0.5 * _dpr) *
        mercPerCssPx;
    final shiftYLocal =
        ((combinedInset.top - combinedInset.bottom) * 0.5 * _dpr) *
        mercPerCssPx;

    final shiftX =
        shiftXLocal * math.cos(theta) - shiftYLocal * math.sin(theta);
    final shiftY =
        shiftXLocal * math.sin(theta) + shiftYLocal * math.cos(theta);

    final cxc = _norm01(fb.cx - shiftX);
    final cyc = (fb.cy - shiftY).clamp(0.0, 1.0);

    final target = latlng.LatLng(_mercYToLat(cyc), _mercXToLng(cxc));

    controller.updateCamera(target: target, zoom: zoom);
    _computeAndRender();
  }

  double _zoomClamp(double z, double minZ, double maxZ) {
    if (z < minZ) return minZ;
    if (z > maxZ) return maxZ;
    return z;
  }

  void _updateOutOfFocusAsync(bool newValue) {
    if (outOfFocusNotifier.value == newValue) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (outOfFocusNotifier.value != newValue) {
        outOfFocusNotifier.value = newValue;
      }
    });
  }

  // ======= Cálculo de bbox (máximo 4 puntos) =======
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

    // Resolver antimeridiano como en tu implementación original
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

    // Esquinas del bbox axis-aligned en Mercator
    final double leftX = _norm01(cx - dx / 2.0);
    final double rightX = _norm01(cx + dx / 2.0);
    final double botY = cy - dy / 2.0;
    final double topY = cy + dy / 2.0;

    final corners = <latlng.LatLng>[
      latlng.LatLng(_mercYToLat(botY), _mercXToLng(leftX)), // bl
      latlng.LatLng(_mercYToLat(topY), _mercXToLng(leftX)), // tl
      latlng.LatLng(_mercYToLat(topY), _mercXToLng(rightX)), // tr
      latlng.LatLng(_mercYToLat(botY), _mercXToLng(rightX)), // br
    ];

    return _FitBounds(cx, cy, dx, dy, corners);
  }
}

/// Contenedor de bbox mínimo (en Mercator) y sus 4 esquinas LatLng.
class _FitBounds {
  final double cx, cy; // centro en Mercator (0..1)
  final double dx, dy; // spans en Mercator
  final List<latlng.LatLng> corners; // [bl, tl, tr, br]
  const _FitBounds(this.cx, this.cy, this.dx, this.dy, this.corners);
}
