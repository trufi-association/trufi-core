import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/controller/map_controller.dart';
import '../../presentation/map/maplibre_map.dart';
import 'trufi_map_engine.dart';

/// Configuration for fully offline maps.
///
/// All paths are relative to the assets folder.
class OfflineMapConfig {
  /// Path to mbtiles file in assets (e.g., 'assets/offline/cochabamba.mbtiles')
  final String mbtilesAsset;

  /// Path to style.json in assets (e.g., 'assets/offline/styles/osm-bright/style.json')
  final String styleAsset;

  /// Path to sprites directory in assets (e.g., 'assets/offline/styles/osm-bright/')
  /// Should contain sprite.json, sprite.png, sprite@2x.json, sprite@2x.png
  final String spritesAssetDir;

  /// Path to fonts directory in assets (e.g., 'assets/offline/fonts/')
  /// Should contain subdirectories for each font (e.g., 'OpenSansRegular/')
  final String fontsAssetDir;

  /// Map of font names: asset directory name -> style font name
  /// e.g., {'OpenSansRegular': 'Open Sans Regular'}
  /// The key is the directory name in assets (without spaces for Flutter compatibility)
  /// The value is the font name used in the style.json (with spaces)
  final Map<String, String> fontMapping;

  /// List of font ranges to copy (e.g., ['0-255', '256-511'])
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
///
/// This engine copies all necessary assets to the device's cache directory
/// and generates a style.json that points to local resources.
///
/// Example:
/// ```dart
/// OfflineMapLibreEngine(
///   engineId: 'offline_map',
///   config: OfflineMapConfig(
///     mbtilesAsset: 'assets/offline/cochabamba.mbtiles',
///     styleAsset: 'assets/offline/styles/osm-bright/style.json',
///     spritesAssetDir: 'assets/offline/styles/osm-bright/',
///     fontsAssetDir: 'assets/offline/fonts/',
///     fontNames: ['Open Sans Regular', 'Open Sans Bold', 'Open Sans Italic'],
///     fontRanges: ['0-255', '256-511', '512-767', '768-1023'],
///   ),
///   displayName: 'Offline Map',
/// )
/// ```
class OfflineMapLibreEngine implements ITrufiMapEngine {
  /// Configuration for offline assets.
  final OfflineMapConfig config;

  /// Custom engine ID (optional).
  final String? engineId;

  /// Custom display name (optional).
  final String? displayName;

  /// Custom description (optional).
  final String? displayDescription;

  /// Custom preview widget (optional).
  final Widget? preview;

  /// Cached generated style path.
  String? _cachedStylePath;

  /// Whether initialization is complete.
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
  String get description =>
      displayDescription ?? 'Mapa completamente offline';

  @override
  Widget? get previewWidget =>
      preview ??
      Container(
        color: Colors.green.shade100,
        child: const Center(
          child: Icon(Icons.offline_bolt, size: 40, color: Colors.green),
        ),
      );

  /// Copy an asset file to the cache directory.
  Future<String> _copyAsset(String assetPath, String targetPath) async {
    final targetFile = File(targetPath);

    // Skip if already exists
    if (await targetFile.exists()) {
      return targetPath;
    }

    // Ensure parent directory exists
    await targetFile.parent.create(recursive: true);

    // Copy from assets
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await targetFile.writeAsBytes(bytes, flush: true);

    return targetPath;
  }

