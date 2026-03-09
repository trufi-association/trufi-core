import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/controller/map_controller.dart';
import '../../domain/entities/camera.dart';
import '../../domain/entities/widget_marker.dart';
import '../../domain/layers/trufi_layer.dart';
import '../../presentation/map/trufi_map.dart';
import 'trufi_map_engine.dart';

/// Configuration for fully offline maps.
class OfflineMapConfig {
  final String mbtilesAsset;
  final String styleAsset;
  final String spritesAssetDir;
  final String fontsAssetDir;
  final Map<String, String> fontMapping;
  final List<String> fontRanges;

  const OfflineMapConfig({
    required this.mbtilesAsset,
    required this.styleAsset,
    required this.spritesAssetDir,
    required this.fontsAssetDir,
    required this.fontMapping,
    required this.fontRanges,
  });
}

/// Offline MapLibre GL engine that uses local mbtiles and style files.
class OfflineMapLibreEngine implements ITrufiMapEngine {
  final OfflineMapConfig config;
  final String? engineId;
  final String? displayName;
  final String? displayDescription;
  final Widget? preview;

  String? _cachedStylePath;
  bool _initialized = false;

  OfflineMapLibreEngine({
    required this.config,
    this.engineId,
    this.displayName,
    this.displayDescription,
    this.preview,
  });

  @override
  String get id => engineId ?? 'offline_maplibre';

  @override
  String get name => displayName ?? 'Offline Map';

  @override
  String get description => displayDescription ?? 'Mapa completamente offline';

  @override
  Widget? get previewWidget =>
      preview ??
      Container(
        color: Colors.green.shade100,
        child: const Center(
          child: Icon(Icons.offline_bolt, size: 40, color: Colors.green),
        ),
      );

  bool get isInitialized => _initialized;
  String? get stylePath => _cachedStylePath;

  Future<String> _copyAsset(String assetPath, String targetPath) async {
    final targetFile = File(targetPath);
    if (await targetFile.exists()) return targetPath;
    await targetFile.parent.create(recursive: true);
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await targetFile.writeAsBytes(bytes, flush: true);
    return targetPath;
  }

  @override
  Future<void> initialize() async {
    if (_initialized && _cachedStylePath != null) return;
    await _initializeOfflineResources();
  }

  Future<String> _initializeOfflineResources() async {
    if (_initialized && _cachedStylePath != null) return _cachedStylePath!;

    final cacheDir = await getApplicationCacheDirectory();
    final offlineDir = Directory('${cacheDir.path}/offline_maps/$id');
    await offlineDir.create(recursive: true);

    final mbtilesPath = await _copyAsset(
      config.mbtilesAsset,
      '${offlineDir.path}/tiles.mbtiles',
    );

    final spritesDir = '${offlineDir.path}/sprites';
    await Directory(spritesDir).create(recursive: true);
    for (final spriteFile in [
      'sprite.json',
      'sprite.png',
      'sprite@2x.json',
      'sprite@2x.png',
    ]) {
      try {
        await _copyAsset(
          '${config.spritesAssetDir}$spriteFile',
          '$spritesDir/$spriteFile',
        );
      } catch (e) {
        debugPrint('Warning: Could not copy sprite file $spriteFile: $e');
      }
    }

    final styleData = await rootBundle.loadString(config.styleAsset);
    final style = json.decode(styleData) as Map<String, dynamic>;

    final Set<List<String>> fontStacks = {};
    if (style.containsKey('layers')) {
      final layers = style['layers'] as List<dynamic>;
      for (final layer in layers) {
        if (layer is Map<String, dynamic> && layer.containsKey('layout')) {
          final layout = layer['layout'] as Map<String, dynamic>;
          if (layout.containsKey('text-font')) {
            final textFont = layout['text-font'];
            if (textFont is List) {
              fontStacks.add(textFont.map((e) => e.toString()).toList());
            }
          }
        }
      }
    }

    final fontsDir = '${offlineDir.path}/fonts';
    for (final entry in config.fontMapping.entries) {
      final assetFontName = entry.key;
      final styleFontName = entry.value;
      final fontDir = '$fontsDir/$styleFontName';
      await Directory(fontDir).create(recursive: true);
      for (final range in config.fontRanges) {
        try {
          await _copyAsset(
            '${config.fontsAssetDir}$assetFontName/$range.pbf',
            '$fontDir/$range.pbf',
          );
        } catch (e) {
          debugPrint(
            'Warning: Could not copy font $assetFontName/$range.pbf: $e',
          );
        }
      }
    }

    for (final fontStack in fontStacks) {
      if (fontStack.length > 1) {
        final stackName = fontStack.join(',');
        final stackDir = '$fontsDir/$stackName';
        await Directory(stackDir).create(recursive: true);
        final primaryFont = fontStack.first;
        final primaryFontDir = '$fontsDir/$primaryFont';
        for (final range in config.fontRanges) {
          try {
            final sourceFile = File('$primaryFontDir/$range.pbf');
            if (await sourceFile.exists()) {
              await sourceFile.copy('$stackDir/$range.pbf');
            }
          } catch (e) {
            debugPrint(
              'Warning: Could not copy font stack $stackName/$range.pbf: $e',
            );
          }
        }
      }
    }

    if (style.containsKey('sources')) {
      final sources = style['sources'] as Map<String, dynamic>;
      for (final key in sources.keys) {
        final source = sources[key] as Map<String, dynamic>;
        if (source['type'] == 'vector') {
          source.remove('tiles');
          source['url'] = 'mbtiles://$mbtilesPath';
        }
      }
    }

    style['sprite'] = 'file://$spritesDir/sprite';
    style['glyphs'] = 'file://$fontsDir/{fontstack}/{range}.pbf';

    final stylePath = '${offlineDir.path}/style.json';
    await File(stylePath).writeAsString(json.encode(style));

    _cachedStylePath = stylePath;
    _initialized = true;
    return stylePath;
  }

