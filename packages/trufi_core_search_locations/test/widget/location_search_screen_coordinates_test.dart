import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// trufi-sanaa#22 — a decimal latitude/longitude pair typed or pasted into
/// the search field is offered as a "Go to `<lat>`, `<lon>`" row. The row
/// needs no network: it appears before the debounce and before any
/// service answers; the reverse geocoder, when there is one, only adds
/// the address underneath.
class _Service implements SearchLocationService {
  final List<String> searched = [];
  final List<(double, double)> reversed = [];

  /// What [search] returns; a completer-backed list lets a test hold the
  /// search open.
  Future<List<SearchLocation>> Function() results = () async => const [];

  /// What [reverse] returns, in call order; null throws (an offline
  /// service without reverse geocoding, or a network error).
  final List<Completer<SearchLocation?>> reverseAnswers = [];
  bool reverseThrows = false;
  SearchLocation? reverseAnswer;

  static const plaza = SearchLocation(
    id: 'photon:1',
    displayName: 'Plaza Colón',
    address: 'Cochabamba',
    latitude: -17.3882,
    longitude: -66.1557,
  );
  static const heroinas = SearchLocation(
    id: 'photon:2',
    displayName: 'Avenida Heroínas',
    address: 'Cochabamba',
    latitude: -17.3927,
    longitude: -66.1587,
  );

  @override
  Future<List<SearchLocation>> search(String query) {
    searched.add(query);
    return results();
  }

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) {
    reversed.add((latitude, longitude));
    if (reverseThrows) throw SearchLocationException('offline');
    if (reverseAnswers.isNotEmpty) {
      return reverseAnswers[reversed.length - 1].future;
    }
    return Future.value(reverseAnswer);
  }

  @override
  void dispose() {}
}

/// Clipboard writes captured on the platform channel (as in
/// copy_place_name_test.dart).
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

