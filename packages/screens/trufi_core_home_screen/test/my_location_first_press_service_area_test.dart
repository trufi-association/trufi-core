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

  // trufi-lima#12 reopened: fitting the whole service area (zoom ~10 in the
  // harness, ~8.5 on a phone) left the map beige where the offline tiles end.
  // "See Lima" goes back to the startup camera, whatever zoom the map is at.
  const startCenter = LatLng(-12.10, -76.95);
  // Where the user has panned to before tapping "See Lima".
  const pannedTo = TrufiCameraPosition(target: LatLng(-12.30, -77.15), zoom: 10);
  for (final startZoom in [4.0, 16.0]) {
    testWidgets('"See Lima" from zoom ${startZoom.toInt()} goes to the '
        'startup camera (defaultCenter, defaultZoom)', (tester) async {
      mockGeolocatorWithFix(laPaz);
      final moves = await pumpHome(
        tester,
        await newCubit(),
        config: config,
        defaultCenter: startCenter,
        defaultZoom: startZoom,
      );
      moves.onCameraChanged!(pannedTo);
      await tester.pump();

      await tester.tap(find.byType(SnackBarAction));
      await tester.pumpAndSettle();

      expect(moves.fits, isEmpty, reason: 'no fit of the service area');
      final camera = moves.moves.single;
      expect(camera.target.latitude, closeTo(startCenter.latitude, 1e-9));
      expect(camera.target.longitude, closeTo(startCenter.longitude, 1e-9));
      expect(camera.zoom, closeTo(startZoom, 1e-9));
    });
  }
}
