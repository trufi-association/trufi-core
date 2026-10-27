import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart';

// The line badge every screen draws (routes list, route detail, itinerary
// legs, nearby lines, saved routes): mode icon + short name on the route
// colour, readable text whatever the feed sends, bus when the mode is
// unknown.

void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  Container decorated(WidgetTester tester) => tester.widget<Container>(
    find.descendant(
      of: find.byType(RouteBadge),
      matching: find.byType(Container),
    ),
  );

  group('RouteBadge variants', () {
    for (final variant in RouteBadgeVariant.values) {
      testWidgets('$variant shows the icon and the name on the colour', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            RouteBadge(
              label: '204',
              color: const Color(0xFF7E57C2),
              icon: const Icon(Icons.tram_rounded),
              variant: variant,
            ),
          ),
        );

        expect(find.text('204'), findsOneWidget);
        expect(find.byIcon(Icons.tram_rounded), findsOneWidget);
        expect(find.byIcon(Icons.directions_bus_rounded), findsNothing);
        final decoration = decorated(tester).decoration! as BoxDecoration;
        expect(decoration.color, const Color(0xFF7E57C2));
        expect(
          decoration.border,
          variant == RouteBadgeVariant.mapLabel ? isNotNull : isNull,
          reason: 'only the map label wears the white outline',
        );
      });
    }

    testWidgets('the tile stacks icon over name, the others sit in a row', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RouteBadge(label: 'A', color: Colors.blue),
              RouteBadge(
                label: 'B',
                color: Colors.blue,
                variant: RouteBadgeVariant.chip,
              ),
            ],
          ),
        ),
      );

      final tileIcon = tester.getCenter(
        find.byIcon(Icons.directions_bus_rounded).first,
      );
      final tileText = tester.getCenter(find.text('A'));
      expect(tileIcon.dy, lessThan(tileText.dy));
      expect(tileIcon.dx, moreOrLessEquals(tileText.dx, epsilon: 1));

      final chipIcon = tester.getCenter(
        find.byIcon(Icons.directions_bus_rounded).last,
      );
      final chipText = tester.getCenter(find.text('B'));
      expect(chipIcon.dx, lessThan(chipText.dx));
      expect(chipIcon.dy, moreOrLessEquals(chipText.dy, epsilon: 1));
    });
  });

  group('RouteBadge fallbacks', () {
    testWidgets('no icon → the bus', (tester) async {
      await tester.pumpWidget(
        host(const RouteBadge(label: 'J', color: Colors.purple)),
      );

      expect(find.byIcon(Icons.directions_bus_rounded), findsOneWidget);
    });

    testWidgets('an empty label leaves the icon alone', (tester) async {
      await tester.pumpWidget(
        host(
          const RouteBadge(
            label: '',
            color: Colors.purple,
            variant: RouteBadgeVariant.chip,
          ),
        ),
      );

      expect(find.byIcon(Icons.directions_bus_rounded), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('the text colour follows the contrast rule unless the feed '
        'sets one', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              RouteBadge(label: 'dark', color: Color(0xFF7E57C2)),
              RouteBadge(label: 'light', color: Color(0xFFFFEB3B)),
              RouteBadge(
                label: 'feed',
                color: Color(0xFF7E57C2),
                textColor: Color(0xFFFF9800),
              ),
            ],
          ),
        ),
      );

      Color colorOf(String label) =>
          tester.widget<Text>(find.text(label)).style!.color!;
      expect(colorOf('dark'), Colors.white);
      expect(colorOf('light'), Colors.black87);
      expect(colorOf('feed'), const Color(0xFFFF9800));

      final feedIcon = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.directions_bus_rounded).last,
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(feedIcon.data.color, const Color(0xFFFF9800));
    });
  });

  group('routeBadgeForeground', () {
    test('white while it clears 3:1, near-black above luminance 0.30', () {
      expect(routeBadgeForeground(const Color(0xFF7E57C2)), Colors.white);
      // Luminance ≈ 0.22: white still reads (3.9:1).
      expect(routeBadgeForeground(const Color(0xFF808080)), Colors.white);
      // Luminance ≈ 0.35: white would be 2.7:1, so near-black takes over —
      // the band 0.30–0.5 the old `luminance > 0.5` rule painted white.
      expect(routeBadgeForeground(const Color(0xFF9E9E9E)), Colors.black87);
      expect(routeBadgeForeground(const Color(0xFFFFEB3B)), Colors.black87);
      expect(routeBadgeForeground(Colors.white), Colors.black87);
    });
  });

  group('parseGtfsColor', () {
    test('accepts six hex digits with or without the leading #', () {
      expect(parseGtfsColor('1A2B3C'), const Color(0xFF1A2B3C));
      expect(parseGtfsColor('#1A2B3C'), const Color(0xFF1A2B3C));
      expect(parseGtfsColor('7E57C2'), const Color(0xFF7E57C2));
      expect(parseGtfsColor('#7e57c2'), const Color(0xFF7E57C2));
    });

    test('null, empty and malformed values give null', () {
      expect(parseGtfsColor(null), isNull);
      expect(parseGtfsColor(''), isNull);
      expect(parseGtfsColor('#'), isNull);
      expect(parseGtfsColor('FF'), isNull);
      expect(parseGtfsColor('FFF'), isNull);
      expect(parseGtfsColor('zz'), isNull);
      expect(parseGtfsColor('zzzzzz'), isNull);
      expect(parseGtfsColor('1A2B3C4D'), isNull);
    });
  });

  group('transportModeBadgeIcon', () {
    test('buses of every local flavour share the bus glyph', () {
      for (final mode in [
        TransportMode.bus,
        TransportMode.trufi,
        TransportMode.micro,
        TransportMode.miniBus,
      ]) {
        expect(transportModeBadgeIcon(mode), Icons.directions_bus_rounded);
      }
    });

    test('rail, subway, tram, ferry and cable modes keep their glyphs; '
        'anything else is generic transit', () {
      expect(transportModeBadgeIcon(TransportMode.rail), Icons.train_rounded);
      expect(
        transportModeBadgeIcon(TransportMode.lightRail),
        Icons.train_rounded,
      );
      expect(
        transportModeBadgeIcon(TransportMode.subway),
        Icons.subway_rounded,
      );
      expect(transportModeBadgeIcon(TransportMode.tram), Icons.tram_rounded);
      expect(
        transportModeBadgeIcon(TransportMode.ferry),
        Icons.directions_ferry_rounded,
      );
      expect(
        transportModeBadgeIcon(TransportMode.gondola),
        Icons.airline_seat_legroom_reduced_rounded,
      );
      expect(
        transportModeBadgeIcon(TransportMode.walk),
        Icons.directions_transit_rounded,
      );
      expect(
        transportModeBadgeIcon(TransportMode.error),
        Icons.directions_transit_rounded,
      );
    });
  });
}
