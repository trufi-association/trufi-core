import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// The street → corners flow on the search screen (#745, reshaped by Sam's
/// review): tapping a street whose service knows its corners opens a
/// dedicated corners sub-screen — "← `<street>`" as the title, a filter that
/// searches only within the corners, and nothing else. Picking a corner
/// returns it to the caller with its full name.
class _DrillDownService
    with SearchLocationDrillDown, LanguageAwareSearch
    implements SearchLocationService {
  String? languageReceived;

  @override
  set searchLanguage(String? languageCode) => languageReceived = languageCode;

  /// Municipality carried by the street result (#972). Null renders the
  /// bare name, as an index without `region` does.
  final String? locality;

  _DrillDownService({this.locality});

  SearchLocation get street => SearchLocation(
        id: 'street:s1',
        displayName: 'Avenida Ayacucho',
        address: locality,
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

  /// Aroma lies in the street's own municipality; Heroínas is a boundary
  /// corner shared with Sacaba. Same ids as the constants, so equality
  /// (by id) with them still holds.
  @override
  Future<List<SearchLocation>> drillDown(SearchLocation location) async => [
        _located(cornerAroma, locality),
        _located(
          cornerHeroinas,
          locality == null ? null : '$locality / Sacaba',
        ),
      ];

  static SearchLocation _located(SearchLocation corner, String? address) =>
      SearchLocation(
        id: corner.id,
        displayName: corner.displayName,
        address: address,
        latitude: corner.latitude,
        longitude: corner.longitude,
      );

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async =>
      null;

  @override
  void dispose() {}
}

void main() {
  SearchLocation? picked;

  Future<void> pumpAndSearch(WidgetTester tester, {String? locality}) async {
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
                    searchService: _DrillDownService(locality: locality),
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

  Future<void> openCorners(WidgetTester tester, {String? locality}) async {
    await pumpAndSearch(tester, locality: locality);
    await tester.tap(find.text('Avenida Ayacucho'));
    await tester.pumpAndSettle();
  }

  /// The text lines of the corners header — everything rendered above the
  /// corner filter field: the street name, plus its municipality when the
  /// index carries one (#972).
  List<String> headerLines(WidgetTester tester) {
    final filterTop = tester.getTopLeft(find.byType(TextField).first).dy;
    return [
      for (final text in tester.widgetList<Text>(find.byType(Text)))
        if (tester.getTopLeft(find.byWidget(text)).dy < filterTop)
          text.data ?? '',
    ];
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

  testWidgets('the screen keeps the geocoder language in sync with the '
      'app locale (#945)', (tester) async {
    final service = _DrillDownService();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates:
            SearchLocationsLocalizations.localizationsDelegates,
        supportedLocales: SearchLocationsLocalizations.supportedLocales,
        home: LocationSearchScreen(isOrigin: true, searchService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(service.languageReceived, 'es');
  });

  group('street locality (#972)', () {
    testWidgets('a street result shows its municipality under the name',
        (tester) async {
      await pumpAndSearch(tester, locality: 'Sacaba');

      expect(find.text('Sacaba'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Sacaba')).dy,
        greaterThan(tester.getTopLeft(find.text('Avenida Ayacucho')).dy),
      );
    });

    testWidgets('the corners header repeats it under the street name',
        (tester) async {
      await openCorners(tester, locality: 'Cercado');

      expect(headerLines(tester), ['Avenida Ayacucho', 'Cercado']);
    });

    testWidgets(
        'corner rows do not repeat the header\'s municipality, only a '
        'boundary corner names both', (tester) async {
      await openCorners(tester, locality: 'Cercado');

      // Aroma shares the street's municipality → the header's line is the
      // only "Cercado"; Heroínas sits on the boundary → its own subtitle.
      expect(find.text('Cercado'), findsOneWidget);
      expect(find.text('Cercado / Sacaba'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Cercado / Sacaba')).dy,
        greaterThan(tester.getTopLeft(find.text('& Avenida Heroínas')).dy),
      );
    });

    testWidgets('without a municipality the header is the bare street name',
        (tester) async {
      await openCorners(tester);

      expect(headerLines(tester), ['Avenida Ayacucho']);
    });
  });
}
