import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Street order by type of road, without a focus point (Lima #18).
///
/// These tests only use today's constructor, so they fail on behaviour, not
/// on a missing parameter. The tests that need `focus` are in
/// `offline_search_focus_test.dart`.

/// A street as the tests need it.
class _S {
  final String name;
  final String? region;
  final int corners;
  final double lat;
  final double lon;
  final List<String> alts;

  const _S(
    this.name, {
    this.region = 'Lima',
    this.corners = 0,
    this.lat = -12.05,
    this.lon = -77.03,
    this.alts = const [],
  });
}

Map<String, dynamic> _indexOf(Map<String, _S> streets) => {
  'streets': {
    for (final e in streets.entries)
      e.key: [
        e.value.name,
        e.value.alts,
        [e.value.lon, e.value.lat],
        e.value.region,
      ],
  },
  'streetJunctions': {
    for (final e in streets.entries)
      if (e.value.corners > 0)
        e.key: [
          for (var i = 0; i < e.value.corners; i++)
            [
              'other$i',
              [e.value.lon, e.value.lat],
            ],
        ],
  },
};

final _assets = <String, Map<String, dynamic>>{};
var _indexes = 0;

/// Refs, in order, of the streets [query] returns on [streets].
Future<List<String>> _refsFor(
  String query,
  Map<String, _S> streets, {
  int limit = 10,
}) async {
  final asset = 'assets/search/ranking-${_indexes++}.json';
  _assets[asset] = _indexOf(streets);
  final service = OfflineSearchDataService(
    assetPath: asset,
    limitPerCategory: limit,
  );
  addTearDown(service.dispose);
  final results = await service.search(query);
  return [for (final r in results) r.id.substring('street:'.length)];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      final json = _assets[key];
      if (json == null) return null;
      final bytes = utf8.encoder.convert(jsonEncode(json));
      return bytes.buffer.asByteData();
    });
  });

  // The Lima "grau" fixture: one avenue whose name has words between the
  // type and "Grau", and the homonyms that used to bury it.
  const grau = {
    'lima': _S('Avenida Almirante Miguel Grau', corners: 40),
    'ancon': _S(
      'Avenida Grau',
      region: 'Ancón',
      corners: 2,
      lat: -11.77,
      lon: -77.17,
    ),
    'calle': _S('Calle Grau', region: 'Callao', corners: 8),
    'pasaje': _S('Pasaje Grau', region: 'Rímac', corners: 30),
    'untyped': _S('Grau', region: 'Ventanilla', corners: 5),
  };

  group('AC3: "avenida grau" reads the words, not the text in a row', () {
    test('finds "Avenida Almirante Miguel Grau" and only avenues', () async {
      final refs = await _refsFor('avenida grau', grau);

      expect(refs, containsAll(['lima', 'ancon']));
      // Negative: a typed query leaves out every other kind of road.
      expect(refs, isNot(contains('calle')));
      expect(refs, isNot(contains('pasaje')));
      expect(refs, isNot(contains('untyped')));
      expect(refs.length, 2);
    });

    test('the typed query ignores accents and case', () async {
      final refs = await _refsFor('AVENIDA  Grau', grau);
      expect(refs, containsAll(['lima', 'ancon']));
    });

    test('a word that is no prefix of any word of the name does not match',
        () async {
      // "rau" is inside "Grau" but starts none of its words: a typed query
      // matches by words only (the plain substring rule is for untyped
      // queries, as today).
      expect(await _refsFor('avenida rau', grau), isEmpty);
    });

    test('"grau" puts every avenue before the untyped, calle and pasaje '
        'rows', () async {
      final refs = await _refsFor('grau', grau);

      // Without a focus the base name decides among avenues (Avenida Grau
      // is named like the query), then corners; the class decides first.
      expect(refs.toSet().length, 5);
      expect(refs.indexOf('untyped'), greaterThan(refs.indexOf('lima')));
      expect(refs.indexOf('untyped'), greaterThan(refs.indexOf('ancon')));
      expect(refs.indexOf('calle'), greaterThan(refs.indexOf('lima')));
      expect(refs.indexOf('calle'), greaterThan(refs.indexOf('ancon')));
      expect(refs.last, 'pasaje');
    });
  });

  group('AC4: the avenue is not cut by the limit', () {
    test('"alfonso ugarte": the avenue first, with a limit of 3 and more '
        'corners on the jirones', () async {
      final refs = await _refsFor(
        'alfonso ugarte',
        {
          'jr1': _S('Jirón Alfonso Ugarte', corners: 12, region: 'Breña'),
          'jr2': _S('Jirón Alfonso Ugarte', corners: 11, region: 'Rímac'),
          'calle': _S('Calle Alfonso Ugarte', corners: 10, region: 'Callao'),
          'untyped': _S('Alfonso Ugarte', corners: 9, region: 'Comas'),
          'pasaje': _S('Pasaje Alfonso Ugarte', corners: 30),
          'av': _S('Avenida Alfonso Ugarte', corners: 2),
        },
        limit: 3,
      );

      expect(refs.first, 'av');
      expect(refs.length, 3);
      // Negative: the pasaje, however connected, is never in the cut.
      expect(refs, isNot(contains('pasaje')));
    });
  });

  group('AC5: avenues before calles, jirones and pasajes of the same name',
      () {
    final sucre = {
      'pasaje': _S('Pasaje Sucre', region: 'A', corners: 50),
      'calle': _S('Calle Sucre', region: 'B', corners: 20),
      'jiron': _S('Jirón Sucre', region: 'C', corners: 10),
      'untyped': _S('Sucre', region: 'D', corners: 5),
      'av': _S('Avenida Sucre', region: 'E', corners: 1),
    };

    test('class order first, then corners within the class', () async {
      expect(await _refsFor('sucre', sucre), [
        'av',
        'calle',
        'jiron',
        'untyped',
        'pasaje',
      ]);
    });

    test('the other avenue-like types lead too, with the abbreviation',
        () async {
      final refs = await _refsFor('ayacucho', {
        'jr': _S('Jr. Ayacucho', region: 'A', corners: 40),
        'psje': _S('Psje. Ayacucho', region: 'B', corners: 45),
        'via': _S('Vía Expresa Ayacucho', region: 'C', corners: 1),
        'av': _S('Av. Ayacucho', region: 'D', corners: 2),
      });
      expect(refs, ['av', 'via', 'jr', 'psje']);
    });

    test('a pasaje never beats a calle, even with an exact name and more '
        'corners', () async {
      final refs = await _refsFor('luna', {
        'pasaje': _S('Pasaje Luna', region: 'A', corners: 99),
        'calle': _S('Calle Larga de la Luna', region: 'B', corners: 1),
      });
      expect(refs, ['calle', 'pasaje']);
    });

    test('a street only also known by the query\'s name does not jump '
        'the class of the avenue named so', () async {
      final refs = await _refsFor('bolivar', {
        'aka': _S('Calle Simón', alts: ['Bolívar'], corners: 50),
        'named': _S('Avenida Bolívar', region: 'Other', corners: 1),
      });
      expect(refs, ['named', 'aka']);
    });
  });

  group('AC6: without focus, the corners still break ties (#1054)', () {
    test('the exact name first, an alternative name second, a longer name '
        'after', () async {
      final refs = await _refsFor('camino a lagunas', {
        'longer': _S('Camino a Lagunas Entrando por Tirani', corners: 4),
        'exact': _S(
          'Camino a Lagunas',
          corners: 3,
          alts: ['Circuito Tunari'],
        ),
        'other': _S('Calle Lagunas', corners: 9),
      });
      expect(refs, ['exact', 'longer']);
    });

    test('same class, same name: more corners first, then the ref', () async {
      final refs = await _refsFor('aroma', {
        'a': _S('Calle Aroma', region: 'T1', corners: 3),
        'b': _S('Calle Aroma', region: 'T2', corners: 9),
        'c': _S('Calle Aroma', region: 'T3', corners: 9),
      });
      expect(refs, ['b', 'c', 'a']);
    });

    test('the text match still decides before corners inside one class',
        () async {
      final refs = await _refsFor('sucre', {
        'contains': _S('Calle Sucre', corners: 50),
        'prefix': _S('Sucre Norte', corners: 3),
        'exact': _S('Sucre', corners: 0),
      });
      expect(refs, ['exact', 'prefix', 'contains']);
    });

    test('the limit keeps the streets with more corners', () async {
      final refs = await _refsFor('circunvalacion', {
        for (var i = 1; i <= 12; i++)
          's$i': _S(
            'Avenida Circunvalación',
            region: 'Town ${i.toString().padLeft(2, '0')}',
            corners: i,
          ),
      });
      expect(refs, [for (var i = 12; i >= 3; i--) 's$i']);
    });
  });

  group('names with no Spanish type keep today\'s order', () {
    test('Arabic names', () async {
      final refs = await _refsFor('الملك', {
        'contains': _S('شارع الملك', corners: 9),
        'prefix': _S('الملك فهد', corners: 2),
        'exact': _S('الملك', corners: 0),
      });
      expect(refs, ['exact', 'prefix', 'contains']);
    });

    test('English names, ties by corners', () async {
      final refs = await _refsFor('main', {
        'east': _S('East Main Street', region: 'A', corners: 5),
        'street': _S('Main Street', region: 'B', corners: 1),
        'avenue': _S('Main Avenue', region: 'C', corners: 7),
        'exact': _S('Main', region: 'D', corners: 0),
      });
      // "Avenue" is not a type of this language's list: no class change.
      expect(refs, ['exact', 'avenue', 'street', 'east']);
    });
  });
}
