import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

class _Fleet implements RealtimeVehiclesProvider {
  _Fleet(this.latest);
  @override
  final List<VehiclePosition> latest;
  @override
  Stream<List<VehiclePosition>> get positionsStream => const Stream.empty();
  @override
  Future<void> start() async {}
  @override
  void stop() {}
}

void main() {
  final now = DateTime(2026, 11, 26, 12);
  VehiclePosition bus({DateTime? at}) => VehiclePosition(
    vehicleId: 'b',
    position: const TrufiLatLng(-12.05, -77.04),
    routeId: '1:1132',
    timestamp: at,
  );

  test('a vehicle that reported within 5 min counts', () {
    final fleet = _Fleet([bus(at: now.subtract(const Duration(minutes: 5)))]);
    expect(fleet.hasDataForRoute('1132', now: now), isTrue);
  });

  test('a route whose only vehicle is older than 5 min has no data', () {
    final fleet = _Fleet([
      bus(at: now.subtract(const Duration(minutes: 5, seconds: 1))),
    ]);
    expect(fleet.hasDataForRoute('1132', now: now), isFalse);
  });

  test('a vehicle with no timestamp counts as fresh', () {
    expect(_Fleet([bus()]).hasDataForRoute('1:1132', now: now), isTrue);
  });
}
