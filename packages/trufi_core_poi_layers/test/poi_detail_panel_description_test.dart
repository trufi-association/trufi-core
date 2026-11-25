import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';

/// trufi-lima#6: a bus stop's POI card showed only its name; the routes
/// that serve it ("Rutas: 1132, 1481") sit in the feature's `description`
/// property and were never shown. The narrow detail panel must render it.
const category = POICategoryConfig(
  name: 'transport',
  displayName: 'Transport',
  count: 1,
  color: Colors.teal,
  weight: 0,
);

POI poi(Map<String, dynamic> properties) => POI(
  id: 'node/1',
  position: const LatLng(-12.05, -77.04),
  name: 'Paradero Arequipa',
  category: category,
  subcategory: 'bus_stop',
  properties: properties,
);

Widget host(POI poi) => MaterialApp(
  localizationsDelegates: POILayersLocalizations.localizationsDelegates,
  supportedLocales: POILayersLocalizations.supportedLocales,
  home: Scaffold(
    body: POIDetailPanel(
      poi: poi,
      onClose: () {},
      onSetAsOrigin: () {},
      onSetAsDestination: () {},
    ),
  ),
);

Set<String> texts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
    .toSet();

void main() {
  testWidgets('the description is shown, and only it is added', (tester) async {
    await tester.pumpWidget(host(poi({'phone': '+51 1 5550000'})));
    final without = texts(tester);

    await tester.pumpWidget(
      host(poi({'phone': '+51 1 5550000', 'description': 'Rutas: 1132, 1481'})),
    );

    expect(find.text('Rutas: 1132, 1481'), findsOneWidget);
    expect(texts(tester).difference(without), {'Rutas: 1132, 1481'});
  });

  testWidgets('no description: no routes row (already true today)', (
    tester,
  ) async {
    await tester.pumpWidget(host(poi({'phone': '+51 1 5550000'})));

    expect(find.textContaining('Rutas'), findsNothing);
  });

  testWidgets('an empty description renders nothing (already true today)', (
    tester,
  ) async {
    await tester.pumpWidget(host(poi({'phone': '+51 1 5550000'})));
    final without = texts(tester);

    await tester.pumpWidget(
      host(poi({'phone': '+51 1 5550000', 'description': ''})),
    );
    expect(texts(tester), without);
    expect(find.text(''), findsNothing);
  });
}
