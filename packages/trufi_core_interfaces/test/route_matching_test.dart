import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Regression: in a hybrid deploy (bundled-GTFS routing + OTP vehicles,
/// the Lima pilot) itinerary legs carry `1132` while OTP vehicles carry
/// `1:1132`. Strict-equality matching made every live bus disappear the
/// moment a search was active, and killed the LIVE badge too.
class _FakeProvider implements RealtimeVehiclesProvider {
  _FakeProvider(this.latest);

  @override
  final List<VehiclePosition> latest;

  @override
  Stream<List<VehiclePosition>> get positionsStream => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  void stop() {}
}

VehiclePosition _vehicle(String id, String? routeId) => VehiclePosition(
  vehicleId: id,
  position: const TrufiLatLng(-12.0, -77.0),
  routeId: routeId,
);

void main() {
  test('stripGtfsFeedPrefix', () {
    expect(stripGtfsFeedPrefix('1:1132'), '1132');
    expect(stripGtfsFeedPrefix('1132'), '1132');
    expect(stripGtfsFeedPrefix('otp-lima:1481'), '1481');
  });

  group('feed-agnostic route matching', () {
    final provider = _FakeProvider([
      _vehicle('A', '1:1132'),
      _vehicle('B', '1132'),
      _vehicle('C', '1:1185'),
      _vehicle('D', null),
    ]);

    test('vehiclesForRoute matches across feed prefixes both ways', () {
      expect(
        provider.vehiclesForRoute('1132').map((v) => v.vehicleId),
        ['A', 'B'],
        reason: 'bare query id must match prefixed vehicle ids',
      );
      expect(
        provider.vehiclesForRoute('1:1132').map((v) => v.vehicleId),
        ['A', 'B'],
        reason: 'prefixed query id must match bare vehicle ids',
      );
    });

    test('vehiclesForRoutes with a mixed-prefix set', () {
      expect(
        provider
            .vehiclesForRoutes({'1132', 'lima:1185'})
            .map((v) => v.vehicleId),
        ['A', 'B', 'C'],
      );
    });

    test('hasDataForRoute powers the LIVE badge across prefixes', () {
      expect(provider.hasDataForRoute('1132'), isTrue);
      expect(provider.hasDataForRoute('1:1132'), isTrue);
      expect(provider.hasDataForRoute('1481'), isFalse);
    });

    test('vehicles without route never match', () {
      expect(
        provider.vehiclesForRoute('').map((v) => v.vehicleId),
        isEmpty,
        reason: 'null routeId must not match an empty query',
      );
    });
  });
}
