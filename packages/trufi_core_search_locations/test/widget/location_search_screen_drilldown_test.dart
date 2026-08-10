import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// The street → corners flow on the search screen (#745, reshaped by Sam's
/// review): tapping a street whose service knows its corners opens a
/// dedicated corners sub-screen — "← `<street>`" as the title, a filter that
/// searches only within the corners, and nothing else. Picking a corner
/// returns it to the caller with its full name.
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
  static const cornerHeroinas = SearchLocation(
    id: 'junction:s1:s2',
    displayName: 'Avenida Ayacucho & Avenida Heroínas',
    latitude: -17.3927,
    longitude: -66.1587,
  );
  static const cornerAroma = SearchLocation(
    id: 'junction:s1:s3',
    displayName: 'Avenida Ayacucho & Avenida Aroma',
    latitude: -17.3907,
    longitude: -66.1571,
  );

  @override
  Future<List<SearchLocation>> search(String query) async =>
      [street, plainResult];

  @override
  bool canDrillDown(SearchLocation location) => location.id == street.id;

  @override
  Future<List<SearchLocation>> drillDown(SearchLocation location) async =>
      [cornerAroma, cornerHeroinas];

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async =>
      null;

  @override
  void dispose() {}
}

void main() {
  SearchLocation? picked;

  Future<void> pumpAndSearch(WidgetTester tester) async {
    picked = null;
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

    await tester.enterText(find.byType(TextField).first, 'ayacucho');
    // Debounce (300 ms) + the async search.
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  Future<void> openCorners(WidgetTester tester) async {
    await pumpAndSearch(tester);
    await tester.tap(find.text('Avenida Ayacucho'));
    await tester.pumpAndSettle();
  }

  testWidgets('a drillable street shows the corners affordance; a plain '
      'result does not', (tester) async {
    await pumpAndSearch(tester);

    expect(find.text('Avenida Ayacucho'), findsOneWidget);
    expect(find.text('Plaza Colón'), findsOneWidget);
    // The fork icon marks the drillable street; the plain result keeps
    // the generic place pin. (Chevrons also appear on the quick-action
    // rows, so they are not asserted by count.)
    expect(find.byIcon(Icons.fork_right_rounded), findsOneWidget);
    expect(find.byIcon(Icons.place_rounded), findsOneWidget);
  });

  testWidgets('tapping the street itself opens the corners sub-screen '
      '(a street is not a point — picking it directly answers nothing)',
      (tester) async {
    await openCorners(tester);

    // Nothing popped: we are inside the corners sub-screen.
    expect(picked, isNull);
    // Title bar carries the street name; rows start at "&".
    expect(find.text('Avenida Ayacucho'), findsOneWidget); // the title
    expect(find.text('& Avenida Aroma'), findsOneWidget);
    expect(find.text('& Avenida Heroínas'), findsOneWidget);
    // Only corners here: no search results, no quick actions.
    expect(find.text('Plaza Colón'), findsNothing);
    expect(find.text('Your Location'), findsNothing);
    expect(find.text('Choose on Map'), findsNothing);
  });

  testWidgets('the corner filter searches only within the corners, '
      'accent-insensitively', (tester) async {
    await openCorners(tester);

    await tester.enterText(find.byType(TextField).first, 'heroinas');
    await tester.pumpAndSettle();

    expect(find.text('& Avenida Heroínas'), findsOneWidget);
    expect(find.text('& Avenida Aroma'), findsNothing);
  });

  testWidgets('picking a corner pops it with its full name', (tester) async {
    await openCorners(tester);

    await tester.tap(find.text('& Avenida Heroínas'));
    await tester.pumpAndSettle();

    expect(picked?.id, 'junction:s1:s2');
    // The trimmed label is display-only: the picked location keeps the
    // full corner name for the origin/destination field.
    expect(picked?.displayName, 'Avenida Ayacucho & Avenida Heroínas');
  });

  testWidgets('the back button returns to the results', (tester) async {
    await openCorners(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('Plaza Colón'), findsOneWidget);
    expect(find.text('& Avenida Heroínas'), findsNothing);
  });

  testWidgets('the system back leaves the corners first, not the screen',
      (tester) async {
    await openCorners(tester);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.maybePop();
    await tester.pumpAndSettle();

    // Still on the search screen, back at the results.
    expect(picked, isNull);
    expect(find.text('Plaza Colón'), findsOneWidget);
    expect(find.text('& Avenida Heroínas'), findsNothing);
  });
}
