import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Cases found in the second review of the street ranking (Lima #18).

class _S {
  final String name;
  final String? region;
  final int corners;
  final double lat;
  final double lon;

  const _S(
    this.name, {
    this.region = 'Lima',
    this.corners = 0,
    this.lat = -12.05,
    this.lon = -77.03,
  });
}

Map<String, dynamic> _indexOf(Map<String, _S> streets) => {
  'streets': {
    for (final e in streets.entries)
      e.key: [
        e.value.name,
        const <String>[],
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

OfflineSearchDataService _serviceFor(
  Map<String, _S> streets, {
  int limit = 10,
  LatLng? focus,
  List<List<String>>? ranks,
}) {
  final asset = 'assets/search/review2-${_indexes++}.json';
  _assets[asset] = _indexOf(streets);
  final service = OfflineSearchDataService(
    assetPath: asset,
    limitPerCategory: limit,
    focus: focus,
    streetTypeRanks: ranks ?? OfflineSearchDataService.defaultStreetTypeRanks,
  );
  addTearDown(service.dispose);
  return service;
}

Future<List<String>> _namesFor(
  String query,
  Map<String, _S> streets, {
  int limit = 10,
  LatLng? focus,
}) async {
  final service = _serviceFor(streets, limit: limit, focus: focus);
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

  group('R1: whole-word matches come before prefix-of-word matches', () {
    test('"calle 1" keeps "Calle 1" among 11 "Avenida Calle 1x"', () async {
      final names = await _namesFor('calle 1', {
        for (var i = 0; i < 11; i++)
          'x$i': _S('Avenida Calle 1$i', region: 'T$i', corners: 20),
        'av': _S('Avenida Calle 1', region: 'A'),
        'calle': _S('Calle 1', region: 'C'),
      });
      expect(names, containsAll(['Avenida Calle 1', 'Calle 1']));
      expect(names.take(2), ['Avenida Calle 1', 'Calle 1']);
    });

    test('untyped "carrera 7" keeps "Carrera 7" among 9 "Avenida Carrera 7x"',
        () async {
      final names = await _namesFor('carrera 7', {
        for (var i = 0; i < 9; i++)
          'x$i': _S('Avenida Carrera 7$i', region: 'T$i', corners: 20),
        'carrera': _S('Carrera 7', region: 'C'),
      }, limit: 5);
      expect(names.first, 'Carrera 7');
    });

    test('with a focus, a nearer prefix match does not pass the exact name',
        () async {
      final names = await _namesFor('ica', {
        'icaro': _S('Jirón Icaro', lat: -12.0464, lon: -77.0428),
        'ica': _S('Jirón Ica', lat: -11.77, lon: -77.17),
      }, focus: LatLng(-12.0464, -77.0428));
      expect(names, ['Jirón Ica', 'Jirón Icaro']);
    });
  });

  group('R3: the type word of a typed query equals a whole word', () {
    test('"calle sucre" does not return "Callejón Sucre"', () async {
      final names = await _namesFor('calle sucre', {
        'callejon': _S('Callejón Sucre'),
        'calle': _S('Calle Sucre', region: 'B'),
      });
      expect(names, ['Calle Sucre']);
    });

    test('"av grau" does not return "Avelino Grau"', () async {
      final names = await _namesFor('av grau', {
        'avelino': _S('Avelino Grau'),
        'av': _S('Avenida Grau', region: 'B'),
      });
      expect(names, ['Avenida Grau']);
    });
  });

  group('R8: street type prefixes are normalized', () {
    test('capitalized and accented keys still match', () async {
      final service = _serviceFor(
        {
          'j': _S('Jirón Sucre', corners: 10),
          'a': _S('Avenida Sucre'),
        },
        ranks: const [
          ['Avenida'],
          ['Calle'],
          ['Jirón'],
        ],
      );
      final results = await service.search('sucre');
      final names = [for (final r in results) r.displayName];
      expect(names, ['Avenida Sucre', 'Jirón Sucre']);
    });
  });
}
