import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// #1004: ETA answers carry the route id the SOURCE uses (`1:1132` from OTP
/// vehicles, `1132` from a bundled-GTFS planner). Lookups must be
/// feed-agnostic in both directions or a hybrid deploy shows "unavailable"
/// for every route that is in fact reporting.
VehicleEta _eta(String routeId, int seconds, {String? vehicleId}) => VehicleEta(
  routeId: routeId,
  eta: Duration(seconds: seconds),
  timestamp: DateTime(2026, 10, 13, 10, 30),
  vehicleId: vehicleId,
);

void main() {
  group('VehicleEta.minutes', () {
    test('rounds up and never shows zero', () {
      expect(_eta('1132', 10).minutes, 1, reason: '10 s away is "~1 min"');
      expect(_eta('1132', 0).minutes, 1, reason: 'never "~0 min"');
      expect(_eta('1132', 240).minutes, 4);
      expect(
        _eta('1132', 250).minutes,
        5,
        reason: '"~N" means "at most N": 4:10 must read ~5, not ~4',
      );
    });
  });

  group('VehicleEta.matchesRoute', () {
    test('ignores the feed prefix on both sides', () {
      expect(_eta('1:1132', 60).matchesRoute('1132'), isTrue);
      expect(_eta('1132', 60).matchesRoute('1:1132'), isTrue);
      expect(_eta('lima:1132', 60).matchesRoute('otp:1132'), isTrue);
      expect(_eta('1:1132', 60).matchesRoute('1:1185'), isFalse);
    });
  });

  group('VehicleEtaSnapshotQueries', () {
    final snapshot = VehicleEtaSnapshot(
      etas: [
        _eta('1:1132', 240, vehicleId: 'A'),
        _eta('1132', 600, vehicleId: 'B'),
        _eta('1:1185', 120, vehicleId: 'C'),
      ],
      fetchedAt: DateTime(2026, 10, 13, 10, 30),
    );

    test('etaForRoute returns the soonest match across prefixes', () {
      expect(
        snapshot.etaForRoute('1132')?.vehicleId,
        'A',
        reason:
            'bare query must match the prefixed 240 s entry, not just '
            'the literal 600 s one',
      );
      expect(
        snapshot.etaForRoute('1:1132')?.vehicleId,
        'A',
        reason: 'prefixed query must consider the bare entry too',
      );
      expect(snapshot.etaForRoute('1185')?.vehicleId, 'C');
      expect(snapshot.etaForRoute('1481'), isNull);
    });

    test('bestEtaByRoute keys by the stripped id and keeps the soonest', () {
      final best = snapshot.bestEtaByRoute;
      expect(best.keys, unorderedEquals(['1132', '1185']));
      expect(best['1132']?.vehicleId, 'A');
      expect(best['1132']?.eta, const Duration(seconds: 240));
    });

    test('empty snapshot answers nothing', () {
      final empty = VehicleEtaSnapshot.empty(DateTime(2026, 10, 13));
      expect(empty.etas, isEmpty);
      expect(empty.etaForRoute('1132'), isNull);
      expect(empty.bestEtaByRoute, isEmpty);
    });
  });

  test('VehicleEtaException carries status and cause in toString', () {
    const plain = VehicleEtaException('down');
    expect(plain.toString(), 'VehicleEtaException: down');
    final full = VehicleEtaException(
      'down',
      statusCode: 503,
      cause: Exception('socket'),
    );
    expect(full.toString(), contains('HTTP 503'));
    expect(full.toString(), contains('socket'));
  });
}
