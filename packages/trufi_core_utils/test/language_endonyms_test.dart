import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

void main() {
  group('languageEndonyms / displayNameForCode', () {
    test('covers every ISO 639-1 language', () {
      expect(languageEndonyms.length, greaterThanOrEqualTo(180));
    });

    test('languages Trufi ships keep their curated names', () {
      expect(LocaleManager.displayNameForCode('en'), 'English');
      expect(LocaleManager.displayNameForCode('es'), 'Español');
      expect(LocaleManager.displayNameForCode('de'), 'Deutsch');
      expect(LocaleManager.displayNameForCode('ar'), 'العربية');
    });

    test('city languages beyond the shipped set resolve to endonyms', () {
      expect(LocaleManager.displayNameForCode('qu'), 'Runa Simi');
      expect(LocaleManager.displayNameForCode('ay'), 'aymar aru');
      expect(LocaleManager.displayNameForCode('gn'), "Avañe'ẽ");
      expect(LocaleManager.displayNameForCode('fa'), 'فارسی');
      expect(LocaleManager.displayNameForCode('am'), 'አማርኛ');
    });

    test('unknown codes fall back to the uppercased code', () {
      expect(LocaleManager.displayNameForCode('xx'), 'XX');
    });

    test('no entry is empty or whitespace', () {
      for (final entry in languageEndonyms.entries) {
        expect(entry.value.trim(), isNotEmpty, reason: entry.key);
      }
    });
  });
}
