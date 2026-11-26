import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// trufi-lima#14: `VehiclePosition.headsign`, optional, in copyWith and props.
void main() {
  const position = TrufiLatLng(-12.0, -77.0);

  test('headsign defaults to null', () {
    expect(
      const VehiclePosition(vehicleId: 'v', position: position).headsign,
      isNull,
    );
  });

  test('copyWith sets it and keeps it when not given', () {
    const bare = VehiclePosition(vehicleId: 'v', position: position);
    final withHeadsign = bare.copyWith(headsign: 'MINKA');
    expect(withHeadsign.headsign, 'MINKA');
    expect(withHeadsign.copyWith(label: 'x').headsign, 'MINKA');
  });

  test('it takes part in equality', () {
    const a = VehiclePosition(
      vehicleId: 'v',
      position: position,
      headsign: 'MINKA',
    );
    const b = VehiclePosition(
      vehicleId: 'v',
      position: position,
      headsign: 'JICAMARCA',
    );
    expect(a, isNot(b));
    expect(
      a,
      const VehiclePosition(
        vehicleId: 'v',
        position: position,
        headsign: 'MINKA',
      ),
    );
  });
}
