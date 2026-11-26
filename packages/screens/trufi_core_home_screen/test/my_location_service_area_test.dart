import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'support/home_harness.dart';

/// trufi-lima#12: outside Lima, "my location" flew to La Paz and left a cream
/// map with no word. With a `serviceArea` the camera stays, a SnackBar says
/// "You are outside Lima" and offers "See Lima".
void main() {
  installHomeTestDefaults();

  // The feed's box plus margin (Lima).
  const limaArea = LatLngBounds(LatLng(-12.35, -77.20), LatLng(-11.80, -76.80));
  const config = HomeScreenConfig(
    serviceArea: limaArea,
    serviceAreaName: 'Lima',
  );
  const laPaz = LatLng(-16.4897, -68.1193);
  const insideLima = LatLng(-12.0560, -77.0350);

  Future<MapMoves> pressMyLocation(
    WidgetTester tester,
    LatLng fix, {
    HomeScreenConfig homeConfig = config,
  }) async {
    mockGeolocatorWithFix(fix);
    final cubit = RoutePlannerCubit(
      repository: MemoryHomeRepository(),
      requestService: ScriptedPlanService(),
    );
    addTearDown(cubit.close);
    await cubit.initialize();
    final moves = await pumpHome(tester, cubit, config: homeConfig);
    final button = find.byIcon(Icons.my_location_rounded);
    expect(button, findsOneWidget, reason: 'tracking should be on');
    await tester.tap(button);
    await tester.pumpAndSettle();
    return moves;
  }

  bool movedTo(MapMoves moves, LatLng point) =>
      moves.moves.any((m) => m.target == point);

  testWidgets('outside the area: the camera does not go there and the '
      'SnackBar names the city', (tester) async {
    final moves = await pressMyLocation(tester, laPaz);

    expect(
      movedTo(moves, laPaz),
      isFalse,
      reason: 'the camera must not travel to the fix outside the area',
    );
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('You are outside Lima'), findsOneWidget);
    final action = tester.widget<SnackBarAction>(find.byType(SnackBarAction));
    expect(action.label, contains('Lima'), reason: 'the action names the city');
  });

  testWidgets('"See Lima" takes the camera to the area', (tester) async {
    final moves = await pressMyLocation(tester, laPaz);

    await tester.tap(find.byType(SnackBarAction));
    await tester.pumpAndSettle();

    final fitted = moves.fits.any((b) => b == limaArea);
    final centred = moves.moves.any(
      (m) =>
          m.target.latitude >= -12.35 &&
          m.target.latitude <= -11.80 &&
          m.target.longitude >= -77.20 &&
          m.target.longitude <= -76.80,
    );
    expect(
      fitted || centred,
      isTrue,
      reason: 'fit the bounds or centre inside them',
    );
    expect(movedTo(moves, laPaz), isFalse);
  });

  testWidgets('inside the area: the camera goes to the fix, no SnackBar', (
    tester,
  ) async {
    final moves = await pressMyLocation(tester, insideLima);

    expect(movedTo(moves, insideLima), isTrue);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.textContaining('outside'), findsNothing);
  });

  testWidgets('Spanish texts: "Estás fuera de Lima" / "Ver Lima"', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await pressMyLocation(tester, laPaz);

    expect(find.text('Estás fuera de Lima'), findsOneWidget);
    expect(find.text('Ver Lima'), findsOneWidget);
  });
}
