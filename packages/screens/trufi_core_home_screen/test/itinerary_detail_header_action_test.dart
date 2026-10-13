import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

// #1005: the detail header exposes a slot for one extra action (the home
// screen's save-route bookmark) in its first row, next to the duration chip.
// The detail itself stays unaware of saved routes.

void main() {
  final bus = routing.Leg(
    mode: 'BUS',
    startTime: DateTime(2026, 10, 13, 8),
    endTime: DateTime(2026, 10, 13, 8, 30),
    duration: const Duration(minutes: 30),
    distance: 5000,
    transitLeg: true,
    route: routing.Route(gtfsId: '1:123', shortName: '123'),
    shortName: '123',
  );

  final itinerary = routing.Itinerary(
    legs: [bus],
    startTime: DateTime(2026, 10, 13, 8),
    endTime: DateTime(2026, 10, 13, 8, 30),
    walkTime: Duration.zero,
    duration: const Duration(minutes: 30),
    walkDistance: 0,
  );

  Widget host({Widget? headerAction}) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    home: Scaffold(
      body: ItineraryDetailContent(
        itinerary: itinerary,
        headerAction: headerAction,
      ),
    ),
  );

  testWidgets('renders the slot in the header row, next to the duration chip', (
    tester,
  ) async {
    const key = Key('header-action');
    await tester.pumpWidget(
      host(headerAction: const Icon(Icons.bookmark_add_outlined, key: key)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(key), findsOneWidget);
    final headerRow = find
        .ancestor(of: find.byKey(key), matching: find.byType(Row))
        .first;
    expect(
      find.descendant(of: headerRow, matching: find.text('30 min')),
      findsOneWidget,
      reason: 'same row as the duration chip',
    );
  });

  testWidgets('renders nothing extra without the slot', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_add_outlined), findsNothing);
    expect(find.text('30 min'), findsOneWidget);
  });
}
