import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trufi_core_utils/packge_info_platform.dart';

import '../../../l10n/maps_localizations.dart';
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
  final LocalizedStringBuilder? nameBuilder;
  final LocalizedStringBuilder? descriptionBuilder;
  final Widget? preview;

  String? _cachedStylePath;
  bool _initialized = false;

  OfflineMapLibreEngine({
    required this.config,
    this.engineId,
    this.displayName,
    this.displayDescription,
    this.nameBuilder,
    this.descriptionBuilder,
    this.preview,
  });

  @override
  String get id => engineId ?? 'offline_maplibre';

  @override
  String get name => displayName ?? 'Offline Map';

  @override
  String get description => displayDescription ?? 'Fully offline map';

  @override
  String localizedName(BuildContext context) =>
      nameBuilder?.call(context) ??
      displayName ??
      MapsLocalizations.of(context).offlineMapName;

  @override
  String localizedDescription(BuildContext context) =>
      descriptionBuilder?.call(context) ??
      displayDescription ??
      MapsLocalizations.of(context).offlineMapDescription;

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

  /// Per-asset content hash, memoized for the process lifetime so several
  /// engines sharing assets (e.g. four styles over one mbtiles) hash each
  /// bundle asset at most once per run. Null means the asset is not in
  /// the bundle — absence is part of the fingerprint, so adding or
  /// removing an asset between builds reads as a content change.
  static final Map<String, Future<String?>> _bundleHashMemo = {};

  /// Tests simulate app updates by swapping mocked assets within one
  /// process; production never needs this (a new build is a new process).
  @visibleForTesting
  static void resetBundleHashCacheForTesting() => _bundleHashMemo.clear();

  static Future<String?> _bundleAssetHash(String assetPath) {
    return _bundleHashMemo.putIfAbsent(assetPath, () async {
      try {
        final data = await rootBundle.load(assetPath);
        return _fnv1a(data.buffer.asUint8List());
      } catch (_) {
        return null;
      }
    });
  }

  /// 32-bit multiply modulo 2^32 with no intermediate above 2^53, so the
  /// result is identical on the VM and under dart2js. The engine never
  /// RUNS on web, but web builds must COMPILE every reachable line —
  /// 64-bit integer literals broke `flutter build web` for every app
  /// importing this package.
  static int _mul32(int a, int b) {
    final hi = (((a >>> 16) & 0xffff) * b) & 0xffff;
    final lo = (a & 0xffff) * b;
    return ((hi << 16) + lo) & 0xffffffff;
  }

  /// Two independent 32-bit FNV-1a streams concatenated: 64 bits of
  /// change-detection using only JS-representable arithmetic.
  /// Non-cryptographic on purpose: the question is "did the bundled file
  /// change between app builds", not adversarial integrity.
  static String _fnv1a(List<int> bytes) {
    var h1 = 0x811c9dc5;
    var h2 = 0xcbf29ce4;
    for (final b in bytes) {
      h1 = _mul32(h1 ^ b, 0x01000193);
      h2 = _mul32(h2 ^ b ^ 0x5f, 0x01000193);
    }
    return h1.toRadixString(16).padLeft(8, '0') +
        h2.toRadixString(16).padLeft(8, '0');
  }

  /// Fingerprint of every bundled asset this engine extracts. Computed
  /// only when the app build changed (or on first install) — never on a
  /// routine boot.
  Future<String> _bundleFingerprint() async {
    // Absence must stay representable in the fingerprint text ('-' is not
    // a hex digit, so it cannot collide with a real hash).
    Future<String> part(String name, String assetPath) async =>
        '$name:${await _bundleAssetHash(assetPath) ?? '-'}';

    final parts = <String>[];
    parts.add(await part('tiles', config.mbtilesAsset));
    parts.add(await part('style', config.styleAsset));
    for (final spriteFile in _spriteFiles) {
      parts.add(
        await part(spriteFile, '${config.spritesAssetDir}$spriteFile'),
      );
    }
    for (final assetFontName in config.fontMapping.keys) {
      for (final range in config.fontRanges) {
        final path = '${config.fontsAssetDir}$assetFontName/$range.pbf';
        parts.add(await part('$assetFontName/$range', path));
      }
    }
    return _fnv1a(utf8.encode(parts.join('|')));
  }

  static const _spriteFiles = [
    'sprite.json',
    'sprite.png',
    'sprite@2x.json',
    'sprite@2x.png',
  ];

  /// The mbtiles is extracted once per *asset*, not once per engine:
  /// several visual styles typically share one tile set, and duplicating
  /// a tens-of-MB file per style quadrupled both the cache footprint and
  /// the post-update re-extraction (Cochabamba: 4 styles × 25.8 MB).
  /// The copy carries a sibling `.hash` so a changed bundle refreshes it.
  Future<String> _ensureSharedTiles(
    Directory mapsRoot, {
    required bool verifyContent,
  }) async {
    // The readable part can collide after sanitization ('a b' vs 'a_b'),
    // and a silent collision would render another asset's tiles — the
    // raw-path hash suffix makes the key injective.
    final readable = config.mbtilesAsset.replaceAll(
      RegExp('[^A-Za-z0-9._-]'),
      '_',
    );
    final key = '$readable-${_fnv1a(utf8.encode(config.mbtilesAsset))}';
    final tilesFile = File('${mapsRoot.path}/_shared/$key');
    final hashFile = File('${tilesFile.path}.hash');

    if (await tilesFile.exists() && await hashFile.exists()) {
      if (!verifyContent) {
        // Routine boot: the engine marker already vouches for the bundle
        // content — do not read megabytes just to re-prove it.
        return tilesFile.path;
      }
      final bundleHash = await _bundleAssetHash(config.mbtilesAsset);
      if (bundleHash != null && await hashFile.readAsString() == bundleHash) {
        return tilesFile.path;
      }
    }
    await tilesFile.parent.create(recursive: true);
    final data = await rootBundle.load(config.mbtilesAsset);
    final bytes = data.buffer.asUint8List();
    await tilesFile.writeAsBytes(bytes, flush: true);
    // Hash the bytes just written — single read, and immune to a stale
    // memoized failure.
    await hashFile.writeAsString(_fnv1a(bytes));
    return tilesFile.path;
  }

  /// Identifier of the app build the extraction belongs to, or null when
  /// package info is unavailable (e.g. plain unit tests, a transient
  /// platform-channel failure). Null means "can't tell" — the caller keeps
  /// whatever extraction exists rather than flapping between wipes.
  Future<String?> _appBuildStamp() async {
    try {
      return await PackageInfoPlatform.fullVersion();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    if (_initialized && _cachedStylePath != null) return;
    await _initializeOfflineResources();
  }

  Future<String> _initializeOfflineResources() async {
    if (_initialized && _cachedStylePath != null) return _cachedStylePath!;

    final cacheDir = await getApplicationCacheDirectory();
    final mapsRoot = Directory('${cacheDir.path}/offline_maps');
    final offlineDir = Directory('${mapsRoot.path}/$id');

    // The extraction is invalidated by CONTENT, gated by the app build:
    //
    // - Routine boot (build matches the marker): reuse everything — no
    //   hashing; only the marker read plus the pre-existing per-boot work
    //   (style rewrite, copy-if-missing self-healing).
    // - First boot after an update/downgrade (build differs): fingerprint
    //   the bundled assets (a few seconds of reads, no writes). Most
    //   updates don't touch map assets — identical fingerprint keeps the
    //   extraction and only restamps the marker. Only a real asset change
    //   pays the wipe + re-extraction (#973).
    // - No/legacy marker: extract from scratch.
    //
    // Marker format: line 1 = build stamp, line 2 = bundle fingerprint.
    final marker = File('${offlineDir.path}/.extracted-for');
    final buildStamp = await _appBuildStamp();

    String? markerBuild;
    String? markerFingerprint;
    if (await marker.exists()) {
      final lines = (await marker.readAsString()).split('\n');
      markerBuild = lines.isNotEmpty ? lines[0] : null;
      if (lines.length > 1) markerFingerprint = lines[1];
    }

    var reuseExtraction = false;
    String? fingerprint;
    if (markerBuild != null && buildStamp != null) {
      if (markerBuild == buildStamp) {
        reuseExtraction = true;
      } else {
        fingerprint = await _bundleFingerprint();
        if (markerFingerprint == fingerprint) {
          // Update that didn't touch the map assets: keep everything,
          // just record the new build so the next boot is cheap again.
          await marker.writeAsString('$buildStamp\n$fingerprint');
          reuseExtraction = true;
        }
      }
    } else if (await offlineDir.exists() && buildStamp == null) {
      // Build unknowable right now: keep the existing extraction instead
      // of wiping on guesswork.
      reuseExtraction = true;
    }

    if (!reuseExtraction && await offlineDir.exists()) {
      await offlineDir.delete(recursive: true);
    }
    await offlineDir.create(recursive: true);

    final mbtilesPath = await _ensureSharedTiles(
      mapsRoot,
      verifyContent: !reuseExtraction,
    );
    // Pre-dedup extractions left a per-engine copy of the tile set —
    // reclaim the space once.
    final legacyTiles = File('${offlineDir.path}/tiles.mbtiles');
    if (await legacyTiles.exists()) {
      await legacyTiles.delete();
    }

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

    // Stamp last: a crash mid-extraction leaves no marker, so the next
    // boot wipes the partial copy and starts over. Routine boots and
    // fingerprint-matched updates never reach a state that needs
    // restamping here.
    if (!reuseExtraction && buildStamp != null) {
      fingerprint ??= await _bundleFingerprint();
      await marker.writeAsString('$buildStamp\n$fingerprint');
    }

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
      final l10n = MapsLocalizations.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingOfflineMap,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                child: Text(l10n.retry),
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
