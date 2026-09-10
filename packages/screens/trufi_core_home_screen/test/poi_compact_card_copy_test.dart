import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';

/// trufi-sanaa#9 on the wide layout (>= 600 dp): the compact POI card at the
/// bottom of the side panel gets the same copy button and long-press as the
/// narrow panel (`POIDetailPanel`, tested in trufi_core_poi_layers).
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
  },
);

/// Side panel width the home screen uses for a 600-899 dp screen.
const sidePanelWidth = 340.0;

void main() {
  final events = <String>[];

  /// A landscape phone: 800x600 dp is the wide layout, and the card sits at
  /// the bottom of the side panel exactly as `home_screen.dart` places it.
  Widget host(POI poi, {TextDirection? textDirection}) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    builder: textDirection == null
        ? null
        : (context, child) =>
              Directionality(textDirection: textDirection, child: child!),
    home: Scaffold(
      body: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: SizedBox(
          width: sidePanelWidth,
          child: POICompactCard(
            poi: poi,
            onClose: () => events.add('close'),
            onSetAsOrigin: () => events.add('origin'),
            onSetAsDestination: () => events.add('destination'),
          ),
        ),
      ),
    ),
  );

  setUp(events.clear);

  Future<void> pumpWide(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
  }

  testWidgets('the copy button sits next to the close button and copies the '
      'name', (tester) async {
    final copied = mockClipboard();
    await pumpWide(tester, host(poi()));

    final card = tester.element(find.byType(POICompactCard));
    expect(MediaQuery.sizeOf(card).width, greaterThanOrEqualTo(600));

    // Tooltip comes from Flutter's own MaterialLocalizations.
    expect(find.byTooltip('Copy'), findsOneWidget);
    final buttons = find.byType(IconButton);
    expect(buttons, findsNWidgets(2));
    expect(tester.getSize(buttons.at(0)), tester.getSize(buttons.at(1)));
    expect(
      tester.getCenter(buttons.at(0)).dy,
      tester.getCenter(buttons.at(1)).dy,
    );

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    expect(copied, ['Farmacia Bolivia']);
    expect(find.text('Copied'), findsOneWidget);
    expect(events, isEmpty);
  });

  testWidgets('long-press copies the name and the address', (tester) async {
    final copied = mockClipboard();
    final p = poi();
    await pumpWide(tester, host(p));

    await tester.longPress(find.text('Farmacia Bolivia'));
    await tester.pump();
    await tester.longPress(find.text(p.address!));
    await tester.pump();

    expect(copied, ['Farmacia Bolivia', p.address]);
  });

  testWidgets('close and the route buttons still work (both ways)', (
    tester,
  ) async {
    final copied = mockClipboard();
    await pumpWide(tester, host(poi()));

    await tester.tap(find.byIcon(Icons.close));
    await tester.tap(find.text('Set as Origin'));
    await tester.tap(find.text('Set as Destination'));
    await tester.pump();

    expect(events, ['close', 'origin', 'destination']);
    expect(copied, isEmpty);
  });

  testWidgets('RTL: an Arabic name is copied whole, by button and by '
      'long-press', (tester) async {
    final copied = mockClipboard();
    // Al-Saleh Mosque, Sana'a.
    await pumpWide(
      tester,
      host(poi(name: 'جامع الصالح'), textDirection: TextDirection.rtl),
    );

    final name = find.text('جامع الصالح');
    expect(Directionality.of(tester.element(name)), TextDirection.rtl);
    // The header row mirrors: close at the far left, copy beside it.
    expect(
      tester.getCenter(find.byIcon(Icons.close)).dx,
      lessThan(tester.getCenter(find.byIcon(Icons.copy_rounded)).dx),
    );

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    await tester.longPress(name);
    await tester.pump();

    expect(copied, ['جامع الصالح', 'جامع الصالح']);
  });
}
