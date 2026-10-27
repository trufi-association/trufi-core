import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

// The saved route card draws its transit legs with the ecosystem's
// RouteBadge: GTFS colours when the snapshot has them, the theme's primary
// otherwise, the mode glyph when the mode was saved and a bus for routes
// saved before the mode existed. Origin and destination read as the route
// detail's terminals, the itinerary numbers as info chips.

const _twoLegs = SavedRouteSnapshot(
  transitLegs: [
    SavedRouteTransitLeg(
      shortName: '204',
      colorHex: '7E57C2',
      textColorHex: 'FFEB3B',
      mode: 'RAIL',
    ),
    SavedRouteTransitLeg(shortName: 'J', colorHex: 'zz'),
  ],
  distanceMeters: 5000,
  durationSeconds: 1800,
);

SavedRoute _route({
  SavedRouteSnapshot? snapshot = _twoLegs,
  String name = 'Al hospital',
  String origin = 'Plaza 14 de Septiembre',
  String destination = 'Hospital Viedma',
}) => SavedRoute(
  id: 'r1',
  name: name,
  origin: SavedRoutePoint(name: origin, latitude: -17.39, longitude: -66.16),
  destination: SavedRoutePoint(
    name: destination,
    latitude: -17.37,
    longitude: -66.15,
  ),
  createdAt: DateTime(2026, 10, 26),
  snapshot: snapshot,
);

Widget _host(Widget child, {double width = 360}) => MaterialApp(
  localizationsDelegates: SavedPlacesLocalizations.localizationsDelegates,
  supportedLocales: SavedPlacesLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
  testWidgets('one RouteBadge per transit leg, in the GTFS colours and with '
      'the mode glyph; bus and primary when the snapshot lacks them', (
    tester,
  ) async {
    await tester.pumpWidget(_host(SavedRouteCard(route: _route())));

    final badges = tester
        .widgetList<RouteBadge>(find.byType(RouteBadge))
        .toList();
    expect(badges, hasLength(2));
    expect(badges.first.label, '204');
    expect(badges.first.color, const Color(0xFF7E57C2));
    expect(badges.first.textColor, const Color(0xFFFFEB3B));
    expect(badges.first.variant, RouteBadgeVariant.chip);
    expect(find.byIcon(Icons.train_rounded), findsOneWidget);

    final primary = Theme.of(
      tester.element(find.byType(SavedRouteCard)),
    ).colorScheme.primary;
    expect(badges.last.label, 'J');
    expect(badges.last.color, primary, reason: 'malformed hex → theme');
    expect(badges.last.textColor, isNull);
    expect(
      find.byIcon(Icons.directions_bus_rounded),
      findsOneWidget,
      reason: 'a leg saved without a mode shows the bus',
    );
    expect(find.byIcon(Icons.directions_transit_rounded), findsNothing);
  });

  testWidgets('origin sits above destination without prefixes; screen '
      'readers still hear which is which', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_host(SavedRouteCard(route: _route())));

    expect(find.text('Plaza 14 de Septiembre'), findsOneWidget);
    expect(find.text('Hospital Viedma'), findsOneWidget);
    expect(find.text('Origin: Plaza 14 de Septiembre'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Plaza 14 de Septiembre')).dy,
      lessThan(tester.getTopLeft(find.text('Hospital Viedma')).dy),
    );
    // The card is one tappable node, so its descendants' labels merge into
    // it: the terminals contribute the prefixed form only.
    final label = tester.getSemantics(find.text('Al hospital')).label;
    expect(label, contains('Origin: Plaza 14 de Septiembre'));
    expect(label, contains('Destination: Hospital Viedma'));
    expect('\n$label\n', isNot(contains('\nPlaza 14 de Septiembre\n')));
    semantics.dispose();
  });

  testWidgets('distance and duration are info chips', (tester) async {
    await tester.pumpWidget(_host(SavedRouteCard(route: _route())));

    expect(find.text('5.0 km'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.byIcon(Icons.straighten_rounded), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    expect(find.textContaining('~'), findsNothing);

    await tester.pumpWidget(
      _host(
        SavedRouteCard(
          route: _route(
            snapshot: const SavedRouteSnapshot(
              transitLegs: [],
              distanceMeters: 800,
              durationSeconds: 5400,
            ),
          ),
        ),
      ),
    );
    expect(find.text('800 m'), findsOneWidget);
    expect(find.text('1h 30min'), findsOneWidget);
    expect(
      find.byIcon(Icons.directions_walk_rounded),
      findsOneWidget,
      reason: 'a walk-only itinerary shows the walk badge',
    );
    expect(find.byType(RouteBadge), findsNothing);
  });

  testWidgets('without a snapshot the card ends at the destination', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(SavedRouteCard(route: _route(snapshot: null))),
    );

    expect(find.text('Hospital Viedma'), findsOneWidget);
    expect(find.byType(RouteBadge), findsNothing);
    expect(find.byIcon(Icons.straighten_rounded), findsNothing);
    expect(find.byIcon(Icons.schedule_rounded), findsNothing);
  });

  testWidgets('long names and three legs fit a 320 dp card', (tester) async {
    await tester.pumpWidget(
      _host(
        width: 320,
        SavedRouteCard(
          route: _route(
            name: 'Asociación Mixta de Transporte Huayñacota',
            origin: 'Plaza 14 de Septiembre, Cochabamba, Bolivia',
            destination: 'Hospital Viedma, Av. Aniceto Arce',
            snapshot: const SavedRouteSnapshot(
              transitLegs: [
                SavedRouteTransitLeg(shortName: '204', mode: 'BUS'),
                SavedRouteTransitLeg(shortName: 'J', mode: 'BUS'),
                SavedRouteTransitLeg(shortName: 'Línea 110', mode: 'BUS'),
              ],
              distanceMeters: 12345,
              durationSeconds: 4321,
            ),
          ),
          onRename: () {},
          onSwap: () {},
          onDelete: () {},
        ),
      ),
    );

    // RenderFlex overflows throw in tests: reaching here is the assertion.
    expect(find.byType(RouteBadge), findsNWidgets(3));
    expect(find.text('12.3 km'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });
}
