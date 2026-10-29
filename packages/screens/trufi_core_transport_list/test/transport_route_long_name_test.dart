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

    test('a right-to-left name keeps its written order whatever the arrow', () {
      // Arrows are not bidi-mirrored: in RTL text the first written half is
      // the origin, with "⟵" (Sana'a) and with "→" alike.
      final r = _route('الحصبة → المطار');
      expect(r.hasOriginDestination, isTrue);
      expect(r.longNameStart, 'الحصبة');
      expect(r.longNameLast, 'المطار');
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

    test('several arrows of one direction: the terminals are the first and the '
        'last part, the middle ones are vias', () {
      final abc = _route('A → B → C');
      expect(abc.hasOriginDestination, isTrue);
      expect(abc.longNameStart, 'A');
      expect(abc.longNameLast, 'C');
      // Sana'a: 25 of its 194 names carry a via.
      final sanaa = _route('جامعة ارحب ⟵ المطار ⟵ الحصبة');
      expect(sanaa.hasOriginDestination, isTrue);
      expect(sanaa.longNameStart, 'جامعة ارحب');
      expect(sanaa.longNameLast, 'الحصبة');
      // Arequipa's circular C-9: the same terminal at both ends.
      final c9 = _route(
        'C-9 Bus "Simon Bolivar": Cruce Sabandía → Av. Independencia → '
        'Cruce Sabandía',
      );
      expect(c9.hasOriginDestination, isTrue);
      expect(c9.longNameStart, 'Cruce Sabandía');
      expect(c9.longNameLast, 'Cruce Sabandía');
      // Left arrows in a left-to-right name swap the ends, not the vias.
      final left = _route('C ← B ← A');
      expect(left.longNameStart, 'A');
      expect(left.longNameLast, 'C');
    });

    test('a real arrow wins over a spaced dash inside a half', () {
      final r = _route('Zona Sud - Ticti → Centro');
      expect(r.hasOriginDestination, isTrue);
      expect(r.longNameStart, 'Zona Sud - Ticti');
      expect(r.longNameLast, 'Centro');
      final left = _route('Centro <- Zona Sud - Ticti');
      expect(left.longNameStart, 'Zona Sud - Ticti');
      expect(left.longNameLast, 'Centro');
    });

    test('no arrow, mixed directions, two dashes, an empty half or an unspaced '
        'dash: no terminals', () {
      for (final name in [
        'MiniBus 270',
        'A → B ← C',
        'A - B - C',
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
    });
  });
}
