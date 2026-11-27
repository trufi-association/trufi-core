import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Cases found in the third review of the street ranking (Lima #18).

class _S {
  final String name;
  final int corners;

  const _S(this.name, {this.corners = 0});
}

Map<String, dynamic> _indexOf(Map<String, _S> streets) => {
  'streets': {
    for (final e in streets.entries)
      e.key: [
        e.value.name,
        const <String>[],
        [-77.03, -12.05],
        'Lima',
      ],
  },
  'streetJunctions': {
    for (final e in streets.entries)
      if (e.value.corners > 0)
        e.key: [
          for (var i = 0; i < e.value.corners; i++)
            [
              'other$i',
              [-77.03, -12.05],
            ],
        ],
  },
};

final _assets = <String, Map<String, dynamic>>{};
var _indexes = 0;

Future<List<String>> _namesFor(
  String query,
  Map<String, _S> streets, {
  int limit = 10,
  List<List<String>>? ranks,
}) async {
  final asset = 'assets/search/review3-${_indexes++}.json';
  _assets[asset] = _indexOf(streets);
  final service = OfflineSearchDataService(
    assetPath: asset,
    limitPerCategory: limit,
    streetTypeRanks: ranks ?? OfflineSearchDataService.defaultStreetTypeRanks,
  );
  addTearDown(service.dispose);
  return [for (final r in await service.search(query)) r.displayName];
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

  group('R9: a typed query finds the same class spelled differently', () {
    test('"jr ucayali" finds "Jirón Ucayali"', () async {
      final names = await _namesFor('jr ucayali', {'a': _S('Jirón Ucayali')});
      expect(names, ['Jirón Ucayali']);
    });

    test('"calle camana" finds "Jirón Camaná"', () async {
      final names = await _namesFor('calle camana', {'a': _S('Jirón Camaná')});
      expect(names, ['Jirón Camaná']);
    });

    test('"avenida lurin" finds "Av. Lurín"', () async {
      final names = await _namesFor('avenida lurin', {'a': _S('Av. Lurín')});
      expect(names, ['Av. Lurín']);
    });

    test('"pje x" finds "Pasaje X"', () async {
      final names = await _namesFor('pje x', {'a': _S('Pasaje X')});
      expect(names, ['Pasaje X']);
    });
  });

  group('R10: a query of only a type word matches the whole class', () {
    test('"av" ranks "Avenida Grande" (50 corners) over "Av. Chica"', () async {
      final names = await _namesFor('av', {
        'chica': _S('Av. Chica', corners: 1),
        'grande': _S('Avenida Grande', corners: 50),
      }, limit: 1);
      expect(names, ['Avenida Grande']);
    });
  });

  group('R11: street type keys may have any case and accents', () {
    test('"Avenida" and "Jirón" keys still sort the classes', () async {
      final names = await _namesFor(
        'sucre',
        {
          'j': _S('Jirón Sucre', corners: 10),
          'a': _S('Avenida Sucre'),
          'c': _S('Calle Sucre', corners: 5),
        },
        ranks: const [
          ['Avenida'],
          ['Calle'],
          ['Jirón'],
        ],
      );
      expect(names, ['Avenida Sucre', 'Calle Sucre', 'Jirón Sucre']);
    });
  });

  group('R13: a query without letters or digits uses the substring rule', () {
    test('"-" finds only the name that contains it', () async {
      final names = await _namesFor('-', {
        'a': _S('Calle Sucre'),
        'b': _S('Jr. San-Martín'),
      });
      expect(names, ['Jr. San-Martín']);
    });
  });
}
