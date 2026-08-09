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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OfflineSearchDataService service;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key != 'assets/search/search.json') return null;
      final bytes = utf8.encoder.convert(jsonEncode(_searchJson));
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

  test('POIs from the same file are searchable', () async {
    final results = await service.search('calatayud');
    expect(results.any((r) => r.displayName == 'Mercado Calatayud'), isTrue);
  });

  test('reverse geocoding is left to the online service', () async {
    expect(await service.reverse(-17.39, -66.15), isNull);
  });

  test('an empty query returns nothing', () async {
    expect(await service.search('   '), isEmpty);
  });
}
