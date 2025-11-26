import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class MovingManyLinesLayer extends TrufiLayer {
  static const String layerId = 'moving-many-lines-layer';

  final Random _random = Random();
  final int nMarkers;
  final int nLines;
  final Duration updateInterval;

  // Coordenada base (Kigali)
  final latlng.LatLng baseCoord = const latlng.LatLng(-1.949516, 30.069619);

  // Widget del marker (círculo azul chico)
  static const Widget _markerWidget = SizedBox(
    width: 14,
    height: 14,
    child: DecoratedBox(
      decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
    ),
  );

  Timer? _timer;

  MovingManyLinesLayer(
    super.controller, {
    this.nMarkers = 100,
    this.nLines = 10,
    this.updateInterval = const Duration(seconds: 1),
  }) : super(id: layerId, layerLevel: 1) {
    _initFeatures();
    _startUpdates();
  }

  /// Crea listas iniciales y las setea en el layer (dispara mutateLayers())
  void _initFeatures() {
    const double offsetRange = 0.02; // ~±2km
    // markers
    final markers = <TrufiMarker>[];
    for (int i = 0; i < nMarkers; i++) {
      final pos = latlng.LatLng(
        baseCoord.latitude + (_random.nextDouble() - 0.5) * offsetRange,
        baseCoord.longitude + (_random.nextDouble() - 0.5) * offsetRange,
      );
      markers.add(
        TrufiMarker(
          id: 'marker_$i',
          position: pos,
          widget: _markerWidget,
          size: const Size(14, 14),
        ),
      );
    }
    setMarkers(markers);

    // lines
    final linesList = <TrufiLine>[];
    for (int i = 0; i < nLines; i++) {
      final start = latlng.LatLng(
        baseCoord.latitude + (_random.nextDouble() - 0.5) * offsetRange,
        baseCoord.longitude + (_random.nextDouble() - 0.5) * offsetRange,
      );
      linesList.add(
        TrufiLine(
          id: 'line_$i',
          position: List.generate(
            6,
            (j) => latlng.LatLng(
              start.latitude + j * 0.001,
              start.longitude + j * 0.001,
            ),
          ),
          color: Colors.red,
          lineWidth: 3,
        ),
      );
    }
    setLines(linesList);
  }

  void _startUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(updateInterval, (_) => _updateFeatures());
  }

  /// Reemplaza markers y lines con posiciones movidas aleatoriamente
  void _updateFeatures() {
    const double moveRange = 0.001; // ~±100m

    // Mover todos los markers (clon + reemplazo)
    final movedMarkers = <TrufiMarker>[];
    for (final m in markers) {
      movedMarkers.add(
        TrufiMarker(
          id: m.id,
          position: latlng.LatLng(
            m.position.latitude + (_random.nextDouble() - 0.5) * moveRange,
            m.position.longitude + (_random.nextDouble() - 0.5) * moveRange,
          ),
          widget: m.widget,
          size: m.size,
          rotation: m.rotation,
          layerLevel: m.layerLevel,
          alignment: m.alignment,
          widgetBytes: m.widgetBytes,
          // visible se mantiene igual
          // visible: m.visible,
        ),
      );
    }
    setMarkers(movedMarkers); // notifica

    // Mover todas las líneas (agregar punto al final, recortar a 20)
    final movedLines = <TrufiLine>[];
    for (final line in lines) {
      final last = line.position.last;
      final newPoint = latlng.LatLng(
        last.latitude + (_random.nextDouble() - 0.5) * moveRange,
        last.longitude + (_random.nextDouble() - 0.5) * moveRange,
      );
      final pts = List<latlng.LatLng>.from(line.position)..add(newPoint);
      if (pts.length > 20) pts.removeAt(0);

      movedLines.add(
        TrufiLine(
          id: line.id,
          position: pts,
          color: line.color,
          lineWidth: line.lineWidth,
          activeDots: line.activeDots,
          layerLevel: line.layerLevel,
          visible: line.visible,
        ),
      );
    }
    setLines(movedLines); // notifica (segunda vez en el tick)
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
