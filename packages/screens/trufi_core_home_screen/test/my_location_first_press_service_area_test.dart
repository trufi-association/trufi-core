import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'support/home_harness.dart';

/// trufi-lima#12, the paths `my_location_service_area_test.dart` does not
/// cover: the first press with tracking off, and the notice at startup.
void main() {
  installHomeTestDefaults();

  const limaArea = LatLngBounds(LatLng(-12.35, -77.20), LatLng(-11.80, -76.80));
  const config = HomeScreenConfig(
    serviceArea: limaArea,
    serviceAreaName: 'Lima',
  );
  const laPaz = LatLng(-16.4897, -68.1193);

  Future<RoutePlannerCubit> newCubit() async {
    final cubit = RoutePlannerCubit(
      repository: MemoryHomeRepository(),
      requestService: ScriptedPlanService(),
    );
    addTearDown(cubit.close);
    await cubit.initialize();
    return cubit;
  }

  bool movedTo(MapMoves moves, LatLng point) =>
      moves.moves.any((m) => m.target == point);

  testWidgets('first press, tracking off: no move to La Paz, SnackBar shows', (
    tester,
  ) async {
    // The defaults answer "location service off": nothing auto-starts.
    final moves = await pumpHome(tester, await newCubit(), config: config);
    expect(find.byIcon(Icons.my_location_outlined), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    mockGeolocatorWithFix(laPaz);
    await tester.tap(find.byIcon(Icons.my_location_outlined));
    await tester.pumpAndSettle();

    expect(movedTo(moves, laPaz), isFalse);
    expect(find.text('You are outside Lima'), findsOneWidget);
  });

  testWidgets('startup outside the area: SnackBar, camera stays', (
    tester,
  ) async {
    mockGeolocatorWithFix(laPaz);
    final moves = await pumpHome(tester, await newCubit(), config: config);

    expect(find.text('You are outside Lima'), findsOneWidget);
    expect(movedTo(moves, laPaz), isFalse);
    expect(moves.moves, isEmpty, reason: 'no camera move at startup');
  });

  testWidgets('startup inside the area: no SnackBar', (tester) async {
    mockGeolocatorWithFix(const LatLng(-12.0560, -77.0350));
    await pumpHome(tester, await newCubit(), config: config);

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('"See Lima" goes through the tracked move, not a raw fit', (
    tester,
  ) async {
    mockGeolocatorWithFix(laPaz);
    final moves = await pumpHome(tester, await newCubit(), config: config);

    await tester.tap(find.byType(SnackBarAction));
    await tester.pumpAndSettle();

    expect(
      moves.fits,
      isEmpty,
      reason: 'a raw fitBounds leaves the camera stale',
    );
    expect(moves.moves, hasLength(1));
    final target = moves.moves.single.target;
    expect(target.latitude, inInclusiveRange(-12.35, -11.80));
    expect(target.longitude, inInclusiveRange(-77.20, -76.80));
  });

  // The 1080x2424 harness at 2.625 is a 411x923 logical map; with 40 px of
  // padding Lima's 0.4 deg of longitude is the limiting side: zoom 10.19.
  for (final startZoom in [4.0, 16.0]) {
    testWidgets('"See Lima" from zoom ${startZoom.toInt()} fits the bounds', (
      tester,
    ) async {
      mockGeolocatorWithFix(laPaz);
      final moves = await pumpHome(
        tester,
        await newCubit(),
        config: config,
        defaultZoom: startZoom,
      );

      await tester.tap(find.byType(SnackBarAction));
      await tester.pumpAndSettle();

      final camera = moves.moves.single;
      expect(camera.zoom, inInclusiveRange(10.1, 10.3));
      expect(camera.target.latitude, closeTo(-12.075, 0.01));
      expect(camera.target.longitude, closeTo(-77.0, 0.01));
    });
  }
}
