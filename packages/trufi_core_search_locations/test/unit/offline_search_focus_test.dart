import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Street order with a `focus` point (Lima #18): inside the same type class
/// and name kind, the street nearest to the focus first. Needs the
/// `focus` parameter of [OfflineSearchDataService], so before it exists this
/// file does not compile.

/// Cercado de Lima, the focus Lima's app passes.
final _cercado = LatLng(-12.0464, -77.0428);

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
        <String>[],
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

Future<List<String>> _refsFor(
  String query,
  Map<String, _S> streets, {
  LatLng? focus,
  int limit = 10,
}) async {
  final asset = 'assets/search/focus-${_indexes++}.json';
  _assets[asset] = _indexOf(streets);
  final service = OfflineSearchDataService(
    assetPath: asset,
    limitPerCategory: limit,
    focus: focus,
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

  group('AC3: "grau" with the focus at Cercado', () {
    final grau = {
      // Few corners on purpose: only the class and the distance may put
      // it first.
      'lima': _S('Avenida Almirante Miguel Grau', corners: 1),
      'ancon': _S(
        'Avenida Grau',
        region: 'Ancón',
        corners: 60,
        lat: -11.77,
        lon: -77.17,
      ),
      'calle': _S(
        'Calle Grau',
        region: 'Callao',
        corners: 3,
        lat: -12.05,
        lon: -77.12,
      ),
      'ventanilla': _S(
        'Grau',
        region: 'Ventanilla',
        corners: 40,
        lat: -11.87,
        lon: -77.12,
      ),
      'pasaje': _S('Pasaje Grau', corners: 90),
    };

    test('the avenue of Lima first; then the far avenue; then the calles by '
        'distance; the pasaje last', () async {
      final refs = await _refsFor('grau', grau, focus: _cercado);
      expect(refs, ['lima', 'ancon', 'calle', 'ventanilla', 'pasaje']);
    });

    test('"avenida grau": the avenue of Lima first, no calle or pasaje',
        () async {
      final refs = await _refsFor('avenida grau', grau, focus: _cercado);
      expect(refs, ['lima', 'ancon']);
    });
  });

  group('AC4: "alfonso ugarte" with the focus', () {
    test('the avenue of Lima first with a limit of 3, though jirones and '
        'calles have more corners and are nearer', () async {
      final refs = await _refsFor(
        'alfonso ugarte',
        {
          'jr1': _S('Jirón Alfonso Ugarte', corners: 12, region: 'Breña'),
          'jr2': _S('Jirón Alfonso Ugarte', corners: 11, region: 'Rímac'),
          'calle': _S('Calle Alfonso Ugarte', corners: 10, region: 'Callao'),
          'untyped': _S('Alfonso Ugarte', corners: 9, region: 'Comas'),
          'av': _S(
            'Avenida Alfonso Ugarte',
            corners: 2,
            lat: -12.06,
            lon: -77.05,
          ),
          'avFar': _S(
            'Avenida Alfonso Ugarte',
            region: 'Ancón',
            corners: 30,
            lat: -11.77,
            lon: -77.17,
          ),
        },
        focus: _cercado,
        limit: 3,
      );
      expect(refs.first, 'av');
      expect(refs[1], 'avFar');
      expect(refs.length, 3);
    });
  });

  group('the focus orders inside the class, never across it', () {
    final twins = {
      'near': _S('Avenida Grau', region: 'Near', corners: 1),
      'far': _S(
        'Avenida Grau',
        region: 'Far',
        corners: 50,
        lat: -11.77,
        lon: -77.17,
      ),
      'nearCalle': _S('Calle Grau', region: 'Near calle', corners: 99),
    };

    test('same name, same class: the nearest first, whatever its corners',
        () async {
      final refs = await _refsFor('avenida grau', twins, focus: _cercado);
      expect(refs, ['near', 'far']);
    });

    test('a nearer calle does not pass a farther avenue', () async {
      final refs = await _refsFor('grau', twins, focus: _cercado);
      expect(refs, ['near', 'far', 'nearCalle']);
    });

    test('without focus the same index orders by corners (#1054)', () async {
      final refs = await _refsFor('avenida grau', twins);
      expect(refs, ['far', 'near']);
    });

    test('a focus on the far side flips the order', () async {
      final refs = await _refsFor(
        'avenida grau',
        twins,
        focus: LatLng(-11.77, -77.17),
      );
      expect(refs, ['far', 'near']);
    });
  });
}
