import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';

/// trufi-lima#6 on the wide layout: the compact POI card at the bottom of
/// the side panel showed only the stop name; the routes that serve it
/// ("Rutas: 1132, 1481", the feature's `description`) were never shown.
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
  localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
  supportedLocales: HomeScreenLocalizations.supportedLocales,
  home: Scaffold(
    body: Align(
      alignment: AlignmentDirectional.bottomStart,
      child: SizedBox(
        width: 340,
        child: POICompactCard(
          poi: poi,
          onClose: () {},
          onSetAsOrigin: () {},
          onSetAsDestination: () {},
        ),
      ),
    ),
  ),
);

Set<String> texts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
    .toSet();

Future<void> pumpWide(WidgetTester tester, Widget widget) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(widget);
}

void main() {
  testWidgets('the description is shown, and only it is added', (tester) async {
    await pumpWide(tester, host(poi({'phone': '+51 1 5550000'})));
    final without = texts(tester);

    await pumpWide(
      tester,
      host(poi({'phone': '+51 1 5550000', 'description': 'Rutas: 1132, 1481'})),
    );

    expect(find.text('Rutas: 1132, 1481'), findsOneWidget);
    expect(texts(tester).difference(without), {'Rutas: 1132, 1481'});
  });

  testWidgets('no description: no routes row (already true today)', (
    tester,
  ) async {
    await pumpWide(tester, host(poi({'phone': '+51 1 5550000'})));

    expect(find.textContaining('Rutas'), findsNothing);
  });

  testWidgets('an empty description renders nothing (already true today)', (
    tester,
  ) async {
    await pumpWide(tester, host(poi({'phone': '+51 1 5550000'})));
    final without = texts(tester);

    await pumpWide(
      tester,
      host(poi({'phone': '+51 1 5550000', 'description': ''})),
    );
    expect(texts(tester), without);
    expect(find.text(''), findsNothing);
  });
}
