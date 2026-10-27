import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

TransportRoute _route(String longName) => TransportRoute(
  id: 'r',
  code: '7',
  name: '7',
  shortName: '7',
  longName: longName,
);

void main() {
  group('route_long_name terminals', () {
    test('"A → B" (trufi-gtfs-builder) reads from A to B', () {
      final r = _route('Terminal Norte → Plaza Principal');
      expect(r.hasOriginDestination, isTrue);
      expect(r.longNameStart, 'Terminal Norte');
      expect(r.longNameLast, 'Plaza Principal');
    });

    test('Sana\'a: Arabic name with "⟵" keeps the written order', () {
      final r = _route('الحثيلي ⟵ باب اليمن');
      expect(r.hasOriginDestination, isTrue);
      expect(r.longNameStart, 'الحثيلي');
      expect(r.longNameLast, 'باب اليمن');
    });

    test('a left arrow in a left-to-right name swaps the halves', () {
      expect(
        _route('Plaza Principal ← Terminal Norte').longNameStart,
        'Terminal Norte',
      );
      expect(
        _route('Plaza Principal <- Terminal Norte').longNameLast,
        'Plaza Principal',
      );
    });

    test('"->", "⟶" and spaced dashes are arrows too', () {
      expect(_route('A -> B').longNameLast, 'B');
      expect(_route('A ⟶ B').longNameLast, 'B');
      expect(
        _route('Litoral - Carlos Blanco Galindo').longNameStart,
        'Litoral',
      );
      expect(
        _route('Litoral – Carlos Blanco Galindo').longNameLast,
        'Carlos Blanco Galindo',
      );
    });

    test('a "<short>: " prefix is stripped before splitting', () {
      final r = _route('Trufi 252: Litoral → Carlos Blanco Galindo');
      expect(r.longNameStart, 'Litoral');
      expect(r.longNameLast, 'Carlos Blanco Galindo');
    });

    test(
      'no arrow, two arrows, an empty half or an unspaced dash: no terminals',
      () {
        for (final name in [
          'MiniBus 270',
          'A → B → C',
          ' → B',
          'Villa Coronilla-Sur',
          'Jean-Paul → ',
        ]) {
          final r = _route(name);
          expect(r.hasOriginDestination, isFalse, reason: name);
          expect(r.longNameStart, r.longNameLast, reason: name);
        }
        // A hyphenated place name with a real arrow still splits on the arrow.
        final r = _route('Jean-Paul → Villa Coronilla-Sur');
        expect(r.longNameStart, 'Jean-Paul');
        expect(r.longNameLast, 'Villa Coronilla-Sur');
      },
    );
  });
}
