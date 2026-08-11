import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// #973 + content-aware refinement: the extraction is invalidated by the
/// bundled assets' CONTENT, gated by the app build. Most app updates
/// don't touch map assets — those must keep the extraction untouched.
/// The mbtiles is also deduplicated across engines (one copy per asset,
/// not per style).
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.root);
  final String root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Map<String, ByteData> assets;

  OfflineMapLibreEngine makeEngine([String id = 'test_engine']) =>
      OfflineMapLibreEngine(
        engineId: id,
        displayName: 'Test',
        displayDescription: 'Test',
        config: OfflineMapConfig(
          mbtilesAsset: 'assets/test.mbtiles',
          styleAsset: 'assets/style.json',
          spritesAssetDir: 'assets/sprites/',
          fontsAssetDir: 'assets/fonts/',
          fontMapping: const {},
          fontRanges: const [],
        ),
      );

  ByteData bytes(String s) => ByteData.sublistView(utf8.encoder.convert(s));

  void setBuild(String version, String buildNumber) {
    PackageInfo.setMockInitialValues(
      appName: 'test',
      packageName: 'test',
      version: version,
      buildNumber: buildNumber,
      buildSignature: '',
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline-refresh-');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    OfflineMapLibreEngine.resetBundleHashCacheForTesting();
    assets = {
      'assets/test.mbtiles': bytes('tiles-v1'),
      'assets/style.json': bytes('{"version":8,"sources":{"omt":{"type":"vector","tiles":["x"]}},"layers":[]}'),
    };
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(
            message!.buffer.asUint8List(
              message.offsetInBytes,
              message.lengthInBytes,
            ),
          );
          return assets[key];
        });
    setBuild('1.0.0', '1');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  File sharedTiles() =>
      File('${tempDir.path}/offline_maps/_shared/assets_test.mbtiles');
  File markerFile([String id = 'test_engine']) =>
      File('${tempDir.path}/offline_maps/$id/.extracted-for');
  File engineTiles([String id = 'test_engine']) =>
      File('${tempDir.path}/offline_maps/$id/tiles.mbtiles');

  test('first boot extracts one shared tile set and stamps build+content',
      () async {
    await makeEngine().initialize();

    expect(sharedTiles().readAsStringSync(), 'tiles-v1');
    expect(engineTiles().existsSync(), isFalse,
        reason: 'no per-engine tile copy anymore');
    final lines = markerFile().readAsStringSync().split('\n');
    expect(lines[0], '1.0.0+1');
    expect(lines[1], isNotEmpty, reason: 'content fingerprint recorded');
  });

  test('routine boot (same build) touches nothing even if assets differ',
      () async {
    await makeEngine().initialize();
    assets['assets/test.mbtiles'] = bytes('tiles-v2');
    OfflineMapLibreEngine.resetBundleHashCacheForTesting();

    await makeEngine().initialize();

    expect(sharedTiles().readAsStringSync(), 'tiles-v1',
        reason: 'same build = fast path, by design');
  });

  test('update WITHOUT asset changes keeps the extraction (the common case)',
      () async {
    await makeEngine().initialize();
    // Sentinel proves the file is not rewritten.
    sharedTiles().writeAsStringSync('disk-sentinel');
    setBuild('1.0.1', '2');
    OfflineMapLibreEngine.resetBundleHashCacheForTesting();

    await makeEngine().initialize();

    expect(sharedTiles().readAsStringSync(), 'disk-sentinel',
        reason: 'identical bundle fingerprint must not re-extract');
    expect(markerFile().readAsStringSync().split('\n')[0], '1.0.1+2',
        reason: 'marker restamped so the next boot is cheap again');
  });

  test('update WITH changed assets wipes and re-extracts', () async {
    await makeEngine().initialize();
    assets['assets/test.mbtiles'] = bytes('tiles-v2');
    setBuild('1.1.0', '3');
    OfflineMapLibreEngine.resetBundleHashCacheForTesting();

    await makeEngine().initialize();

    expect(sharedTiles().readAsStringSync(), 'tiles-v2');
    expect(markerFile().readAsStringSync().split('\n')[0], '1.1.0+3');
  });

  test('legacy layout (single-line marker + per-engine tiles) migrates',
      () async {
    final legacy = engineTiles();
    legacy.createSync(recursive: true);
    legacy.writeAsStringSync('tiles-legacy');
    markerFile().writeAsStringSync('0.9.0+9');

    await makeEngine().initialize();

    expect(sharedTiles().readAsStringSync(), 'tiles-v1');
    expect(engineTiles().existsSync(), isFalse,
        reason: 'legacy per-engine copy reclaimed');
    expect(markerFile().readAsStringSync(), contains('\n'),
        reason: 'marker upgraded to build+fingerprint format');
  });

  test('several engines over one mbtiles share a single copy', () async {
    await makeEngine('style_a').initialize();
    await makeEngine('style_b').initialize();

    expect(sharedTiles().existsSync(), isTrue);
    expect(engineTiles('style_a').existsSync(), isFalse);
    expect(engineTiles('style_b').existsSync(), isFalse);

    for (final id in ['style_a', 'style_b']) {
      final style =
          json.decode(File('${tempDir.path}/offline_maps/$id/style.json')
              .readAsStringSync()) as Map<String, dynamic>;
      expect(json.encode(style['sources']), contains('_shared'),
          reason: '$id must point at the shared tile set');
    }
  });
}
