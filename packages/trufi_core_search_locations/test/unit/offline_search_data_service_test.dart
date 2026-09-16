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

  group('drill-down capability (#745)', () {
    test('a street with corners is drillable once data is loaded', () async {
      // canDrillDown is synchronous: it only answers truthfully after a
      // search loaded the data — which is the only way the screen can be
      // holding a street result in the first place.
      final results = await service.search('ayacucho');
      final street = results.firstWhere((r) => r.id == 'street:s1');
      expect(service.canDrillDown(street), isTrue);

      final corners = await service.drillDown(street);
      expect(corners.length, 2);
      expect(corners.map((c) => c.id), everyElement(startsWith('junction:')));
    });

    test('a street without corners is not drillable', () async {
      final results = await service.search('junin');
      final street = results.firstWhere((r) => r.id == 'street:s3');
      expect(service.canDrillDown(street), isFalse);
    });

    test('junction results themselves are not drillable', () async {
      final results = await service.search('ayacucho y heroinas');
      final junction = results.firstWhere((r) => r.id.startsWith('junction:'));
      expect(service.canDrillDown(junction), isFalse);
    });

    test('before any search the answer is simply false, not an error', () {
      final fresh = OfflineSearchDataService();
      expect(
        fresh.canDrillDown(
          const SearchLocation(
            id: 'street:s1',
            displayName: 'Avenida Ayacucho',
            latitude: -17.39,
            longitude: -66.15,
          ),
        ),
        isFalse,
      );
    });
  });

  group('street locality (#972)', () {
    // Two municipalities side by side, plus the rows a real index may
    // carry: no region at all (three elements), an empty one, a null one.
    const localityJson = {
      'streets': {
        'a': ['Calle Sucre', <String>[], [-66.1570, -17.3940], 'Cercado'],
        'b': ['Calle Sucre', <String>[], [-66.0400, -17.4040], 'Sacaba'],
        'c': ['Calle Bolívar', <String>[], [-66.1560, -17.3930], 'Cercado'],
        'd': ['Avenida Villazón', <String>[], [-66.1000, -17.3980], 'Sacaba'],
        'e': ['Calle Colombia', <String>[], [-66.1580, -17.3950]],
        'f': ['Calle España', <String>[], [-66.1590, -17.3960], ''],
        'g': ['Calle Perú', <String>[], [-66.1600, -17.3970], null],
      },
      'streetJunctions': {
        'a': [
          ['c', [-66.1565, -17.3935]], // both in Cercado
          ['e', [-66.1575, -17.3945]], // the other street has no region
        ],
        'c': [
          ['d', [-66.1200, -17.3960]], // Cercado meets Sacaba
        ],
        'e': [
          ['a', [-66.1575, -17.3945]], // the queried street has no region
        ],
        'f': [
          ['g', [-66.1595, -17.3965]], // neither has one
        ],
      },
    };

    late OfflineSearchDataService localities;

    setUp(() {
      _mockAsset('assets/search/localities.json', localityJson);
      localities = OfflineSearchDataService(
        assetPath: 'assets/search/localities.json',
      );
    });

    tearDown(() => localities.dispose());

    test('a street carries its municipality as the address', () async {
      final results = await service.search('ayacucho');
      expect(results.single.address, 'Cercado');
    });

    test('same-named streets of neighbouring towns are told apart', () async {
      final results = await localities.search('sucre');
      expect(results.map((r) => r.displayName), everyElement('Calle Sucre'));
      expect(
        results.map((r) => r.formattedDisplay),
        unorderedEquals(['Calle Sucre, Cercado', 'Calle Sucre, Sacaba']),
      );
    });

    test('a row without region, or with an empty or null one, has no address',
        () async {
      for (final query in ['colombia', 'espana', 'peru']) {
        final results = await localities.search(query);
        expect(results.single.address, isNull, reason: query);
      }
    });

    test('a corner inside one municipality names it once', () async {
      final results = await localities.search('sucre y bolivar');
      final corner = results.firstWhere((r) => r.id == 'junction:a:c');
      expect(corner.address, 'Cercado');
    });

    test('a corner on a municipal boundary names both', () async {
      final results = await localities.search('bolivar y villazon');
      final corner = results.firstWhere((r) => r.id == 'junction:c:d');
      expect(corner.address, 'Cercado / Sacaba');
    });

    test('a corner where only one street has a region uses that one', () async {
      final fromKnown = await localities.search('sucre y colombia');
      expect(
        fromKnown.firstWhere((r) => r.id == 'junction:a:e').address,
        'Cercado',
      );
      final fromUnknown = await localities.search('colombia y sucre');
      expect(
        fromUnknown.firstWhere((r) => r.id == 'junction:e:a').address,
        'Cercado',
      );
    });

    test('a corner where neither street has a region has no address', () async {
      final results = await localities.search('espana y peru');
      expect(results.firstWhere((r) => r.id == 'junction:f:g').address, isNull);
    });

    test('junctionsOf carries the same subtitles', () async {
      final boundary = await localities.junctionsOf('c');
      expect(boundary.single.address, 'Cercado / Sacaba');
      final inside = await service.junctionsOf('s1');
      expect(inside.map((c) => c.address), everyElement('Cercado'));
    });
  });
}