  /// Initialize all offline resources.
  Future<String> _initializeOffline(
    void Function(String status, double progress)? onProgress,
  ) async {
    if (_initialized && _cachedStylePath != null) {
      return _cachedStylePath!;
    }

    final cacheDir = await getApplicationCacheDirectory();
    final offlineDir = Directory('${cacheDir.path}/offline_maps/$id');
    await offlineDir.create(recursive: true);

    // 1. Copy mbtiles
    onProgress?.call('Copiando tiles...', 0.1);
    final mbtilesPath = await _copyAsset(
      config.mbtilesAsset,
      '${offlineDir.path}/tiles.mbtiles',
    );

    // 2. Copy sprites
    onProgress?.call('Copiando sprites...', 0.3);
    final spritesDir = '${offlineDir.path}/sprites';
    await Directory(spritesDir).create(recursive: true);

    for (final spriteFile in ['sprite.json', 'sprite.png', 'sprite@2x.json', 'sprite@2x.png']) {
      try {
        await _copyAsset(
          '${config.spritesAssetDir}$spriteFile',
          '$spritesDir/$spriteFile',
        );
      } catch (e) {
        debugPrint('Warning: Could not copy sprite file $spriteFile: $e');
      }
    }

    // 3. Copy fonts
    // fontMapping: assetDirName -> styleFontName
    // e.g., 'OpenSansRegular' -> 'Open Sans Regular'
    onProgress?.call('Copiando fuentes...', 0.5);
    final fontsDir = '${offlineDir.path}/fonts';

    for (final entry in config.fontMapping.entries) {
      final assetFontName = entry.key; // e.g., 'OpenSansRegular'
      final styleFontName = entry.value; // e.g., 'Open Sans Regular'
      final fontDir = '$fontsDir/$styleFontName';
      await Directory(fontDir).create(recursive: true);

      for (final range in config.fontRanges) {
        try {
          await _copyAsset(
            '${config.fontsAssetDir}$assetFontName/$range.pbf',
            '$fontDir/$range.pbf',
          );
        } catch (e) {
          // Font range might not exist, skip it
          debugPrint('Warning: Could not copy font $assetFontName/$range.pbf: $e');
        }
      }
    }

    // 4. Load and modify style.json
    onProgress?.call('Configurando estilo...', 0.8);
    final styleData = await rootBundle.loadString(config.styleAsset);
    final style = json.decode(styleData) as Map<String, dynamic>;

    // Update sources to use local mbtiles
    // Format: mbtiles:///absolute/path/to/file.mbtiles
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

    // Update sprite to use local files
    style['sprite'] = 'file://$spritesDir/sprite';

    // Update glyphs to use local files
    style['glyphs'] = 'file://$fontsDir/{fontstack}/{range}.pbf';

    // Save modified style
    final stylePath = '${offlineDir.path}/style.json';
    await File(stylePath).writeAsString(json.encode(style));

    onProgress?.call('Listo', 1.0);

    _cachedStylePath = stylePath;
    _initialized = true;

    return stylePath;
  }

  @override
  Widget buildMap({
    required TrufiMapController controller,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
    bool isDarkMode = false,
  }) {
    return _OfflineMapWrapper(
      engine: this,
      controller: controller,
      onMapClick: onMapClick,
      onMapLongClick: onMapLongClick,
    );
  }
}

/// Wrapper widget that initializes offline resources before rendering the map.
class _OfflineMapWrapper extends StatefulWidget {
  final OfflineMapLibreEngine engine;
  final TrufiMapController controller;
  final void Function(LatLng)? onMapClick;
  final void Function(LatLng)? onMapLongClick;

  const _OfflineMapWrapper({
    required this.engine,
    required this.controller,
    this.onMapClick,
    this.onMapLongClick,
  });

  @override
  State<_OfflineMapWrapper> createState() => _OfflineMapWrapperState();
}

class _OfflineMapWrapperState extends State<_OfflineMapWrapper> {
  String? _stylePath;
  String? _error;
  bool _loading = true;
  double _progress = 0;
  String _statusMessage = 'Inicializando...';

  @override
  void initState() {
    super.initState();
    _initOffline();
  }

  Future<void> _initOffline() async {
    try {
      final stylePath = await widget.engine._initializeOffline(
        (status, progress) {
          if (mounted) {
            setState(() {
              _statusMessage = status;
              _progress = progress;
            });
          }
        },
      );

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
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_statusMessage),
            const SizedBox(height: 8),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(value: _progress),
            ),
          ],
        ),
      );
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
                  _initOffline();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return TrufiMapLibreMap(
      controller: widget.controller,
      styleString: _stylePath!,
      onMapClick: widget.onMapClick,
      onMapLongClick: widget.onMapLongClick,
    );
  }
}
