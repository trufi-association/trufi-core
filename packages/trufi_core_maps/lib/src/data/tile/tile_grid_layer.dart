import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';
import 'package:vector_tile/vector_tile.dart';

import '../../domain/entities/camera.dart';
import '../../domain/entities/line.dart';
import 'cached_fetch.dart';
import 'tile_utils.dart';

/// Fetches and decodes vector tile data based on a camera position.
///
/// This is a stateless utility — call [fetchForCamera] when the camera changes
/// and use the results to build layers declaratively.
///
/// ```dart
/// final grid = TileGrid<MyPoi>(
///   uriTemplate: 'https://tiles.example.com/{z}/{x}/{y}.pbf',
///   fromGeoJsonPoint: (point) => MyPoi.fromGeoJson(point),
/// );
///
/// // In your state management:
/// void onCameraChanged(TrufiCameraPosition camera) async {
///   final pois = await grid.fetchForCamera(camera);
///   setState(() => _pois = pois);
/// }
/// ```
class TileGrid<T> {
  TileGrid({
    required this.uriTemplate,
    required this.fromGeoJsonPoint,
    this.granularityLevels = 0,
    this.showGrid = false,
    this.gridColor = Colors.blue,
    DeviceIdService? deviceIdService,
  }) : _deviceIdService =
           deviceIdService ?? SharedPreferencesDeviceIdService();

  final String uriTemplate;
  final T? Function(GeoJsonPoint) fromGeoJsonPoint;
  final int granularityLevels;
  final bool showGrid;
  final Color gridColor;

  /// Service used to inject the `X-Device-Id` header on every tile fetch.
  /// Defaults to [SharedPreferencesDeviceIdService].
  final DeviceIdService _deviceIdService;

  final Set<String> _drawnBoxes = <String>{};

  /// Fetch elements for the given camera position.
  /// Returns the decoded elements and optional grid lines for debug.
  Future<({List<T> elements, List<TrufiLine> gridLines})> fetchForCamera(
    TrufiCameraPosition camera, {
    String layerId = 'tile-grid',
  }) async {
    final z = camera.zoom.floor();
    final bounds =
        camera.visibleRegion ??
        TileUtils.approxBoundsAround(camera.target, meters: 800);

    final tiles = TileUtils.tilesForBounds(
      bounds: bounds,
      zoom: z,
      granularityLevels: granularityLevels,
    );

    final results = await Future.wait([
      for (final t in tiles) fetchPBF(t.z, t.x, t.y),
    ]);
    final elements = results.expand((e) => e).toList();

    final gridLines = <TrufiLine>[];
    if (showGrid) {
      for (final t in tiles) {
        final id = 'box-$layerId-${t.z}-${t.x}-${t.y}';
        if (_drawnBoxes.contains(id)) continue;
        final outline = TileUtils.tileOutline(x: t.x, y: t.y, z: t.z);
        gridLines.add(
          TrufiLine(
            id: id,
            position: outline,
            activeDots: false,
            color: gridColor,
            layerLevel: 5,
            lineWidth: 2,
          ),
        );
        _drawnBoxes.add(id);
      }
    }

    return (elements: elements, gridLines: gridLines);
  }

  Future<List<T>> fetchPBF(int z, int x, int y) async {
    try {
      final replaced = uriTemplate
          .replaceAll('{z}', '$z')
          .replaceAll('{x}', '$x')
          .replaceAll('{y}', '$y');
      final uri = Uri.parse(replaced);

      final Uint8List bodyByte = await cachedFirstFetch(
        uri,
        z,
        x,
        y,
        deviceIdService: _deviceIdService,
      );
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
      debugPrint("Error in fetchPBF: $e");
      return [];
    }
  }
}
