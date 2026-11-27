import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// trufi-lima#12 (reopened): the navigation's "outside the service area"
/// notice exists in each language of the package, with its placeholder, and
/// the English template documents it. Reads the ARB files (the source of the
/// generated getters); flutter test runs with the package root as working
/// directory.
void main() {
  Map<String, dynamic> arb(String lang) =>
      jsonDecode(File('lib/l10n/navigation_$lang.arb').readAsStringSync())
          as Map<String, dynamic>;

  final en = arb('en');
  final es = arb('es');
  final de = arb('de');

  const keys = ['navOutsideServiceArea', 'navOutsideServiceAreaUnnamed'];
  const withPlaceholder = {'navOutsideServiceArea': '{name}'};

  for (final key in keys) {
    test('$key exists, non-empty, in en / es / de', () {
      for (final entry in {'en': en, 'es': es, 'de': de}.entries) {
        final value = entry.value[key];
        expect(value, isA<String>(), reason: '$key missing in ${entry.key}');
        expect((value as String).trim(), isNotEmpty);
        final placeholder = withPlaceholder[key];
        if (placeholder != null) {
          expect(value, contains(placeholder), reason: '${entry.key}/$key');
        } else {
          expect(value, isNot(contains('{')), reason: '${entry.key}/$key');
        }
      }
    });

    test('$key is documented in the English template', () {
      expect(en['@$key'], isA<Map<String, dynamic>>());
      expect((en['@$key'] as Map)['description'], isNotEmpty);
    });
  }

  test('the named notice takes a String name placeholder', () {
    final meta = en['@navOutsideServiceArea'] as Map<String, dynamic>;
    final placeholders = meta['placeholders'] as Map<String, dynamic>;
    expect(placeholders.keys, contains('name'));
  });
}
