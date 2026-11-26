import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

void main() {
  final at = DateTime(2026, 11, 26, 12);

  test('empty() keeps routesWithVehicles when given', () {
    final snapshot = VehicleEtaSnapshot.empty(
      at,
      routesWithVehicles: const {'1132'},
    );

    expect(snapshot.etas, isEmpty);
    expect(snapshot.knowsRoutesWithVehicles, isTrue);
    expect(snapshot.routesWithVehicles, {'1132'});
  });

  test('empty() without it does not know which routes have vehicles', () {
    final snapshot = VehicleEtaSnapshot.empty(at);

    expect(snapshot.knowsRoutesWithVehicles, isFalse);
  });
}
