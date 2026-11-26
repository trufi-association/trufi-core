import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';

import 'support/home_harness.dart';

/// trufi-lima#12, the case that must not change: a deploy without
/// `serviceArea` (every other city) still flies to any fix, silently.
void main() {
  installHomeTestDefaults();

  const laPaz = LatLng(-16.4897, -68.1193);

  testWidgets('no serviceArea: my location moves the camera to the fix and '
      'shows no SnackBar', (tester) async {
    mockGeolocatorWithFix(laPaz);
    final cubit = RoutePlannerCubit(
      repository: MemoryHomeRepository(),
      requestService: ScriptedPlanService(),
    );
    addTearDown(cubit.close);
    await cubit.initialize();
    final moves = await pumpHome(tester, cubit);

    await tester.tap(find.byIcon(Icons.my_location_rounded));
    await tester.pumpAndSettle();

    expect(moves.moves.any((m) => m.target == laPaz && m.zoom == 16), isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });
}
