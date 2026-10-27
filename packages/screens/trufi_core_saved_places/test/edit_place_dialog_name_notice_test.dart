import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import 'in_memory_repository.dart';

// #1003: a soft notice under the name field when another saved place already
// goes by that name. Soft means: visible before saving, gone as soon as the
// name changes, and never in the way of Save.

const _notice = 'You already have a place with this name';

SavedPlace _place({
  String id = '1',
  String name = 'Parada',
  double lat = -17.39884,
  double lng = -66.16269,
}) => SavedPlace(
  id: id,
  name: name,
  latitude: lat,
  longitude: lng,
  type: SavedPlaceType.other,
  createdAt: DateTime(2026, 1, 1),
);

Widget _app(Widget child, {String locale = 'en'}) => MaterialApp(
  locale: Locale(locale),
  supportedLocales: SavedPlacesLocalizations.supportedLocales,
  localizationsDelegates: const [
    SavedPlacesLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Scaffold(body: child),
);

bool _taken(String name) => SavedPlacesCubit.normalizeName(name) == 'parada';

void main() {
  testWidgets('the notice follows the typed name and never blocks Save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SavedPlace? saved;
    await tester.pumpWidget(
      _app(
        EditPlaceDialog(
          place: _place(id: 'new', name: '', lat: -17.4, lng: -66.1),
          isNameTaken: _taken,
          onSave: (place) => saved = place,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_notice), findsNothing, reason: 'empty name: no notice');

    await tester.enterText(find.byType(TextFormField), 'parada');
    await tester.pumpAndSettle();
    expect(find.text(_notice), findsOneWidget, reason: 'case-insensitive');

    await tester.enterText(find.byType(TextFormField), 'Parada 2');
    await tester.pumpAndSettle();
    expect(find.text(_notice), findsNothing, reason: 'a free name clears it');

    await tester.enterText(find.byType(TextFormField), 'Parada');
    await tester.pumpAndSettle();
    expect(find.text(_notice), findsOneWidget);

    // The notice pushes Save below the fold of the 800 px test surface; the
    // sheet scrolls, as on a phone.
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved?.name, 'Parada', reason: 'the notice is not a validator');
  });

  testWidgets('editing a place whose name is shared shows the notice before '
      'anything is typed', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        EditPlaceDialog(place: _place(), isNameTaken: _taken, onSave: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_notice), findsOneWidget);
  });

  testWidgets('without a predicate the sheet never warns', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(EditPlaceDialog(place: _place(), onSave: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.text(_notice), findsNothing);
  });

  testWidgets('the notice is localized', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        EditPlaceDialog(place: _place(), isNameTaken: _taken, onSave: (_) {}),
        locale: 'es',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ya tienes un lugar con este nombre'), findsOneWidget);
  });

  group('through SavedPlacesScreen', () {
    Future<void> openAdd(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
    }

    testWidgets('a second "Parada" is warned about and still saved; editing '
        'it does not collide with itself', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final repository = InMemorySavedPlacesRepository();
      // One "Parada" already saved, 3 km from where the picker will land.
      await repository.savePlace(_place(id: 'first', lat: -17.37));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [SavedPlacesLocalizations.delegate],
          home: SavedPlacesScreen(
            repository: repository,
            onChooseOnMap: ({initialLatitude, initialLongitude}) async =>
                (latitude: -17.39884, longitude: -66.16269),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await openAdd(tester);
      await tester.enterText(find.byType(TextFormField), 'Parada');
      await tester.pumpAndSettle();
      expect(find.text(_notice), findsOneWidget);

      await tester.tap(find.text('Tap to select on map'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.byType(EditPlaceDialog), findsNothing);
      expect(find.widgetWithText(SavedPlaceTile, 'Parada'), findsNWidgets(2));

      // Edit the one we just added: its own name is not "in use".
      await tester.tap(find.byIcon(Icons.more_vert_rounded).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit place'));
      await tester.pumpAndSettle();
      expect(
        find.text(_notice),
        findsOneWidget,
        reason: 'the other Parada still exists',
      );

      await tester.enterText(find.byType(TextFormField), 'Parada Sur');
      await tester.pumpAndSettle();
      expect(find.text(_notice), findsNothing);
    });
  });
}
