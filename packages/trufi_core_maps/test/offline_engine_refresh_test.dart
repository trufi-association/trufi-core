import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// #973: the offline extraction must follow app updates. _copyAsset skips
/// existing files, so the extraction is stamped with the app build and
/// wiped on mismatch — otherwise users keep the old tiles/style/glyphs
/// until they clear app data.
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

  OfflineMapLibreEngine makeEngine() => OfflineMapLibreEngine(
    engineId: 'test_engine',
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

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline-refresh-');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    assets = {
      'assets/test.mbtiles': bytes('tiles-v1'),
      'assets/style.json': bytes('{"version":8,"sources":{},"layers":[]}'),
    };
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ));
          return assets[key];
        });
    PackageInfo.setMockInitialValues(
      appName: 'test',
      packageName: 'test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  File extractedTiles() =>
      File('${tempDir.path}/offline_maps/test_engine/tiles.mbtiles');
  File markerFile() =>
      File('${tempDir.path}/offline_maps/test_engine/.extracted-for');

  test('first boot extracts and stamps the build', () async {
    await makeEngine().initialize();

    expect(extractedTiles().readAsStringSync(), 'tiles-v1');
    expect(markerFile().readAsStringSync(), '1.0.0+1');
  });

  test('same build keeps the existing extraction (no useless rework)',
      () async {
    await makeEngine().initialize();
    assets['assets/test.mbtiles'] = bytes('tiles-v2');

    await makeEngine().initialize();

    expect(extractedTiles().readAsStringSync(), 'tiles-v1');
  });

  test('app update wipes and re-extracts the new assets', () async {
    await makeEngine().initialize();
    assets['assets/test.mbtiles'] = bytes('tiles-v2');
    PackageInfo.setMockInitialValues(
      appName: 'test',
      packageName: 'test',
      version: '1.0.1',
      buildNumber: '2',
      buildSignature: '',
    );

    await makeEngine().initialize();

    expect(extractedTiles().readAsStringSync(), 'tiles-v2');
    expect(markerFile().readAsStringSync(), '1.0.1+2');
  });

  test('a pre-fix extraction (no marker) is wiped once and stamped',
      () async {
    final legacy = extractedTiles();
    legacy.createSync(recursive: true);
    legacy.writeAsStringSync('tiles-legacy');

    await makeEngine().initialize();

    expect(extractedTiles().readAsStringSync(), 'tiles-v1');
    expect(markerFile().readAsStringSync(), '1.0.0+1');
  });
}
