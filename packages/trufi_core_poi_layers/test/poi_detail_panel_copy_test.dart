import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';

/// trufi-sanaa#9 on the POI card: a copy button next to the close button
/// plus long-press on the name and on every info row. The other buttons
/// keep working.
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

const category = POICategoryConfig(
  name: 'healthcare',
  displayName: 'Healthcare',
  count: 1,
  color: Colors.teal,
  weight: 0,
);

POI poi({String name = 'Farmacia Bolivia'}) => POI(
  id: 'node/1',
  position: const LatLng(-17.39, -66.15),
  name: name,
  category: category,
  subcategory: 'pharmacy',
  properties: const {
    'addr:street': 'Avenida Heroínas',
    'addr:housenumber': '123',
    'phone': '+591 4 4250000',
  },
);

void main() {
  final events = <String>[];

  Widget host(POI poi, {TextDirection? textDirection}) => MaterialApp(
    localizationsDelegates: POILayersLocalizations.localizationsDelegates,
    supportedLocales: POILayersLocalizations.supportedLocales,
    builder: textDirection == null
        ? null
        : (context, child) =>
              Directionality(textDirection: textDirection, child: child!),
    home: Scaffold(
      body: POIDetailPanel(
        poi: poi,
        onClose: () => events.add('close'),
        onSetAsOrigin: () => events.add('origin'),
        onSetAsDestination: () => events.add('destination'),
      ),
    ),
  );

  setUp(events.clear);

  testWidgets('the copy button copies the name and confirms', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(host(poi()));

    // Tooltip comes from Flutter's own MaterialLocalizations.
    expect(find.byTooltip('Copy'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    expect(copied, ['Farmacia Bolivia']);
    expect(find.text('Copied'), findsOneWidget);
    expect(events, isEmpty);
  });

  testWidgets('long-press copies the name, the address and the phone', (
    tester,
  ) async {
    final copied = mockClipboard();
    final p = poi();
    await tester.pumpWidget(host(p));

    await tester.longPress(find.text('Farmacia Bolivia'));
    await tester.pump();
    await tester.longPress(find.text(p.address!));
    await tester.pump();
    await tester.longPress(find.text('+591 4 4250000'));
    await tester.pump();

    expect(copied, ['Farmacia Bolivia', p.address, '+591 4 4250000']);
  });

  testWidgets('close and the route buttons still work (both ways)', (
    tester,
  ) async {
    final copied = mockClipboard();
    await tester.pumpWidget(host(poi()));

    await tester.tap(find.byIcon(Icons.close));
    await tester.tap(find.text('From here'));
    await tester.tap(find.text('Go here'));
    await tester.pump();

    expect(events, ['close', 'origin', 'destination']);
    expect(copied, isEmpty);
  });

  testWidgets('RTL: an Arabic name is copied whole, by button and by '
      'long-press', (tester) async {
    final copied = mockClipboard();
    // Al-Saleh Mosque, Sana'a.
    await tester.pumpWidget(
      host(poi(name: 'جامع الصالح'), textDirection: TextDirection.rtl),
    );

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    await tester.longPress(find.text('جامع الصالح'));
    await tester.pump();

    expect(copied, ['جامع الصالح', 'جامع الصالح']);
  });

  test('the copy tooltip ships in Arabic without a key of our own', () async {
    final ar = await GlobalMaterialLocalizations.delegate.load(
      const Locale('ar'),
    );
    expect(ar.copyButtonLabel, 'نسخ');
  });
}
