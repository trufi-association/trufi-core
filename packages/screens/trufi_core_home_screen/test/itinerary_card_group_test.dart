import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// The grouped card (#737): a slot served by interchangeable routes paints
/// ONE SEGMENT PER OPTION — the ridden one saturated in its own route
/// color, the rest dimmed into the strip backdrop (same reading as the
/// detail switcher) — no "/" text, no "+n" cap (the summary row scrolls
/// horizontally; the options are explored in the detail view).
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

  ItineraryCard card({List<List<routing.Route>>? slotRoutes}) => ItineraryCard(
    itinerary: itinerary,
    isSelected: false,
    onTap: () {},
    slotRoutes: slotRoutes,
  );

  routing.Route colored(String name, String color) =>
      routing.Route(shortName: name, color: color);

  testWidgets('a multi-route slot paints one segment per option, each in '
      'its own route color', (tester) async {
    await tester.pumpWidget(
      host(
        card(
          slotRoutes: [
            [colored('123', '7E57C2')],
            [colored('106', 'E91E63'), colored('120', '4CAF50')],
          ],
        ),
      ),
    );

    expect(find.text('123'), findsOneWidget);
    expect(find.text('106'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);

    Color bgOf(String name) {
      // Each segment paints its fill on its own Material (the nearest
      // Material ancestor of the segment's label).
      final material = tester.widget<Material>(
        find
            .ancestor(of: find.text(name), matching: find.byType(Material))
            .first,
      );
      return material.color!;
    }

    expect(
      bgOf('106'),
      const Color(0xFFE91E63),
      reason:
          "the CHOSEN option's segment rides its route color, "
          'saturated — the card wears the 106',
    );

    // The muted fill is deterministic: the route color at 82% over the
    // strip backdrop (surfaceContainerHighest at 50% over surface) — an
    // exact oracle, so a wrong blend, backdrop or alpha fails loudly.
    // 82%, not a wash-out: unchosen options KEEP their colors (Sam
    // 2026-08-13); the choice is marked by the ring, not by dimming.
    final theme = Theme.of(tester.element(find.byType(ItineraryCard)));
    final backdrop = Color.alphaBlend(
      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      theme.colorScheme.surface,
    );
    expect(
      bgOf('120'),
      Color.alphaBlend(
        const Color(0xFF4CAF50).withValues(alpha: 0.82),
        backdrop,
      ),
      reason:
          'unchosen segments keep their route color, only slightly '
          'muted — same reading as the detail switcher',
    );

    // The ridden option is the only segment wearing the inset ring — read
    // from the segment's OWN CustomPaint (the nearest ancestor; outer
    // ancestors may paint their own foregrounds).
    CustomPainter? ringOf(String name) => tester
        .widget<CustomPaint>(
          find
              .ancestor(of: find.text(name), matching: find.byType(CustomPaint))
              .first,
        )
        .foregroundPainter;
    expect(
      ringOf('106'),
      isNotNull,
      reason: 'the chosen segment wears the selection ring',
    );
    expect(ringOf('120'), isNull, reason: 'unchosen segments carry no ring');
  });

  testWidgets('all options render — no "+n" collapse; the row scrolls', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        card(
          slotRoutes: [
            [colored('123', '7E57C2')],
            [
              colored('106', 'E91E63'),
              colored('120', '4CAF50'),
              colored('250', 'FF9800'),
              colored('Z12', '7E57C2'),
            ],
          ],
        ),
      ),
    );

    for (final name in ['106', '120', '250', 'Z12']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('without a group the card renders exactly as before', (
    tester,
  ) async {
    await tester.pumpWidget(host(card()));

    expect(find.text('123'), findsOneWidget);
    expect(find.text('106'), findsOneWidget);
  });
}
