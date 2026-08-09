import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// A miniature `search.json` in the exporter's json-compact shape:
/// two avenues that cross, plus a POI. Coordinates are [lon, lat].
const _searchJson = {
  '_version': '3.1',
  'streets': {
    's1': ['Avenida Ayacucho', <String>[], [-66.1588, -17.3925], 'Cercado'],
    's2': [
      'Avenida Heroínas de la Coronilla',
      <String>[],
      [-66.1600, -17.3930],
      'Cercado',
    ],
    's3': ['Calle Junín', <String>[], [-66.1550, -17.3900], 'Cercado'],
  },
  'streetJunctions': {
    's1': [
      ['s2', [-66.1587, -17.3927]],
      ['s3', [-66.1560, -17.3910]],
    ],
    's2': [
      ['s1', [-66.1587, -17.3927]],
    ],
  },
  'pois': [
    [
      'Mercado Calatayud',
      <String>[],
      <String>[],
      [-66.1620, -17.3880],
      'Cercado',
      'marketplace',
    ],
  ],
};

final _assets = <String, Map<String, dynamic>>{};

void _mockAsset(String key, Map<String, dynamic> json) => _assets[key] = json;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OfflineSearchDataService service;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      final json = key == 'assets/search/search.json'
          ? _searchJson
          : _assets[key];
      if (json == null) return null; // missing asset → rootBundle throws
      final bytes = utf8.encoder.convert(jsonEncode(json));
      return bytes.buffer.asByteData();
    });
    service = OfflineSearchDataService();
  });

  tearDown(() => service.dispose());

  group('street search', () {
    test('finds a street by name', () async {
      final results = await service.search('ayacucho');
      expect(results.any((r) => r.displayName == 'Avenida Ayacucho'), isTrue);
    });

    test('ignores case and accents', () async {
      final results = await service.search('heroinas');
      expect(
        results.any((r) => r.displayName.contains('Heroínas')),
        isTrue,
        reason: 'typing without the accent must still find the street',
      );
    });
  });

  group('junction search (#745)', () {
    test('"A y B" returns the crossing, not the streets', () async {
      final results = await service.search('ayacucho y heroinas');
      final junction = results.firstWhere((r) => r.id.startsWith('junction:'));
      expect(junction.displayName, contains('Ayacucho'));
      expect(junction.displayName, contains('Heroínas'));
      expect(junction.latitude, closeTo(-17.3927, 1e-6));
      expect(junction.longitude, closeTo(-66.1587, 1e-6));
    });

    test('other separators work too', () async {
      for (final query in [
        'ayacucho esq heroinas',
        'ayacucho con heroinas',
        'ayacucho & heroinas',
      ]) {
        final results = await service.search(query);
        expect(
          results.any((r) => r.id.startsWith('junction:')),
          isTrue,
          reason: 'separator in "$query" should be understood',
        );
      }
    });

    test('a street with no crossing to the other yields no junction', () async {
      final results = await service.search('junin y heroinas');
      expect(results.any((r) => r.id.startsWith('junction:')), isFalse);
    });

    test('junctionsOf lists every corner of a street', () async {
      final junctions = await service.junctionsOf('s1');
      expect(junctions.length, 2);
      expect(
        junctions.map((j) => j.displayName),
        everyElement(contains('Ayacucho')),
      );
    });
  });

  test('places are left to the online service', () async {
    // POIs live in the same file but are deliberately not returned: the
    // online geocoder ranks them better and stays fresher, and mixing
    // them in pushed its results off the screen.
    final results = await service.search('calatayud');
    expect(results, isEmpty);
  });

  test('reverse geocoding is left to the online service', () async {
    expect(await service.reverse(-17.39, -66.15), isNull);
  });

  test('an empty query returns nothing', () async {
    expect(await service.search('   '), isEmpty);
  });

  test('alternative names are searchable too', () async {
    final results = await service.search('junin');
    expect(results.any((r) => r.displayName == 'Calle Junín'), isTrue);
  });

  group('when the data is unusable', () {
    test('a missing asset fails as a SearchLocationException', () async {
      // Not a raw FlutterError: SearchLocationsCubit only catches this
      // type, and anything else leaves the spinner running forever.
      final missing = OfflineSearchDataService(
        assetPath: 'assets/search/does-not-exist.json',
      );
      await expectLater(
        missing.search('ayacucho'),
        throwsA(isA<SearchLocationException>()),
      );
      // And it retries rather than caching the failure.
      await expectLater(
        missing.search('ayacucho'),
        throwsA(isA<SearchLocationException>()),
      );
    });

    test('a malformed junction row does not sink the whole dataset', () async {
      final broken = Map<String, dynamic>.from(_searchJson);
      broken['streetJunctions'] = {
        's1': [
          ['s2', null], // malformed
          ['s2', [-66.1587, -17.3927]], // good
        ],
      };
      _mockAsset('assets/search/broken.json', broken);
      final service = OfflineSearchDataService(
        assetPath: 'assets/search/broken.json',
      );
      final results = await service.search('ayacucho y heroinas');
      expect(results.any((r) => r.id.startsWith('junction:')), isTrue);
      expect(
        (await service.search('ayacucho')).isNotEmpty,
        isTrue,
        reason: 'streets must survive a bad junction row',
      );
    });
  });
}
