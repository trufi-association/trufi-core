import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// #1023: `TrufiLocation` equality ignores the address, so without this the
/// cubit's `emit(state.copyWith(fromPlace: resolved))` was a no-op and the
/// Home field kept the bare pair until the next restart (found on the
/// emulator: Photon answered, the repository saved it, the field never
/// changed).
void main() {
  const bare = TrufiLocation(
    description: '-17.37, -66.14',
    latitude: -17.37,
    longitude: -66.14,
  );
  const resolved = TrufiLocation(
    description: '-17.37, -66.14',
    latitude: -17.37,
    longitude: -66.14,
    address: 'Calle Los Cedros, Cochabamba',
  );

  test('a place that only gained its address is a new planner state', () {
    expect(
      bare,
      resolved,
      reason: 'TrufiLocation equality ignores the address',
    );
    const empty = RoutePlannerState();
    expect(
      empty.copyWith(fromPlace: bare),
      isNot(equals(empty.copyWith(fromPlace: resolved))),
    );
    expect(
      empty.copyWith(toPlace: bare),
      isNot(equals(empty.copyWith(toPlace: resolved))),
    );
    expect(
      empty.copyWith(fromPlace: bare),
      equals(empty.copyWith(fromPlace: bare)),
      reason: 'same place, same address: still equal',
    );
  });
}
