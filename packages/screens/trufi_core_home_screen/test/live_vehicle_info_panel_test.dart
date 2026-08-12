import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

void main() {
  final vehicle = VehiclePosition(
    vehicleId: 'ANH-817',
    label: 'ANH-817',
    position: const TrufiLatLng(-12.0491, -77.0914),
    heading: 90,
    speed: 10.0, // GTFS-RT wire unit: m/s
    routeId: '1:1132',
    tripId: '1:1132-ida-WD000038',
    timestamp: DateTime(2026, 8, 11, 12, 0, 0),
  );

  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  group('LiveVehicleInfoPanel', () {
    testWidgets('shows route, plate, speed in km/h and freshness', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          LiveVehicleInfoPanel(
            vehicle: vehicle,
            now: DateTime(2026, 8, 11, 12, 0, 45),
          ),
        ),
      );

      expect(find.text('Route 1132'), findsOneWidget,
          reason: 'feed prefix (1:) must be stripped for riders');
      expect(find.text('ANH-817'), findsOneWidget);
      expect(find.text('36 km/h'), findsOneWidget,
          reason: '10 m/s from the GTFS-RT wire is 36 km/h');
      expect(find.text('Updated 45 s ago'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('a slightly-future timestamp (clock drift) clamps to 0 s', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          LiveVehicleInfoPanel(
            vehicle: vehicle,
            // Panel clock 20 s BEHIND the vehicle's report time.
            now: DateTime(2026, 8, 11, 11, 59, 40),
          ),
        ),
      );
      expect(find.text('Updated 0 s ago'), findsOneWidget,
          reason: 'negative ages must never render ("hace -20 s")');
    });

    testWidgets('minutes-old reports switch to the minutes string', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          LiveVehicleInfoPanel(
            vehicle: vehicle,
            now: DateTime(2026, 8, 11, 12, 5, 0),
          ),
        ),
      );
      expect(find.text('Updated 5 min ago'), findsOneWidget);
    });

    testWidgets('degrades gracefully without optional fields', (tester) async {
      final bare = VehiclePosition(
        vehicleId: 'X1',
        position: const TrufiLatLng(-12.0, -77.0),
      );
      await tester.pumpWidget(host(LiveVehicleInfoPanel(vehicle: bare)));

      expect(find.text('Live bus'), findsOneWidget,
          reason: 'fallback title when the route is unknown');
      expect(find.textContaining('km/h'), findsNothing);
      expect(find.textContaining('Updated'), findsNothing);
    });

    test('displayRoute strips only the feed prefix', () {
      expect(LiveVehicleInfoPanel.displayRoute('1:1132'), '1132');
      expect(LiveVehicleInfoPanel.displayRoute('1132'), '1132');
      expect(LiveVehicleInfoPanel.displayRoute(null), '');
    });
  });

  test('live vehicles layer starts disabled unless the deploy opts in', () {
    expect(const HomeScreenConfig().liveVehiclesInitiallyEnabled, isFalse);
    expect(
      const HomeScreenConfig(liveVehiclesInitiallyEnabled: true)
          .liveVehiclesInitiallyEnabled,
      isTrue,
    );
  });
}
