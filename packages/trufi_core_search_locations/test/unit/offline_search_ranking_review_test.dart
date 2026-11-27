import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Cases found in the review of the street ranking (Lima #18).

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

Future<List<String>> _refsFor(
  String query,
  Map<String, _S> streets, {
  int limit = 10,
  LatLng? focus,
}) async {
  final asset = 'assets/search/review-${_indexes++}.json';
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

  group('F1: a typed query also finds names that contain its type word', () {
    test('"camino real" finds "Avenida Camino Real"', () async {
      final refs = await _refsFor('camino real', {
        'av': _S('Avenida Camino Real'),
        'other': _S('Avenida Grau'),
      });
      expect(refs, ['av']);
    });

    test('"calle 26" finds "Avenida Calle 26"', () async {
      final refs = await _refsFor('calle 26', {
        'av': _S('Avenida Calle 26'),
        'calle': _S('Calle 26', region: 'B'),
        'other': _S('Calle 27', region: 'C'),
      });
      expect(refs, ['av', 'calle']);
    });

    test('"prolongacion arica" finds "Avenida Prolongación Arica"', () async {
      final refs = await _refsFor('prolongacion arica', {
        'av': _S('Avenida Prolongación Arica'),
      });
      expect(refs, ['av']);
    });

    test('the class filter still leaves out other types', () async {
      final refs = await _refsFor('avenida grau', {'calle': _S('Calle Grau')});
      expect(refs, isEmpty);
    });
  });

  group('F2: the exact name is not pushed out by substring matches', () {
    test(
      '"ica" with 31 avenues like "Avenida Arica" and a limit of 30',
      () async {
        final refs = await _refsFor('ica', {
          for (var i = 0; i < 31; i++)
            'arica$i': _S('Avenida Arica', region: 'Town $i', corners: 50),
          'jiron': _S('Jirón Ica', region: 'J'),
          'exact': _S('Ica', region: 'E'),
        }, limit: 30);
        expect(refs.length, 30);
        expect(refs, containsAll(['jiron', 'exact']));
        expect(refs.take(2), ['exact', 'jiron']);
      },
    );

    test('with a focus, a nearer substring match does not pass the exact '
        'name', () async {
      final refs = await _refsFor('ica', {
        'arica': _S('Calle Arica', lat: -12.0464, lon: -77.0428),
        'exact': _S('Calle Ica', lat: -11.77, lon: -77.17),
      }, focus: LatLng(-12.0464, -77.0428));
      expect(refs, ['exact', 'arica']);
    });
  });

  group('F6: without focus the type word length does not order', () {
    test(
      '"ica": jirón and prolongación by corners, not by type word',
      () async {
        final refs = await _refsFor('ica', {
          'jr': _S('Jirón Ica', region: 'A', corners: 1),
          'prol': _S('Prolongación Ica', region: 'B', corners: 5),
        });
        expect(refs, ['prol', 'jr']);
      },
    );
  });

  group('F8: the lowest class among the matching names', () {
    test(
      'main "Grau" with the alternative "Avenida Grau" ranks as avenue',
      () async {
        final refs = await _refsFor('grau', {
          'plain': _S('Grau', region: 'A', corners: 9),
          'alt': _S('Grau', region: 'B', alts: ['Avenida Grau'], corners: 1),
        });
        expect(refs, ['alt', 'plain']);
      },
    );
  });

  group('F9: words split on any non-letter', () {
    test('"avenida huaylas" finds "Avenida Ex-Huaylas"', () async {
      final refs = await _refsFor('avenida huaylas', {
        'av': _S('Avenida Ex-Huaylas'),
      });
      expect(refs, ['av']);
    });

    test('"av.grau" finds "Avenida Grau"', () async {
      final refs = await _refsFor('av.grau', {'av': _S('Avenida Grau')});
      expect(refs, ['av']);
    });
  });

  group('F11: the main name before the alternative at equal text match', () {
    test('without focus, a main-name match beats an alternative one', () async {
      final refs = await _refsFor('bolivar simon', {
        'alt': _S('Calle X', alts: ['Simón de Bolívar'], corners: 50),
        'main': _S('Calle Simón Bolívar', region: 'B', corners: 1),
      });
      expect(refs, ['main', 'alt']);
    });
  });
}
