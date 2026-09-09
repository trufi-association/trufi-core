import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

/// trufi-sanaa#9 on the saved-places tile: long-press copies the label the
/// tile shows; tap still selects the place.
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

SavedPlace _place(String name, SavedPlaceType type) => SavedPlace(
  id: type.name,
  name: name,
  latitude: -17.39,
  longitude: -66.16,
  type: type,
  createdAt: DateTime.utc(2026, 9, 9),
);

Widget _app(Widget child, {String locale = 'es', TextDirection? direction}) =>
    MaterialApp(
      locale: Locale(locale),
      supportedLocales: SavedPlacesLocalizations.supportedLocales,
      localizationsDelegates: const [
        SavedPlacesLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      builder: direction == null
          ? null
          : (context, child) =>
                Directionality(textDirection: direction, child: child!),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('long-press copies the shown name and confirms in the UI '
      'language; tap still selects', (tester) async {
    final copied = mockClipboard();
    var taps = 0;
    await tester.pumpWidget(
      _app(
        SavedPlaceTile(
          place: _place('Casa Cambio', SavedPlaceType.home),
          onTap: () => taps++,
        ),
      ),
    );

    await tester.longPress(find.text('Casa Cambio'));
    await tester.pump();
    expect(copied, ['Casa Cambio']);
    expect(find.text('Copiado'), findsOneWidget);
    expect(taps, 0, reason: 'a long-press is not a tap');

    await tester.tap(find.text('Casa Cambio'));
    await tester.pump();
    expect(taps, 1);
    expect(copied, ['Casa Cambio'], reason: 'a tap copies nothing');
  });

  testWidgets('a Home still carrying the default label copies the localized '
      'label it shows', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(
      _app(SavedPlaceTile(place: _place('Home', SavedPlaceType.home))),
    );

    await tester.longPress(find.text('Casa'));
    await tester.pump();

    expect(copied, ['Casa']);
  });

  testWidgets('RTL: an Arabic favourite is copied whole', (tester) async {
    final copied = mockClipboard();
    // Al-Sabeen Park, Sana'a.
    await tester.pumpWidget(
      _app(
        SavedPlaceTile(place: _place('حديقة السبعين', SavedPlaceType.other)),
        direction: TextDirection.rtl,
      ),
    );

    await tester.longPress(find.text('حديقة السبعين'));
    await tester.pump();

    expect(copied, ['حديقة السبعين']);
    expect(find.text('Copiado'), findsOneWidget);
  });
}
