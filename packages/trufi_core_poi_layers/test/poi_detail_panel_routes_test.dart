import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';

/// trufi-lima#6: a bus stop's POI card showed only its name; the routes
/// that serve it ("Rutas: 1132, 1481") are never shown. The narrow detail
/// panel must render the feature's `routes` property. It is `routes`, not
/// `description`: other cities' POIs carry OSM `description` on hundreds of
/// features, and showing it would change their cards.
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

List<String> mockClipboard() {
  final copied = <String>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') {
      copied.add((call.arguments as Map)['text'] as String);
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return copied;
}

Set<String> texts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
    .toSet();

void main() {
  testWidgets('the routes are shown, and only they are added', (tester) async {
    await tester.pumpWidget(host(poi({'phone': '+51 1 5550000'})));
    final without = texts(tester);

    await tester.pumpWidget(
      host(poi({'phone': '+51 1 5550000', 'routes': 'Rutas: 1132, 1481'})),
    );
    expect(find.text('Rutas: 1132, 1481'), findsOneWidget);
    expect(texts(tester).difference(without), {'Rutas: 1132, 1481'});
  });

  testWidgets('no routes: no routes row (already true today)', (tester) async {
    await tester.pumpWidget(host(poi({'phone': '+51 1 5550000'})));

    expect(find.textContaining('Rutas'), findsNothing);
  });

  testWidgets('empty routes render nothing (already true today)', (
    tester,
  ) async {
    await tester.pumpWidget(host(poi({'phone': '+51 1 5550000'})));
    final without = texts(tester);

    await tester.pumpWidget(
      host(poi({'phone': '+51 1 5550000', 'routes': ''})),
    );
    expect(texts(tester), without);
    expect(find.text(''), findsNothing);
  });

  testWidgets(
    'a description without routes is not shown (already true today)',
    (tester) async {
      await tester.pumpWidget(host(poi({'phone': '+51 1 5550000'})));
      final without = texts(tester);

      await tester.pumpWidget(
        host(
          poi({
            'phone': '+51 1 5550000',
            'description': 'Farmacia de turno 24 h',
          }),
        ),
      );
      expect(find.text('Farmacia de turno 24 h'), findsNothing);
      expect(texts(tester), without);
    },
  );

  testWidgets('long-press on the routes row copies the routes '
      '(via _InfoRow, as the other rows)', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(
      host(poi({'phone': '+51 1 5550000', 'routes': 'Rutas: 1132, 1481'})),
    );

    await tester.longPress(find.text('Rutas: 1132, 1481'));
    await tester.pump();

    expect(copied, ['Rutas: 1132, 1481']);
  });
}
