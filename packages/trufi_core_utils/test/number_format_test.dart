import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

void main() {
  group('safeNumberFormat (#945 fresh review)', () {
    test('known locales keep their symbols', () {
      expect(safeNumberFormat('#,##0.0', 'es').format(27.1), '27,1');
      expect(safeNumberFormat('#,##0.0', 'en').format(27.1), '27.1');
    });

    test('a locale intl has no number symbols for must not throw', () {
      // Quechua/Aymara/Guaraní are exactly the languages cities add via
      // the N-language model; NumberFormat('...', 'qu') throws an
      // ArgumentError without this fallback.
      expect(() => safeNumberFormat('#,##0.0', 'qu').format(27.1),
          returnsNormally);
      expect(() => safeNumberFormat('#,##0', 'ay').format(790),
          returnsNormally);
    });
  });
}
