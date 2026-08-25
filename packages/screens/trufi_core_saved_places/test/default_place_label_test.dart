import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

// #898 (second report): renaming Home/Work saved fine and the edit sheet showed
// the new name, but the list card kept saying "Home"/"Casa" — the tile
// hard-coded the default label for every home/work place.

SavedPlace _place(String name, SavedPlaceType type) => SavedPlace(
  id: type.name,
  name: name,
  latitude: -17.39,
  longitude: -66.16,
  type: type,
  createdAt: DateTime.utc(2026, 8, 14),
);

Widget _app(Widget child, {String locale = 'es'}) => MaterialApp(
  locale: Locale(locale),
  supportedLocales: SavedPlacesLocalizations.supportedLocales,
  localizationsDelegates: const [
    SavedPlacesLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Scaffold(body: child),
);

void main() {
  testWidgets('a renamed Home shows the user\'s name', (tester) async {
    await tester.pumpWidget(
      _app(SavedPlaceTile(place: _place('Casa Cambio', SavedPlaceType.home))),
    );
    expect(find.text('Casa Cambio'), findsOneWidget);
    expect(find.text('Casa'), findsNothing);
  });

  testWidgets('a renamed Work shows the user\'s name', (tester) async {
    await tester.pumpWidget(
      _app(SavedPlaceTile(place: _place('Oficina', SavedPlaceType.work))),
    );
    expect(find.text('Oficina'), findsOneWidget);
  });

  testWidgets('a Home still carrying the default label stays localized', (
    tester,
  ) async {
    // Stored as "Casa" while the app ran in Spanish…
    await tester.pumpWidget(
      _app(SavedPlaceTile(place: _place('Casa', SavedPlaceType.home))),
    );
    expect(find.text('Casa'), findsOneWidget);

    // …and follows the UI language, as before.
    await tester.pumpWidget(
      _app(
        SavedPlaceTile(place: _place('Casa', SavedPlaceType.home)),
        locale: 'en',
      ),
    );
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('an empty name falls back to the localized label', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(SavedPlaceTile(place: _place('', SavedPlaceType.work))),
    );
    expect(find.text('Trabajo'), findsOneWidget);
  });

  testWidgets('favourites always show their own name', (tester) async {
    await tester.pumpWidget(
      _app(SavedPlaceTile(place: _place('Casa', SavedPlaceType.other))),
    );
    expect(find.text('Casa'), findsOneWidget);
  });

  test('savedPlaceDisplayName is the single source for the label', () {
    final es = lookupSavedPlacesLocalizations(const Locale('es'));
    expect(
      savedPlaceDisplayName(_place('Home', SavedPlaceType.home), es),
      'Casa',
    );
    expect(
      savedPlaceDisplayName(_place('Zuhause', SavedPlaceType.home), es),
      'Casa',
    );
    expect(
      savedPlaceDisplayName(_place('Mi depa', SavedPlaceType.home), es),
      'Mi depa',
    );
    expect(
      savedPlaceDisplayName(_place('  ', SavedPlaceType.work), es),
      'Trabajo',
    );
  });
}
