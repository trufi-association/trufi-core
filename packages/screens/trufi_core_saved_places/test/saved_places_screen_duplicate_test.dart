import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import 'in_memory_repository.dart';

// #898 end-to-end through the real widgets: "+" → name → pick on map → Save,
// twice, with the picker returning points 2 m apart (what a human does when
// re-picking "the same spot"). The first guard only ever fired for
// byte-identical coordinates, so this flow produced two entries.

const _lat = -17.39884;
const _lng = -66.16269;
const _degPerMeterLat = 1 / 111_000;

void main() {
  Future<void> addPlace(WidgetTester tester, String name) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), name);
    await tester.tap(find.text('Tap to select on map'));
    await tester.pumpAndSettle();
    expect(find.text('Location selected'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(EditPlaceDialog), findsNothing, reason: 'sheet closed');
  }

  Finder tilesNamed(String name) => find.widgetWithText(SavedPlaceTile, name);

  testWidgets('saving the same place twice keeps one entry and warns', (
    tester,
  ) async {
    final picks = <({double latitude, double longitude})>[
      (latitude: _lat, longitude: _lng),
      (latitude: _lat + 2 * _degPerMeterLat, longitude: _lng),
      (latitude: _lat + 500 * _degPerMeterLat, longitude: _lng),
    ];
    var pick = 0;

    // Phone-sized surface: on the default 800x600 the sheet's Save button
    // sits below the fold and the tap silently misses.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [SavedPlacesLocalizations.delegate],
        home: SavedPlacesScreen(
          repository: InMemorySavedPlacesRepository(),
          onChooseOnMap: ({initialLatitude, initialLongitude}) async =>
              picks[pick++],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await addPlace(tester, 'Prueba');
    expect(tilesNamed('Prueba'), findsOneWidget);

    await addPlace(tester, 'Prueba'); // 2 m away
    expect(tilesNamed('Prueba'), findsOneWidget, reason: 'no second entry');
    expect(
      find.text('"Prueba" is already saved at that location'),
      findsOneWidget,
      reason: 'the user is told why nothing happened',
    );

    await tester.pumpAndSettle(const Duration(seconds: 5)); // snackbar gone
    await addPlace(tester, 'Prueba'); // 500 m away: a different place
    expect(tilesNamed('Prueba'), findsNWidgets(2));
  });
}
