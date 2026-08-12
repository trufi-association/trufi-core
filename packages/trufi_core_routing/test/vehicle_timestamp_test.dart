import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// #981 review blocker: the provider used to stamp `DateTime.now()` at parse
/// time (and didn't even request the feed's field), so every vehicle looked
/// "just updated" forever. These pin the real semantics: the timestamp is
/// the vehicle's own report time from the GTFS-RT feed.
void main() {
  group('OtpVehiclePositionsProvider.parseVehicleTimestamp', () {
    test('prefers OTP lastUpdate (ISO-8601 with offset, as OTP 2.9 sends)', () {
      final ts = OtpVehiclePositionsProvider.parseVehicleTimestamp({
        'lastUpdate': '2026-08-11T23:30:49-05:00',
        'lastUpdated': 1786509049,
      });
      expect(
        ts.toUtc(),
        DateTime.utc(2026, 8, 12, 4, 30, 49),
        reason: '23:30:49-05:00 is 04:30:49Z',
      );
    });

    test('falls back to deprecated epoch lastUpdated for older servers', () {
      final ts = OtpVehiclePositionsProvider.parseVehicleTimestamp({
        'lastUpdate': null,
        'lastUpdated': 1786509049,
      });
      expect(ts.toUtc(), DateTime.utc(2026, 8, 12, 4, 30, 49));
    });

    test('unparseable ISO still falls back to the epoch twin', () {
      final ts = OtpVehiclePositionsProvider.parseVehicleTimestamp({
        'lastUpdate': 'not-a-date',
        'lastUpdated': 1786509049,
      });
      expect(ts.toUtc(), DateTime.utc(2026, 8, 12, 4, 30, 49));
    });

    test('degrades to poll time only when the feed carries neither', () {
      final before = DateTime.now();
      final ts = OtpVehiclePositionsProvider.parseVehicleTimestamp({});
      final after = DateTime.now();
      expect(
        ts.isAfter(before.subtract(const Duration(seconds: 1))) &&
            ts.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });
}
