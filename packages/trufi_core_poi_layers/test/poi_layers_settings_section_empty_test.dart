import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';

// trufi-core#1042: the settings section draws nothing while the manager has
// no categories (manifest not loaded yet, or empty), and the toggles once it
// has them. The manager's default storage goes through a platform channel
// that hangs in tests, so an in-memory one is injected.

class _MemoryStorage implements StorageService {
  final _data = <String, Object>{};
  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<String?> read(String key) async => _data[key] as String?;
  @override
  Future<void> delete(String key) async => _data.remove(key);
  @override
  Future<void> clear() async => _data.clear();
  @override
  Future<void> writeInt(String key, int value) async => _data[key] = value;
  @override
  Future<int?> readInt(String key) async => _data[key] as int?;
  @override
  Future<void> writeBool(String key, bool value) async => _data[key] = value;
  @override
  Future<bool?> readBool(String key) async => _data[key] as bool?;
  @override
  Future<void> writeDouble(String key, double value) async =>
      _data[key] = value;
  @override
  Future<double?> readDouble(String key) async => _data[key] as double?;
  @override
  Future<void> writeStringList(String key, List<String> value) async =>
      _data[key] = value;
  @override
  Future<List<String>?> readStringList(String key) async =>
      _data[key] as List<String>?;
  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);
  @override
  Future<Set<String>> getKeys() async => _data.keys.toSet();
}

const _metadata = '''
{"categories": [{"name": "health", "displayName": "Health", "count": 1,
  "subcategories": [{"name": "hospital", "displayName": "Hospital",
  "count": 1, "defaultActive": true, "color": "#D32F2F"}]}]}
''';
const _emptyCollection = '{"type": "FeatureCollection", "features": []}';

/// Serves the two assets the manager asks for; anything else is missing.
Future<ByteData?> _assets(ByteData? message) async {
  final key = utf8.decode(message!.buffer.asUint8List());
  final body = switch (key) {
    'assets/pois/metadata.json' => _metadata,
    'assets/pois/health.geojson' => _emptyCollection,
    _ => null,
  };
  if (body == null) return null;
  return ByteData.sublistView(Uint8List.fromList(utf8.encode(body)));
}

Future<void> _pump(WidgetTester tester, POILayersManager manager) =>
    tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: POILayersLocalizations.localizationsDelegates,
        supportedLocales: POILayersLocalizations.supportedLocales,
        home: ChangeNotifierProvider<POILayersManager>.value(
          value: manager,
          child: const Scaffold(body: POILayersSettingsSection()),
        ),
      ),
    );

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', _assets);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('no categories yet: the section takes no space', (tester) async {
    final manager = POILayersManager(
      assetsBasePath: 'assets/pois',
      storage: _MemoryStorage(),
    );
    addTearDown(manager.dispose);
    await _pump(tester, manager);
    expect(find.text('Points of Interest'), findsNothing);
    expect(tester.getSize(find.byType(POILayersSettingsSection)), Size.zero);
  });

  testWidgets('once the manifest is loaded the header and the toggles appear', (
    tester,
  ) async {
    final manager = POILayersManager(
      assetsBasePath: 'assets/pois',
      storage: _MemoryStorage(),
    );
    addTearDown(manager.dispose);
    await _pump(tester, manager);
    // The loader schedules its work with Future(): real async, not the
    // test's fake clock.
    await tester.runAsync(manager.initialize);
    await tester.pump();
    expect(find.text('Points of Interest'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
  });
}
