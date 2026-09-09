import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// trufi-sanaa#9 — long-press on a place name copies it; tap keeps doing
/// what it always did (select the place). Clipboard writes are captured on
/// the platform channel, the seam Flutter's own clipboard tests use.
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

class _Service with SearchLocationDrillDown implements SearchLocationService {
  static const plaza = SearchLocation(
    id: 'photon:1',
    displayName: 'Plaza Colón',
    address: 'Cochabamba, Bolivia',
    latitude: -17.3882,
    longitude: -66.1557,
  );
  // Al-Saleh Mosque, Sana'a — the reporter's use case.
  static const mosque = SearchLocation(
    id: 'poi:2',
    displayName: 'جامع الصالح',
    address: 'صنعاء',
    latitude: 15.3336,
    longitude: 44.2072,
  );
  static const street = SearchLocation(
    id: 'street:s1',
    displayName: 'Avenida Ayacucho',
    latitude: -17.3925,
    longitude: -66.1588,
  );
  static const corner = SearchLocation(
    id: 'junction:s1:s3',
    displayName: 'Avenida Ayacucho & Avenida Aroma',
    latitude: -17.3907,
    longitude: -66.1571,
  );

  @override
  Future<List<SearchLocation>> search(String query) async => [
    plaza,
    mosque,
    street,
  ];

  @override
  bool canDrillDown(SearchLocation location) => location.id == street.id;

  @override
  Future<List<SearchLocation>> drillDown(SearchLocation location) async => [
    corner,
  ];

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async =>
      null;

  @override
  void dispose() {}
}

const home = SearchLocation(
  id: 'home',
  displayName: 'Casa',
  latitude: -17.39,
  longitude: -66.15,
);

void main() {
  SearchLocation? picked;

  Future<void> pumpScreen(
    WidgetTester tester, {
    TextDirection? textDirection,
  }) async {
    picked = null;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates:
            SearchLocationsLocalizations.localizationsDelegates,
        supportedLocales: SearchLocationsLocalizations.supportedLocales,
        builder: textDirection == null
            ? null
            : (context, child) =>
                  Directionality(textDirection: textDirection, child: child!),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              picked = await Navigator.push<SearchLocation>(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationSearchScreen(
                    isOrigin: true,
                    searchService: _Service(),
                    myPlaces: const [home],
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'a');
    // Debounce (300 ms) + the async search.
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  group('search results', () {
    testWidgets('long-press copies the name only — not "name, address" — '
        'and does not select the place', (tester) async {
      final copied = mockClipboard();
      await pumpScreen(tester);
      await search(tester);

      await tester.longPress(find.text('Plaza Colón'));
      await tester.pump();

      expect(copied, ['Plaza Colón']);
      expect(find.text('Copied'), findsOneWidget);
      expect(picked, isNull, reason: 'a long-press must not pop the screen');
      expect(find.text('Plaza Colón'), findsOneWidget);
    });

    testWidgets('tap still selects the place (both ways)', (tester) async {
      final copied = mockClipboard();
      await pumpScreen(tester);
      await search(tester);

      await tester.tap(find.text('Plaza Colón'));
      await tester.pumpAndSettle();

      expect(picked?.id, 'photon:1');
      expect(copied, isEmpty);
    });

    testWidgets('a corner inside its street list shows the trimmed label but '
        'copies the full name', (tester) async {
      final copied = mockClipboard();
      await pumpScreen(tester);
      await search(tester);
      await tester.tap(find.text('Avenida Ayacucho'));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('& Avenida Aroma'));
      await tester.pump();

      expect(copied, ['Avenida Ayacucho & Avenida Aroma']);
      expect(picked, isNull);
    });

    testWidgets('RTL: an Arabic name is copied whole', (tester) async {
      final copied = mockClipboard();
      await pumpScreen(tester, textDirection: TextDirection.rtl);
      await search(tester);

      final name = find.text('جامع الصالح');
      expect(Directionality.of(tester.element(name)), TextDirection.rtl);

      await tester.longPress(name);
      await tester.pump();

      expect(copied, ['جامع الصالح']);
      expect(find.text('Copied'), findsOneWidget);
      expect(picked, isNull);
    });
  });

  group('your places', () {
    testWidgets('long-press copies, tap selects', (tester) async {
      final copied = mockClipboard();
      await pumpScreen(tester);

      await tester.longPress(find.text('Casa'));
      await tester.pump();
      expect(copied, ['Casa']);
      expect(find.text('Copied'), findsOneWidget);
      expect(picked, isNull);

      await tester.tap(find.text('Casa'));
      await tester.pumpAndSettle();
      expect(picked?.id, 'home');
      expect(copied, ['Casa'], reason: 'a tap copies nothing');
    });
  });
}
