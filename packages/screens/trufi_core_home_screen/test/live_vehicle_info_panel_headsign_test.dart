import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// trufi-lima#14: the vehicle card says where the bus goes ("Hacia MINKA"),
/// only when the feed gives a headsign.
void main() {
  VehiclePosition bus({String? headsign}) => VehiclePosition(
    vehicleId: 'ANH-817',
    label: 'ANH-817',
    position: const TrufiLatLng(-12.0491, -77.0914),
    speed: 10.0,
    routeId: '1:1481',
    headsign: headsign,
    timestamp: DateTime(2026, 11, 26, 12),
  );

  Widget host(Widget child, {Locale locale = const Locale('en')}) =>
      MaterialApp(
        locale: locale,
        localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
        supportedLocales: HomeScreenLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  Future<void> pump(
    WidgetTester tester,
    VehiclePosition v, {
    Locale locale = const Locale('en'),
  }) => tester.pumpWidget(
    host(
      LiveVehicleInfoPanel(vehicle: v, now: DateTime(2026, 11, 26, 12, 0, 30)),
      locale: locale,
    ),
  );

  testWidgets('a headsign shows as "Towards X" (en)', (tester) async {
    await pump(tester, bus(headsign: 'MINKA'));
    expect(find.text('Towards MINKA'), findsOneWidget);
  });

  testWidgets('Spanish: "Hacia X"', (tester) async {
    await pump(tester, bus(headsign: 'JICAMARCA'), locale: const Locale('es'));
    expect(find.text('Hacia JICAMARCA'), findsOneWidget);
  });

  testWidgets('German: "Richtung X"', (tester) async {
    await pump(tester, bus(headsign: 'MINKA'), locale: const Locale('de'));
    expect(find.text('Richtung MINKA'), findsOneWidget);
  });

  testWidgets('no headsign: no row, the rest of the card unchanged', (
    tester,
  ) async {
    await pump(tester, bus());
    expect(find.textContaining('Towards'), findsNothing);
    expect(find.text('36 km/h'), findsOneWidget);
    expect(find.text('Updated 30 s ago'), findsOneWidget);
  });

  testWidgets('an empty headsign is no row either', (tester) async {
    await pump(tester, bus(headsign: ''));
    expect(find.textContaining('Towards'), findsNothing);
  });
}