  @override
  Widget buildMap({
    TrufiMapController? controller,
    required TrufiCameraPosition initialCamera,
    TrufiCameraPosition? camera,
    ValueChanged<TrufiCameraPosition>? onCameraChanged,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
    List<TrufiLayer> layers = const [],
    List<WidgetMarker> widgetMarkers = const [],
  }) {
    return _OfflineMapWrapper(
      key: ValueKey(id),
      engine: this,
      controller: controller,
      initialCamera: initialCamera,
      camera: camera,
      onCameraChanged: onCameraChanged,
      onMapClick: onMapClick,
      onMapLongClick: onMapLongClick,
      layers: layers,
      widgetMarkers: widgetMarkers,
    );
  }
}

class _OfflineMapWrapper extends StatefulWidget {
  final OfflineMapLibreEngine engine;
  final TrufiMapController? controller;
  final TrufiCameraPosition initialCamera;
  final TrufiCameraPosition? camera;
  final ValueChanged<TrufiCameraPosition>? onCameraChanged;
  final void Function(LatLng)? onMapClick;
  final void Function(LatLng)? onMapLongClick;
  final List<TrufiLayer> layers;
  final List<WidgetMarker> widgetMarkers;

  const _OfflineMapWrapper({
    super.key,
    required this.engine,
    required this.controller,
    required this.initialCamera,
    this.camera,
    this.onCameraChanged,
    this.onMapClick,
    this.onMapLongClick,
    this.layers = const [],
    this.widgetMarkers = const [],
  });

  @override
  State<_OfflineMapWrapper> createState() => _OfflineMapWrapperState();
}

class _OfflineMapWrapperState extends State<_OfflineMapWrapper> {
  String? _stylePath;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    try {
      final stylePath = await widget.engine._initializeOfflineResources();
      if (mounted) {
        setState(() {
          _stylePath = stylePath;
          _loading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('Offline map error: $e\n$stack');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.engine.isInitialized && _stylePath == null) {
      _stylePath = widget.engine.stylePath;
      _loading = false;
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar el mapa offline',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _ensureInitialized();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return TrufiMap(
      key: ValueKey(_stylePath),
      controller: widget.controller,
      initialCamera: widget.initialCamera,
      camera: widget.camera,
      styleString: _stylePath!,
      onCameraChanged: widget.onCameraChanged,
      onMapClick: widget.onMapClick,
      onMapLongClick: widget.onMapLongClick,
      layers: widget.layers,
      widgetMarkers: widget.widgetMarkers,
    );
  }
}
