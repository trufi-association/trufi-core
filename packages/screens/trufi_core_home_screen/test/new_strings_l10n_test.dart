import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// trufi-lima #9, #12, #13, #14: every new string exists in each language of
/// the package, with its placeholder, and the English template documents it.
/// Reads the ARB files (the source of the generated getters); flutter test
/// runs with the package root as working directory.
void main() {
  Map<String, dynamic> arb(String lang) =>
      jsonDecode(File('lib/l10n/home_screen_$lang.arb').readAsStringSync())
          as Map<String, dynamic>;

  final en = arb('en');
  final es = arb('es');
  final de = arb('de');

  const keys = [
    'errorNoConnection',
    'errorPlanFailed',
    'etaNoneNearby',
    'liveDataTooltip',
    'liveVehicleHeadsign',
    'outsideServiceArea',
    'showServiceArea',
  ];
  const withPlaceholder = {
    'liveVehicleHeadsign': '{headsign}',
    'outsideServiceArea': '{name}',
    'showServiceArea': '{name}',
  };

  for (final key in keys) {
    test('$key exists, non-empty, in en / es / de', () {
      for (final entry in {'en': en, 'es': es, 'de': de}.entries) {
        final value = entry.value[key];
        expect(value, isA<String>(), reason: '$key missing in ${entry.key}');
        expect((value as String).trim(), isNotEmpty);
        final placeholder = withPlaceholder[key];
        if (placeholder != null) {
          expect(value, contains(placeholder), reason: '${entry.key}/$key');
        }
      }
    });

    test('$key is documented in the English template', () {
      expect(en['@$key'], isA<Map<String, dynamic>>());
      expect((en['@$key'] as Map)['description'], isNotEmpty);
    });
  }

  test('the texts of the report (en / es)', () {
    expect(
      en['errorNoConnection'],
      'No internet connection. Check your connection and try again.',
    );
    expect(
      es['errorNoConnection'],
      'Sin conexión a internet. Revisa tu conexión e inténtalo de nuevo.',
    );
    expect(
      en['errorPlanFailed'],
      "We couldn't search for routes. Please try again.",
    );
    expect(
      es['errorPlanFailed'],
      'No pudimos buscar rutas. Inténtalo de nuevo.',
    );
    expect(en['etaNoneNearby'], 'No buses nearby right now');
    expect(es['etaNoneNearby'], 'Sin buses cerca ahora');
    expect(en['liveDataTooltip'], 'Live');
    expect(es['liveDataTooltip'], 'En vivo');
    expect(de['liveDataTooltip'], 'Live');
    expect(en['liveVehicleHeadsign'], 'Towards {headsign}');
    expect(es['liveVehicleHeadsign'], 'Hacia {headsign}');
    expect(de['liveVehicleHeadsign'], 'Richtung {headsign}');
    expect(en['outsideServiceArea'], 'You are outside {name}');
    expect(es['outsideServiceArea'], 'Estás fuera de {name}');
    expect(es['showServiceArea'], 'Ver {name}');
  });

  test('the German texts are translated, not the English ones', () {
    for (final key in [
      'errorNoConnection',
      'errorPlanFailed',
      'etaNoneNearby',
      'outsideServiceArea',
      'showServiceArea',
    ]) {
      expect(de[key], isNot(en[key]), reason: '$key is still English in de');
    }
  });
}
