import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/simple_opening_hours.dart';

// 2026-10-26 is a Monday, 2026-11-01 a Sunday.
final monday = DateTime(2026, 10, 26);
final sunday = DateTime(2026, 11, 1);
DateTime at(DateTime day, int hour, [int minute = 0]) =>
    DateTime(day.year, day.month, day.day, hour, minute);

void main() {
  group('single departures', () {
    test('a bare time is a departure on every selected day', () {
      final oh = SimpleOpeningHours('Mo-Su 17:30');
      for (final key in ['mo', 'tu', 'we', 'th', 'fr', 'sa', 'su']) {
        expect(oh.departuresOf(key), ['17:30'], reason: key);
        expect(oh.rangesOf(key), isEmpty, reason: key);
      }
      expect(oh.departuresOf('ph'), isEmpty);
    });

    test('departures separated by commas come out sorted and zero-padded', () {
      final oh = SimpleOpeningHours('Mo-Fr 7:10,05:00');
      expect(oh.departuresOf('mo'), ['05:00', '07:10']);
      expect(oh.departuresOf('fr'), ['05:00', '07:10']);
      expect(oh.departuresOf('sa'), isEmpty);
      expect(oh.nextDepartureOn(at(monday, 6)), '07:10');
    });

    test('service windows and departures mix across rules', () {
      final oh = SimpleOpeningHours('Mo-Sa 05:30-18:50; Su 08:00');
      expect(oh.rangesOf('sa'), ['05:30-18:50']);
      expect(oh.departuresOf('sa'), isEmpty);
      expect(oh.rangesOf('su'), isEmpty);
      expect(oh.departuresOf('su'), ['08:00']);
    });

    test('the next departure is the first one at or after the time of day', () {
      final oh = SimpleOpeningHours('Mo-Su 05:00,07:10');
      expect(oh.nextDepartureOn(at(monday, 4, 59)), '05:00');
      expect(oh.nextDepartureOn(at(monday, 5)), '05:00');
      expect(oh.nextDepartureOn(at(monday, 6)), '07:10');
      expect(oh.nextDepartureOn(at(monday, 7, 10)), '07:10');
      expect(oh.nextDepartureOn(at(monday, 7, 11)), isNull);
    });

    test('the line is open while a departure is still ahead', () {
      final oh = SimpleOpeningHours('Mo-Su 17:30');
      expect(oh.isOpenOn(at(monday, 10)), isTrue);
      expect(oh.isOpenOn(at(monday, 17, 30)), isTrue);
      expect(oh.isOpenOn(at(monday, 17, 31)), isFalse);
      expect(oh.isWithinServiceWindowOn(at(monday, 10)), isFalse);
    });

    test('a departure-only day has no closing time', () {
      expect(SimpleOpeningHours('Mo-Su 17:30').getClosingTimeOfDay(monday),
          isNull);
      expect(
        SimpleOpeningHours('Mo-Su 05:00-07:10,17:30')
            .getClosingTimeOfDay(monday),
        '07:10',
      );
    });

    test('isDeparture tells a time from a window or an open-ended time', () {
      expect(SimpleOpeningHours.isDeparture('17:30'), isTrue);
      expect(SimpleOpeningHours.isDeparture('7:30'), isTrue);
      expect(SimpleOpeningHours.isDeparture('05:00-17:30'), isFalse);
      expect(SimpleOpeningHours.isDeparture('09:00+'), isFalse);
      expect(SimpleOpeningHours.isDeparture('off'), isFalse);
    });

    test('isDeparture rejects times that do not exist', () {
      expect(SimpleOpeningHours.isDeparture('23:59'), isTrue);
      expect(SimpleOpeningHours.isDeparture('00:00'), isTrue);
      expect(SimpleOpeningHours.isDeparture('24:00'), isFalse);
      expect(SimpleOpeningHours.isDeparture('25:99'), isFalse);
      expect(SimpleOpeningHours.isDeparture('17:60'), isFalse);
      expect(SimpleOpeningHours('Mo-Su 25:99').departuresOf('mo'), isEmpty);
    });
  });

  group('service windows', () {
    test('a window is open inside and closed outside', () {
      final oh = SimpleOpeningHours('Mo-Su 04:00-05:45');
      expect(oh.isOpenOn(at(monday, 5)), isTrue);
      expect(oh.isWithinServiceWindowOn(at(monday, 5)), isTrue);
      expect(oh.isOpenOn(at(monday, 10)), isFalse);
      expect(oh.getClosingTimeOfDay(monday), '05:45');
      expect(oh.departuresOn(monday), isEmpty);
      expect(oh.rangesOn(monday), ['04:00-05:45']);
    });

    test('a day split in two windows is open inside the first one', () {
      // The previous implementation let the last window overwrite the
      // verdict of the first one.
      final oh = SimpleOpeningHours('Mo-Su 08:00-12:00,14:00-18:00');
      expect(oh.isOpenOn(at(monday, 10)), isTrue);
      expect(oh.isOpenOn(at(monday, 13)), isFalse);
      expect(oh.isOpenOn(at(monday, 15)), isTrue);
      expect(oh.rangesOn(monday), ['08:00-12:00', '14:00-18:00']);
    });

    test('an overnight window wraps past midnight', () {
      final oh = SimpleOpeningHours('Mo-Su 22:00-02:00');
      expect(oh.isOpenOn(at(monday, 23)), isTrue);
      expect(oh.isOpenOn(at(monday, 1)), isTrue);
      expect(oh.isOpenOn(at(monday, 12)), isFalse);
    });

    test('off clears a day', () {
      final oh = SimpleOpeningHours('Mo-Sa 05:30-18:50; Su off');
      expect(oh.rangesOf('sa'), ['05:30-18:50']);
      expect(oh.rangesOf('su'), isEmpty);
      expect(oh.departuresOf('su'), isEmpty);
      expect(oh.isOpenOn(at(sunday, 10)), isFalse);
    });

    test('weekday ranges that wrap the week', () {
      final oh = SimpleOpeningHours('Sa-Mo 06:00-20:00');
      expect(oh.rangesOf('sa'), ['06:00-20:00']);
      expect(oh.rangesOf('su'), ['06:00-20:00']);
      expect(oh.rangesOf('mo'), ['06:00-20:00']);
      expect(oh.rangesOf('tu'), isEmpty);
    });
  });
}