void main() {
  SearchLocation? picked;

  Future<void> pumpScreen(
    WidgetTester tester,
    _Service service, {
    Locale? locale,
  }) async {
    picked = null;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates:
            SearchLocationsLocalizations.localizationsDelegates,
        supportedLocales: SearchLocationsLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              picked = await Navigator.push<SearchLocation>(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationSearchScreen(
                    isOrigin: true,
                    searchService: service,
                    onYourLocation: () async => null,
                    onChooseOnMap: () async => null,
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

  /// Types [query] and pumps one frame: no debounce has elapsed yet.
  Future<void> type(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField).first, query);
    await tester.pump();
  }

  /// Lets the 300 ms debounce fire and the async work settle.
  Future<void> debounce(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  final goTo = find.textContaining('Go to ');

  testWidgets('a coordinate pair is offered as "Go to <lat>, <lon>" at once, '
      'before any service is asked', (tester) async {
    final service = _Service();
    await pumpScreen(tester, service);

    await type(tester, '15.294830, 44.2243701');

    expect(find.text('Go to 15.29483, 44.22437'), findsOneWidget);
    expect(find.byIcon(Icons.pin_drop_rounded), findsOneWidget);
    expect(service.searched, isEmpty);
    expect(service.reversed, isEmpty);
  });

  testWidgets('after the debounce the reverse geocoder fills the address '
      'and the text search still runs', (tester) async {
    final service = _Service()..reverseAnswer = _Service.heroinas;
    await pumpScreen(tester, service);

    await type(tester, '15.294830, 44.2243701');
    await debounce(tester);

    expect(service.reversed, [(15.294830, 44.2243701)]);
    expect(service.searched, ['15.294830, 44.2243701']);
    expect(find.text('Go to 15.29483, 44.22437'), findsOneWidget);
    expect(find.text('Avenida Heroínas, Cochabamba'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Avenida Heroínas, Cochabamba')).dy,
      greaterThan(tester.getTopLeft(find.text('Go to 15.29483, 44.22437')).dy),
    );
  });

  testWidgets('picking the row pops the pair as the name, the exact values '
      'and the address', (tester) async {
    final service = _Service()..reverseAnswer = _Service.heroinas;
    await pumpScreen(tester, service);

    await type(tester, '15.294830, 44.2243701');
    await debounce(tester);
    await tester.tap(find.text('Go to 15.29483, 44.22437'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.id, 'coordinates:15.29483,44.2243701');
    expect(picked!.displayName, '15.29483, 44.22437');
    expect(picked!.latitude, 15.294830);
    expect(picked!.longitude, 44.2243701);
    expect(picked!.address, 'Avenida Heroínas, Cochabamba');
  });

  testWidgets('picked before the debounce, the row pops without an address', (
    tester,
  ) async {
    final service = _Service()..reverseAnswer = _Service.heroinas;
    await pumpScreen(tester, service);

    await type(tester, '-17.39, -66.16');
    await tester.tap(find.text('Go to -17.39, -66.16'));
    await tester.pumpAndSettle();

    expect(picked?.displayName, '-17.39, -66.16');
    expect(picked?.latitude, -17.39);
    expect(picked?.longitude, -66.16);
    expect(picked?.address, isNull);
    // The debounce may still fire into the screen while it animates out
    // (it always did for the text search); it must not break anything.
    expect(tester.takeException(), isNull);
  });

  testWidgets('with no reverse geocoder (offline) the row stays, without '
      'address, and nothing fails', (tester) async {
    final service = _Service()..reverseThrows = true;
    await pumpScreen(tester, service);

    await type(tester, '15.294830, 44.2243701');
    await debounce(tester);

    expect(service.reversed, hasLength(1));
    expect(find.text('Go to 15.29483, 44.22437'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Go to 15.29483, 44.22437'));
    await tester.pumpAndSettle();
    expect(picked?.address, isNull);
    expect(picked?.latitude, 15.294830);
  });

  testWidgets('a reverse answer that returns null leaves the row bare', (
    tester,
  ) async {
    final service = _Service(); // reverseAnswer stays null
    await pumpScreen(tester, service);

    await type(tester, '15.294830, 44.2243701');
    await debounce(tester);

    expect(find.text('Go to 15.29483, 44.22437'), findsOneWidget);
    // Only the title and the section header and hints are texts with
    // content under the row: no address line was added.
    expect(find.text('Cochabamba'), findsNothing);
  });

  testWidgets('no spinner while the text search runs and no "No results '
      'found" when it comes back empty: the row is a result', (tester) async {
    final gate = Completer<List<SearchLocation>>();
    final service = _Service()..results = () => gate.future;
    await pumpScreen(tester, service);

    await type(tester, '15.294830, 44.2243701');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(service.searched, hasLength(1));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Go to 15.29483, 44.22437'), findsOneWidget);

    gate.complete(const []);
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsNothing);
    expect(find.text('Go to 15.29483, 44.22437'), findsOneWidget);
  });

  testWidgets('text results, when there are any, come under the row', (
    tester,
  ) async {
    final service = _Service()..results = () async => [_Service.plaza];
    await pumpScreen(tester, service);

    await type(tester, '15.294830, 44.2243701');
    await debounce(tester);

    expect(find.text('Go to 15.29483, 44.22437'), findsOneWidget);
    expect(find.text('Plaza Colón'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Plaza Colón')).dy,
      greaterThan(tester.getTopLeft(find.text('Go to 15.29483, 44.22437')).dy),
    );
  });

  testWidgets('a plain query shows no row, and the usual spinner and '
      'empty state are untouched', (tester) async {
    final gate = Completer<List<SearchLocation>>();
    final service = _Service()..results = () => gate.future;
    await pumpScreen(tester, service);

    await type(tester, 'ayacucho');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(goTo, findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete(const []);
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
    expect(service.reversed, isEmpty);
  });

  testWidgets('the hemisphere spelling and Arabic-Indic digits give the '
      'same row, with ASCII digits', (tester) async {
    final service = _Service();
    await pumpScreen(tester, service);

    await type(tester, '15.33255° N, 44.19772° E');
    expect(find.text('Go to 15.33255, 44.19772'), findsOneWidget);

    // ١٥٫٢٩٤٨٣، ٤٤٫٢٢٤٣٧ — as copied from an Arabic UI.
    await type(
      tester,
      '\u0661\u0665\u066b\u0662\u0669\u0664\u0668\u0663\u060c '
      '\u0664\u0664\u066b\u0662\u0662\u0664\u0663\u0667',
    );
    expect(find.text('Go to 15.29483, 44.22437'), findsOneWidget);
    expect(find.text('Go to 15.33255, 44.19772'), findsNothing);
  });

  testWidgets('the row follows the query: it goes away when the text stops '
      'being a pair, and the clear button drops it', (tester) async {
    final service = _Service();
    await pumpScreen(tester, service);

    await type(tester, '15.29483, 44.22437');
    expect(goTo, findsOneWidget);

    await type(tester, '15.29483, 44.22437 x');
    expect(goTo, findsNothing);

    await type(tester, '15.29483, 44.22437');
    expect(goTo, findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(goTo, findsNothing);
    expect(find.text('Your Location'), findsOneWidget);
  });

  testWidgets('a reverse answer for a query the user has since edited is '
      'dropped; the current one lands', (tester) async {
    final first = Completer<SearchLocation?>();
    final second = Completer<SearchLocation?>();
    final service = _Service()..reverseAnswers.addAll([first, second]);
    await pumpScreen(tester, service);

    await type(tester, '15.3, 44.2');
    await debounce(tester);
    await type(tester, '15.4, 44.2');
    await debounce(tester);
    expect(service.reversed, [(15.3, 44.2), (15.4, 44.2)]);

    first.complete(_Service.plaza);
    await tester.pumpAndSettle();
    expect(find.text('Plaza Colón, Cochabamba'), findsNothing);
    expect(find.text('Go to 15.4, 44.2'), findsOneWidget);

    second.complete(_Service.heroinas);
    await tester.pumpAndSettle();
    expect(find.text('Avenida Heroínas, Cochabamba'), findsOneWidget);
  });

  testWidgets('long-press copies the bare pair, not the "Go to" wording', (
    tester,
  ) async {
    final copied = mockClipboard();
    final service = _Service();
    await pumpScreen(tester, service);

    await type(tester, '15.294830, 44.2243701');
    await tester.longPress(find.text('Go to 15.29483, 44.22437'));
    await tester.pumpAndSettle();

    expect(copied, ['15.29483, 44.22437']);
    expect(picked, isNull);
  });

  testWidgets('the row is localized', (tester) async {
    final service = _Service();
    await pumpScreen(tester, service, locale: const Locale('es'));

    await type(tester, '-17.39, -66.16');

    expect(find.text('Ir a -17.39, -66.16'), findsOneWidget);
  });
}
