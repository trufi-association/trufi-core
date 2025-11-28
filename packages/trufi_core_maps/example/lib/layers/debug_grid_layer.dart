import 'package:flutter/material.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

class DebugGridLayer extends TrufiLayer {
  static const String layerId = 'debug-grid-layer';

  DebugGridLayer(super.controller)
      : super(id: layerId, layerLevel: 10, visible: false) {
    controller.cameraPositionNotifier.addListener(_onCameraChanged);
  }

  int _granularityLevels = 0;
  final Set<String> _drawnBoxes = <String>{};

  int get granularityLevels => _granularityLevels;

  set granularityLevels(int value) {
    if (_granularityLevels == value) return;
    _granularityLevels = value;
    _clearAndRedraw();
  }

  void _clearAndRedraw() {
    _drawnBoxes.clear();
    clearLines();
    _onCameraChanged();
  }

  void _onCameraChanged() {
    if (!visible) return;

    final cam = controller.cameraPositionNotifier.value;
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
          layerLevel: layerLevel,
          lineWidth: 2,
        ),
      );
      _drawnBoxes.add(tileId);
    }

    if (newLines.isNotEmpty) {
      addLines(newLines);
    }
  }

  @override
  void dispose() {
    controller.cameraPositionNotifier.removeListener(_onCameraChanged);
    super.dispose();
  }

  void setVisible(bool value) {
    if (visible == value) return;
    visible = value;
    if (visible) {
      _clearAndRedraw();
    } else {
      _drawnBoxes.clear();
      clearLines();
    }
    mutateLayers();
  }
}
