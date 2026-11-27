import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'support/navigation_fixtures.dart';
import 'support/navigation_screen_harness.dart';

/// trufi-lima#12 (reopened): with the phone outside Lima, "Go" centred the
/// navigation on the GPS (a cream map) and showed "1,079.2 km" to the stop.
/// With a `serviceArea` in the [NavigationConfig], while the rider is outside
/// it: the map shows the first leg of the trip instead of following the GPS,
/// a notice says "You are outside {name}", and the distance figure of the
/// instruction card (with the ETA that depends on it) is hidden. Once a fix
/// inside the area arrives, the navigation is the normal one.
///
/// Driven through `NavigationScreen.showFromItinerary`, over a map engine
/// that records what it is told to look at.
void main() {
  final realWakelock = wakelockPlusPlatformInstance;
  setUp(() => wakelockPlusPlatformInstance = NoWakelock());
  tearDown(() => wakelockPlusPlatformInstance = realWakelock);

  const named = NavigationConfig(
    serviceArea: sanaaArea,
    serviceAreaName: "Sana'a",
  );

  /// The map is not on [rider], and shows the first leg (within a km of the
  /// trip's origin: a fit on the leg or its first point).
  void expectFirstLegNotRider(RecordingMapManager maps, LatLng rider) {
    final calls = maps.engine.calls;
    expect(calls, isNotEmpty);
    for (final call in calls) {
      expect(
        call.camera,
        isNull,
        reason: 'navigation gives the map no controlled camera: it only '
            'starts somewhere',
      );
    }
    final target = calls.last.target;
    expect(target, isNot(rider), reason: 'the map must not start on the GPS');
    expect(
      meters(target, SanaaTrip.origin),
      lessThan(1000),
      reason: 'the map shows the first leg of the trip',
    );
  }

  group('rider outside the service area', () {
    testWidgets('at the start: map on the first leg, notice, no distance and '
        'no ETA', (tester) async {
      final run = await startSanaaNavigation(
        tester,
        rider: farAway,
        config: named,
      );

      expectFirstLegNotRider(run.maps, farAway);
      expect(find.text("You are outside Sana'a"), findsOneWidget);
      expect(distanceFigure, findsNothing);
      expect(find.textContaining('km'), findsNothing);
      expect(etaFigure, findsNothing, reason: 'the ETA derives from it');
    });

    testWidgets('a fix outside arrives while navigating: same', (tester) async {
      final run = await startSanaaNavigation(
        tester,
        rider: SanaaTrip.origin,
        config: named,
      );
      expect(find.textContaining('outside'), findsNothing);
      expect(distanceFigure, findsOneWidget);

      run.location.moveTo(farAway);
      await tester.pumpAndSettle();

      expect(find.text("You are outside Sana'a"), findsOneWidget);
      expect(distanceFigure, findsNothing);
      expect(etaFigure, findsNothing);
      for (final call in run.maps.engine.calls) {
        expect(call.camera, isNull);
        expect(call.initialCamera.target, isNot(farAway));
      }
    });

    testWidgets('unnamed area: the unnamed notice, without "null"', (
      tester,
    ) async {
      await startSanaaNavigation(
        tester,
        rider: farAway,
        config: const NavigationConfig(serviceArea: sanaaArea),
      );

      expect(find.text('You are outside the service area'), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
      expect(distanceFigure, findsNothing);
    });

    testWidgets('Spanish: "Estás fuera de Sana\'a"', (tester) async {
      await startSanaaNavigation(
        tester,
        rider: farAway,
        config: named,
        locale: const Locale('es'),
      );
      expect(find.text("Estás fuera de Sana'a"), findsOneWidget);
    });

    testWidgets('German: "Sie sind außerhalb von Sana\'a"', (tester) async {
      await startSanaaNavigation(
        tester,
        rider: farAway,
        config: named,
        locale: const Locale('de'),
      );
      expect(find.text("Sie sind außerhalb von Sana'a"), findsOneWidget);
    });
  });

  group('rider inside the service area: navigation as today', () {
    testWidgets('at the start: distance and ETA, no notice, the map on the '
        'rider', (tester) async {
      final run = await startSanaaNavigation(
        tester,
        rider: SanaaTrip.origin,
        config: named,
      );

      expect(find.textContaining('outside'), findsNothing);
      expect(distanceFigure, findsOneWidget);
      expect(etaFigure, findsOneWidget);
      expect(run.maps.engine.calls.last.target, SanaaTrip.origin);
    });

    testWidgets('a fix on the edge of the area counts as inside', (
      tester,
    ) async {
      await startSanaaNavigation(
        tester,
        rider: sanaaArea.southWest,
        config: named,
      );

      expect(find.textContaining('outside'), findsNothing);
      expect(distanceFigure, findsOneWidget);
    });

    testWidgets('outside, then a fix inside: notice gone, distance and ETA '
        'back, the camera is the normal one', (tester) async {
      final run = await startSanaaNavigation(
        tester,
        rider: farAway,
        config: named,
      );
      expect(distanceFigure, findsNothing);

      run.location.moveTo(SanaaTrip.origin);
      await tester.pumpAndSettle();

      expect(find.textContaining('outside'), findsNothing);
      expect(distanceFigure, findsOneWidget);
      expect(etaFigure, findsOneWidget);
      final last = run.maps.engine.calls.last;
      expect(
        last.camera,
        isNull,
        reason: 'no pinned first-leg camera once the rider is inside',
      );
    });
  });
}
