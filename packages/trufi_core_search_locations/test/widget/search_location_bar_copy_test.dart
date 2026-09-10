import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// trufi-sanaa#9 on the home origin/destination fields: long-press copies
/// the place name (not the "name, address" the field renders); tap still
/// opens the search. Both width variants of the bar are covered.
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

const plaza = SearchLocation(
  id: 'photon:1',
  displayName: 'Plaza Colón',
  address: 'Cochabamba, Bolivia',
  latitude: -17.3882,
  longitude: -66.1557,
);
const mosque = SearchLocation(
  id: 'poi:2',
  displayName: 'جامع الصالح',
  latitude: 15.3336,
  longitude: 44.2072,
);

void main() {
  final searched = <bool>[];

  /// [width] < 500 renders the compact (portrait) fields, otherwise the wide
  /// ones with the From/To captions.
  Widget bar({
    required SearchLocationState state,
    double width = 800,
    String locale = 'en',
    TextDirection? textDirection,
  }) => MaterialApp(
    locale: Locale(locale),
    localizationsDelegates: SearchLocationsLocalizations.localizationsDelegates,
    supportedLocales: SearchLocationsLocalizations.supportedLocales,
    builder: textDirection == null
        ? null
        : (context, child) =>
              Directionality(textDirection: textDirection, child: child!),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: SearchLocationBar(
            state: state,
            showMenuButton: false,
            onSearch: ({required bool isOrigin}) async {
              searched.add(isOrigin);
              return null;
            },
            onOriginSelected: (_) {},
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    ),
  );

  setUp(searched.clear);

  testWidgets('wide bar: long-press on the origin copies the name, tap still '
      'opens the search', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(
      bar(state: const SearchLocationState(origin: plaza)),
    );

    // The field renders "name, address"…
    final field = find.text('Plaza Colón, Cochabamba, Bolivia');
    expect(field, findsOneWidget);

    await tester.longPress(field);
    await tester.pump();
    // …but the name alone is what gets copied.
    expect(copied, ['Plaza Colón']);
    expect(find.text('Copied'), findsOneWidget);
    expect(searched, isEmpty);

    await tester.tap(field);
    await tester.pumpAndSettle();
    expect(searched, [true]);
    expect(copied, ['Plaza Colón']);
  });

  testWidgets('compact bar: long-press on the destination copies, tap opens '
      'the search', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(
      bar(state: const SearchLocationState(destination: plaza), width: 400),
    );

    final field = find.text('Plaza Colón, Cochabamba, Bolivia');
    await tester.longPress(field);
    await tester.pump();
    expect(copied, ['Plaza Colón']);

    await tester.tap(field);
    await tester.pumpAndSettle();
    expect(searched, [false]);
  });

  testWidgets('an empty field has nothing to copy: the held press falls '
      'through to the tap, as before', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(bar(state: const SearchLocationState.empty()));

    await tester.longPress(find.text('Select origin'));
    await tester.pumpAndSettle();

    expect(copied, isEmpty);
    expect(find.text('Copied'), findsNothing);
    // No long-press handler is installed on an empty field, so InkWell
    // treats the release as a tap and opens the search — unchanged from
    // before this feature.
    expect(searched, [true]);
  });

  testWidgets('RTL: an Arabic destination is copied whole', (tester) async {
    final copied = mockClipboard();
    await tester.pumpWidget(
      bar(
        state: const SearchLocationState(destination: mosque),
        textDirection: TextDirection.rtl,
      ),
    );

    await tester.longPress(find.text('جامع الصالح'));
    await tester.pump();

    expect(copied, ['جامع الصالح']);
  });

  testWidgets('the wide bar captions are localized (were hard-coded '
      'From/To)', (tester) async {
    await tester.pumpWidget(bar(state: const SearchLocationState.empty()));
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);

    await tester.pumpWidget(
      bar(state: const SearchLocationState.empty(), locale: 'es'),
    );
    expect(find.text('Desde'), findsOneWidget);
    expect(find.text('Hasta'), findsOneWidget);
    expect(find.text('From'), findsNothing);
  });
}
