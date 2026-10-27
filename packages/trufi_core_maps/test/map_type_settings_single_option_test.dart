import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// #1021: with a single map style the sheet is the home of the layer
/// toggles alone — no "Map type" section for a list of one.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required int options,
    Widget? extras,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [MapsLocalizations.delegate],
        supportedLocales: MapsLocalizations.supportedLocales,
        home: MapTypeSettingsScreen(
          currentMapIndex: 0,
          mapOptions: [
            for (var i = 0; i < options; i++)
              MapTypeOption(
                id: 'map$i',
                name: 'Map $i',
                description: 'Style $i',
                isOffline: i.isEven,
              ),
          ],
          onMapTypeChanged: (_) {},
          additionalSettings: extras,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final mapType = lookupMapsLocalizations(const Locale('en')).mapType;

  testWidgets('one style + layer extras: only the extras are listed', (
    tester,
  ) async {
    await pump(tester, options: 1, extras: const Text('layer toggles'));
    expect(find.text('layer toggles'), findsOneWidget);
    expect(find.text(mapType), findsNothing);
    expect(find.text('Map 0'), findsNothing);
  });

  testWidgets('two styles: the map type section is back', (tester) async {
    await pump(tester, options: 2, extras: const Text('layer toggles'));
    expect(find.text(mapType), findsOneWidget);
    expect(find.text('layer toggles'), findsOneWidget);
  });
}
