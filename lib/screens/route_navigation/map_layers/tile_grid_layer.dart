import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/cached_first_fetch.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/tile_utils.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:vector_tile/vector_tile.dart';

class TileGrid<T> {
  TileGrid({
    required this.layer,
    required this.uriTemplate,
    required this.fromGeoJsonPoint,
    required this.onFetchElements,
    this.granularityLevels = 0,
    this.color = Colors.blue,
    this.showGrid = false,
  }) {
    layer.controller.cameraPositionNotifier.addListener(_onCameraChanged);
  }

  final TrufiLayer layer;
  final int granularityLevels;
  final Color color;
  final Set<String> _drawnBoxes = <String>{};
  final bool showGrid;
  final String uriTemplate;
  final T? Function(GeoJsonPoint) fromGeoJsonPoint;
  final void Function(List<T>) onFetchElements;

  void dispose() {
    layer.controller.cameraPositionNotifier.removeListener(_onCameraChanged);
  }

  void _onCameraChanged() {
    final cam = layer.controller.cameraPositionNotifier.value;
    final z = cam.zoom.floor();

    final bounds =
        cam.visibleRegion ??
        TileUtils.approxBoundsAround(cam.target, meters: 800);

    final tiles = TileUtils.tilesForBounds(
      bounds: bounds,
      zoom: z,
      granularityLevels: granularityLevels,
    );

    final newLines = <TrufiLine>[];
    Future.wait([for (final t in tiles) fetchPBF(t.z, t.x, t.y)])
        .then((results) {
          final elements = results.expand((e) => e).toList();
          onFetchElements(elements);
        })
        .catchError((error) {
          debugPrint("Batch error: $error");
        });

    if (!showGrid) return;

    for (final t in tiles) {
      final id = 'box-${layer.id}-${layer.id}-${t.z}-${t.x}-${t.y}';
      if (_drawnBoxes.contains(id)) continue;
      final outline = TileUtils.tileOutline(x: t.x, y: t.y, z: t.z);
      newLines.add(
        TrufiLine(
          id: id,
          position: outline,
          activeDots: false,
          color: color,
          layerLevel: 5,
          lineWidth: 2,
        ),
      );
      _drawnBoxes.add(id);
    }

    if (newLines.isNotEmpty) {
      layer.addLines(newLines);
    }
  }

  Future<List<T>> fetchPBF(int z, int x, int y) async {
    try {
      final replaced = uriTemplate
          .replaceAll('{z}', '$z')
          .replaceAll('{x}', '$x')
          .replaceAll('{y}', '$y');
      final uri = Uri.parse(replaced);

      final Uint8List bodyByte = await cachedFirstFetch(uri, z, x, y);
      final tile = VectorTile.fromBytes(bytes: bodyByte);

      final markersToAdd = <T>[];

      for (final VectorTileLayer layer in tile.layers) {
        for (final VectorTileFeature feature in layer.features) {
          feature.decodeGeometry();

          if (feature.geometryType != GeometryType.Point) {
            throw Exception("Unexpected geometry type. Expected Point.");
          }

          final geojson = feature.toGeoJson<GeoJsonPoint>(x: x, y: y, z: z);
          if (geojson == null) continue;
          final element = fromGeoJsonPoint(geojson);
          if (element == null) continue;
          markersToAdd.add(element);
        }
      }
      return markersToAdd;
    } catch (e) {
      print("Error in fetchPBF: $e");
      return [];
    }
  }
}
