import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// The grouped card (#737): a slot served by interchangeable routes joins
/// them Google Maps style ("106 / 120") and the footer badge switches from
/// "+N more" (departures) to "+N options".
void main() {
  routing.Leg bus(String route) => routing.Leg(
    mode: 'BUS',
    startTime: DateTime(2026, 8, 12, 8),
    endTime: DateTime(2026, 8, 12, 8, 30),
    duration: const Duration(minutes: 30),
    distance: 5000,
    transitLeg: true,
    route: routing.Route(gtfsId: '1:$route', shortName: route),
    shortName: route,
  );

  final itinerary = routing.Itinerary(
    legs: [bus('123'), bus('106')],
    startTime: DateTime(2026, 8, 12, 8),
    endTime: DateTime(2026, 8, 12, 9),
    walkTime: const Duration(minutes: 5),
    duration: const Duration(hours: 1),
    walkDistance: 400,
  );

  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  ItineraryCard card({
    List<List<routing.Route>>? slotRoutes,
    bool hasRouteAlternatives = false,
    int? alternativeCount,
  }) => ItineraryCard(
    itinerary: itinerary,
    isSelected: false,
    onTap: () {},
    alternativeCount: alternativeCount,
    slotRoutes: slotRoutes,
    hasRouteAlternatives: hasRouteAlternatives,
  );

  testWidgets('multi-route slot renders joined names "106 / 120"', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        card(
          slotRoutes: [
            [routing.Route(shortName: '123')],
            [routing.Route(shortName: '106'), routing.Route(shortName: '120')],
          ],
          hasRouteAlternatives: true,
          alternativeCount: 2,
        ),
      ),
    );

    expect(find.text('123'), findsOneWidget);
    expect(find.text('106 / 120'), findsOneWidget);
    expect(find.text('+2 options'), findsOneWidget,
        reason: 'route alternatives use the options badge, not departures');
  });

  testWidgets('same-route group keeps plain names and departures badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        card(
          slotRoutes: [
            [routing.Route(shortName: '123')],
            [routing.Route(shortName: '106')],
          ],
          alternativeCount: 2,
        ),
      ),
    );

    expect(find.text('123'), findsOneWidget);
    expect(find.text('106'), findsOneWidget);
    expect(find.text('+2 more'), findsOneWidget);
  });

  testWidgets('more than 3 options collapse into "+N"', (tester) async {
    await tester.pumpWidget(
      host(
        card(
          slotRoutes: [
            [routing.Route(shortName: '123')],
            [
              routing.Route(shortName: '106'),
              routing.Route(shortName: '120'),
              routing.Route(shortName: '250'),
              routing.Route(shortName: 'Z12'),
            ],
          ],
          hasRouteAlternatives: true,
        ),
      ),
    );

    expect(find.text('106 / 120 / 250 +1'), findsOneWidget);
  });

  testWidgets('without a group the card renders exactly as before', (
    tester,
  ) async {
    await tester.pumpWidget(host(card()));

    expect(find.text('123'), findsOneWidget);
    expect(find.text('106'), findsOneWidget);
  });
}
