import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'support/home_harness.dart';

/// The "You are outside Lima" notice carries an action, which keeps a
/// SnackBar on screen until dismissed: it must time out, and go away once a
/// fix inside the area centres the camera.
void main() {
  installHomeTestDefaults();

  const limaArea = LatLngBounds(LatLng(-12.35, -77.20), LatLng(-11.80, -76.80));
  const config = HomeScreenConfig(
    serviceArea: limaArea,
    serviceAreaName: 'Lima',
  );
  const laPaz = LatLng(-16.4897, -68.1193);
  const insideLima = LatLng(-12.0560, -77.0350);
  const outsideNotice = 'You are outside Lima';

  Map<String, dynamic> positionAt(LatLng fix) => {
    'latitude': fix.latitude,
    'longitude': fix.longitude,
    'timestamp': DateTime(2026, 11, 26, 12).millisecondsSinceEpoch,
    'accuracy': 5.0,
    'altitude': 0.0,
    'altitude_accuracy': 0.0,
    'heading': 0.0,
    'heading_accuracy': 0.0,
    'speed': 0.0,
    'speed_accuracy': 0.0,
    'is_mocked': true,
  };

  /// Starts at [first] and returns a function that reports a new fix.
  void Function(LatLng) mockMovingFix(LatLng first) {
    mockGeolocatorWithFix(first);
    MockStreamHandlerEventSink? sink;
    const updates = EventChannel('flutter.baseflow.com/geolocator_updates');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockStreamHandler(
      updates,
      MockStreamHandler.inline(
        onListen: (args, events) {
          sink = events;
          events.success(positionAt(first));
        },
        onCancel: (args) {},
      ),
    );
    addTearDown(() => messenger.setMockStreamHandler(updates, null));
    return (fix) => sink!.success(positionAt(fix));
  }

  Future<MapMoves> pumpTrackingHome(WidgetTester tester) async {
    final cubit = RoutePlannerCubit(
      repository: MemoryHomeRepository(),
      requestService: ScriptedPlanService(),
    );
    addTearDown(cubit.close);
    await cubit.initialize();
    return pumpHome(tester, cubit, config: config);
  }

  testWidgets('the outside-area notice goes away after its duration', (
    tester,
  ) async {
    mockMovingFix(laPaz);
    await pumpTrackingHome(tester);
    expect(find.text(outsideNotice), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text(outsideNotice), findsNothing);
  });

  testWidgets(
    'a fix inside the area closes the notice and centres the camera',
    (tester) async {
      final reportFix = mockMovingFix(laPaz);
      final moves = await pumpTrackingHome(tester);
      expect(find.text(outsideNotice), findsOneWidget);

      reportFix(insideLima);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.my_location_rounded));
      await tester.pumpAndSettle();

      expect(find.text(outsideNotice), findsNothing);
      expect(moves.moves.any((m) => m.target == insideLima), isTrue);
    },
  );
}
