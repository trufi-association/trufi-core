import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// The street → corners flow on the search screen (#745): a street result
/// whose service knows its corners gets a trailing button; tapping it
/// swaps the results for the corners list, with a back affordance, and
/// picking a corner returns it to the caller.
class _DrillDownService
    with SearchLocationDrillDown
    implements SearchLocationService {
  static const street = SearchLocation(
    id: 'street:s1',
    displayName: 'Avenida Ayacucho',
    latitude: -17.3925,
    longitude: -66.1588,
  );
  static const plainResult = SearchLocation(
    id: 'photon:1',
    displayName: 'Plaza Colón',
    latitude: -17.3882,
    longitude: -66.1557,
  );
  static const corner = SearchLocation(
    id: 'junction:s1:s2',
    displayName: 'Avenida Ayacucho & Avenida Heroínas',
    latitude: -17.3927,
    longitude: -66.1587,
  );

  @override
  Future<List<SearchLocation>> search(String query) async =>
      [street, plainResult];

  @override
  bool canDrillDown(SearchLocation location) => location.id == street.id;

  @override
  Future<List<SearchLocation>> drillDown(SearchLocation location) async =>
      [corner];

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async =>
      null;

  @override
  void dispose() {}
}

void main() {
  Future<SearchLocation?> pumpAndSearch(WidgetTester tester) async {
    SearchLocation? picked;
    await tester.pumpWidget(
      MaterialApp(
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
                    searchService: _DrillDownService(),
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

    await tester.enterText(find.byType(TextField).first, 'ayacucho');
    // Debounce (300 ms) + the async search.
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    return picked;
  }

  testWidgets('a drillable street shows the corners button; a plain '
      'result does not', (tester) async {
    await pumpAndSearch(tester);

    expect(find.text('Avenida Ayacucho'), findsOneWidget);
    expect(find.text('Plaza Colón'), findsOneWidget);
    expect(find.byIcon(Icons.fork_right_rounded), findsOneWidget);
  });

  testWidgets('tapping the corners button lists the corners and back '
      'returns to the results', (tester) async {
    await pumpAndSearch(tester);

    await tester.tap(find.byIcon(Icons.fork_right_rounded));
    await tester.pumpAndSettle();

    // Corners list replaces the results. Rows start at "&" — the header
    // already names the street, and repeating it truncated the cross
    // street's name.
    expect(find.text('& Avenida Heroínas'), findsOneWidget);
    expect(find.text('Avenida Ayacucho & Avenida Heroínas'), findsNothing);
    expect(find.text('Plaza Colón'), findsNothing);
    expect(find.textContaining('Avenida Ayacucho'), findsOneWidget); // header

    // Back returns to the plain results without re-searching.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('Plaza Colón'), findsOneWidget);
    expect(find.text('& Avenida Heroínas'), findsNothing);
  });

  testWidgets('picking a corner pops it as the selected location',
      (tester) async {
    SearchLocation? picked;
    await tester.pumpWidget(
      MaterialApp(
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
                    searchService: _DrillDownService(),
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
    await tester.enterText(find.byType(TextField).first, 'ayacucho');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.fork_right_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('& Avenida Heroínas'));
    await tester.pumpAndSettle();

    expect(picked?.id, 'junction:s1:s2');
    // The trimmed label is display-only: the picked location keeps the
    // full corner name for the origin/destination field.
    expect(picked?.displayName, 'Avenida Ayacucho & Avenida Heroínas');
  });

  testWidgets('editing the query exits the corners list', (tester) async {
    await pumpAndSearch(tester);

    await tester.tap(find.byIcon(Icons.fork_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('& Avenida Heroínas'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'ayacuch');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('& Avenida Heroínas'), findsNothing);
    expect(find.text('Plaza Colón'), findsOneWidget);
  });
}
