import 'package:flutter/material.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// State holder that produces line data for a debug tile grid overlay.
///
/// Unlike the old imperative approach, this class computes grid lines
/// from the current camera and returns them as data. The host widget
/// calls [updateFromCamera] whenever the camera changes and reads [lines].
class DebugGridLayer {
  static const String layerId = 'debug-grid-layer';

  int _granularityLevels = 0;
  bool _visible = false;
  final Set<String> _drawnBoxes = <String>{};
  List<TrufiLine> _lines = [];

  /// Callback invoked when lines change so the host can call setState.
  VoidCallback? onUpdate;

  bool get visible => _visible;

  int get granularityLevels => _granularityLevels;

  set granularityLevels(int value) {
    if (_granularityLevels == value) return;
    _granularityLevels = value;
    _drawnBoxes.clear();
    _lines = [];
  }

  /// Current line data to pass into a TrufiLayer.
  List<TrufiLine> get lines => _lines;

  void setVisible(bool value) {
    if (_visible == value) return;
    _visible = value;
    if (!_visible) {
      _drawnBoxes.clear();
      _lines = [];
    }
    onUpdate?.call();
  }

  /// Recompute grid lines for the given camera position.
  void updateFromCamera(TrufiCameraPosition cam) {
    if (!_visible) return;

    final z = cam.zoom.floor();

    final bounds =
        cam.visibleRegion ??
        TileUtils.approxBoundsAround(cam.target, meters: 800);

    final tiles = TileUtils.tilesForBounds(
      bounds: bounds,
      zoom: z,
      granularityLevels: _granularityLevels,
    );

    final newLines = <TrufiLine>[];

    for (final t in tiles) {
      final tileId = 'grid-${t.z}-${t.x}-${t.y}-g$_granularityLevels';
      if (_drawnBoxes.contains(tileId)) continue;

      final outline = TileUtils.tileOutline(x: t.x, y: t.y, z: t.z);
      newLines.add(
        TrufiLine(
          id: tileId,
          position: outline,
          activeDots: false,
          color: Colors.red.withValues(alpha: 0.6),
          layerLevel: 10,
          lineWidth: 2,
        ),
      );
      _drawnBoxes.add(tileId);
    }

    if (newLines.isNotEmpty) {
      _lines = [..._lines, ...newLines];
      onUpdate?.call();
    }
  }
}
