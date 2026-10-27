import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import 'in_memory_repository.dart';

// #1003, second half: the list already drew the address under the name, but
// a place picked on the map was saved without one — hence three identical
// "Parada" rows. The sheet now resolves the picked point and, failing that,
// stores "lat, lon", so no map-picked place is ever saved blank.

const _lat = -17.39884;
const _lng = -66.16269;
const _street = 'Av. Heroínas, Cochabamba';
const _coordinates = '-17.39884, -66.16269';

SavedPlace _place({
  String id = '1',
  String name = 'Parada',
  String? address,
  double lat = _lat,
  double lng = _lng,
  SavedPlaceType type = SavedPlaceType.other,
}) => SavedPlace(
  id: id,
  name: name,
  address: address,
  latitude: lat,
  longitude: lng,
  type: type,
  createdAt: DateTime(2026, 1, 1),
);

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: const [
    SavedPlacesLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Scaffold(body: child),
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Finds the subtitle row of the location card: "Location selected" plus the
/// text right under it.
Finder _locationSubtitle(String text) => find.descendant(
  of: find
      .ancestor(
        of: find.text('Location selected'),
        matching: find.byType(Column),
      )
      .first,
  matching: find.text(text),
);

void main() {
  group('formatCoordinates', () {
    test('five decimals, comma separated', () {
      expect(formatCoordinates(_lat, _lng), _coordinates);
      expect(formatCoordinates(0, 0), '0.00000, 0.00000');
    });
  });

  group('SavedPlace JSON', () {
    test('a null address stays null through toJson/fromJson', () {
      final restored = SavedPlace.fromJson(_place().toJson());
      expect(restored.address, isNull);
      expect(_place().toJson()['address'], isNull);
    });

    test('a record written before #1003 (no address key) still loads', () {
      final json = _place().toJson()..remove('address');
      expect(SavedPlace.fromJson(json).address, isNull);
    });

    test('a resolved address and the coordinates fallback round-trip', () {
      for (final address in [_street, _coordinates]) {
        final restored = SavedPlace.fromJson(_place(address: address).toJson());
        expect(restored.address, address);
        expect(restored, _place(address: address));
      }
    });
  });

  group('SavedPlaceTile subtitle', () {
    testWidgets('shows the address under the name', (tester) async {
      await tester.pumpWidget(
        _app(SavedPlaceTile(place: _place(address: _street))),
      );
      expect(find.text('Parada'), findsOneWidget);
      expect(find.text(_street), findsOneWidget);
    });

    testWidgets('a place without address shows only its name', (tester) async {
      await tester.pumpWidget(_app(SavedPlaceTile(place: _place())));
      expect(find.text('Parada'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SavedPlaceTile),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
    });

    testWidgets('two same-named places read differently', (tester) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              SavedPlaceTile(
                place: _place(id: 'a', address: _street),
              ),
              SavedPlaceTile(
                place: _place(id: 'b', address: _coordinates, lat: -17.37),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Parada'), findsNWidgets(2));
      expect(find.text(_street), findsOneWidget);
      expect(find.text(_coordinates), findsOneWidget);
    });
  });

  group('EditPlaceDialog address', () {
    Future<SavedPlace?> pumpSheet(
      WidgetTester tester, {
      SavedPlace? place,
      OnChooseOnMap? onChooseOnMap,
      OnResolveAddress? onResolveAddress,
    }) async {
      _phone(tester);
      SavedPlace? saved;
      await tester.pumpWidget(
        _app(
          EditPlaceDialog(
            place: place,
            onChooseOnMap: onChooseOnMap,
            onResolveAddress: onResolveAddress,
            onSave: (p) => saved = p,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return saved;
    }

    Future<void> pickAndSave(WidgetTester tester) async {
      await tester.tap(find.text('Tap to select on map'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    testWidgets('a picked point is reverse geocoded, shown on the card and '
        'stored with the place', (tester) async {
      SavedPlace? saved;
      final lookups = <(double, double)>[];
      _phone(tester);
      await tester.pumpWidget(
        _app(
          EditPlaceDialog(
            onChooseOnMap: ({initialLatitude, initialLongitude}) async =>
                (latitude: _lat, longitude: _lng),
            onResolveAddress: (lat, lng) async {
              lookups.add((lat, lng));
              return _street;
            },
            onSave: (p) => saved = p,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Parada');

      await tester.tap(find.text('Tap to select on map'));
      await tester.pumpAndSettle();
      expect(lookups, [(_lat, _lng)]);
      expect(_locationSubtitle(_street), findsOneWidget);
      expect(_locationSubtitle(_coordinates), findsNothing);

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved?.address, _street);
    });

    testWidgets('no answer → the coordinates become the address', (
      tester,
    ) async {
      final resolvers = <OnResolveAddress?>[
        null,
        (_, _) async => null,
        (_, _) async => '   ',
        (_, _) async => throw StateError('offline'),
      ];
      _phone(tester);
      for (final (i, resolve) in resolvers.indexed) {
        SavedPlace? saved;
        await tester.pumpWidget(
          _app(
            EditPlaceDialog(
              key: ValueKey(i), // a fresh sheet per resolver
              onChooseOnMap: ({initialLatitude, initialLongitude}) async =>
                  (latitude: _lat, longitude: _lng),
              onResolveAddress: resolve,
              onSave: (p) => saved = p,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), 'Parada');
        await pickAndSave(tester);
        expect(saved?.address, _coordinates, reason: 'resolver: $resolve');
      }
    });

    testWidgets('a late answer for the previous pick is discarded', (
      tester,
    ) async {
      final picks = [
        (latitude: _lat, longitude: _lng),
        (latitude: -17.37, longitude: -66.15),
      ];
      var pick = 0;
      final first = Completer<String?>();
      SavedPlace? saved;
      _phone(tester);
      await tester.pumpWidget(
        _app(
          EditPlaceDialog(
            onChooseOnMap: ({initialLatitude, initialLongitude}) async =>
                picks[pick++],
            onResolveAddress: (lat, _) =>
                lat == _lat ? first.future : Future.value('Plaza Colón'),
            onSave: (p) => saved = p,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Parada');

      await tester.tap(find.text('Tap to select on map')); // slow lookup
      await tester.pumpAndSettle();
      expect(
        _locationSubtitle(_coordinates),
        findsOneWidget,
        reason: 'pending',
      );
      await tester.tap(find.text('Location selected')); // re-pick: fast lookup
      await tester.pumpAndSettle();
      expect(_locationSubtitle('Plaza Colón'), findsOneWidget);

      first.complete(_street); // the first lookup answers too late
      await tester.pumpAndSettle();
      expect(_locationSubtitle('Plaza Colón'), findsOneWidget);
      expect(_locationSubtitle(_street), findsNothing);

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved?.address, 'Plaza Colón');
      expect(saved?.latitude, -17.37);
    });

    testWidgets('editing a place saved before #1003 resolves its address on '
        'open, without moving the pin', (tester) async {
      final saved = await pumpSheet(
        tester,
        place: _place(),
        onResolveAddress: (_, _) async => _street,
      );
      expect(saved, isNull);
      expect(_locationSubtitle(_street), findsOneWidget);

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    });

    testWidgets('editing a place that has an address keeps it and does not '
        'look it up again', (tester) async {
      var lookups = 0;
      await pumpSheet(
        tester,
        place: _place(address: _street),
        onResolveAddress: (_, _) async {
          lookups++;
          return 'somewhere else';
        },
      );
      expect(lookups, 0);
      expect(_locationSubtitle(_street), findsOneWidget);
    });

    testWidgets('a placeholder Home (no coordinates) triggers no lookup', (
      tester,
    ) async {
      var lookups = 0;
      await pumpSheet(
        tester,
        place: _place(
          id: 'home_placeholder',
          name: 'Home',
          lat: 0,
          lng: 0,
          type: SavedPlaceType.home,
        ),
        onResolveAddress: (_, _) async {
          lookups++;
          return _street;
        },
      );
      expect(lookups, 0);
      expect(find.text('No location selected'), findsOneWidget);
    });
  });

  group('through SavedPlacesScreen', () {
    testWidgets('two "Parada" picked on the map end up with different '
        'subtitles in the list and in storage', (tester) async {
      _phone(tester);
      final repository = InMemorySavedPlacesRepository();
      final picks = [
        (latitude: _lat, longitude: _lng),
        (latitude: -17.37, longitude: -66.15),
      ];
      var pick = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [SavedPlacesLocalizations.delegate],
          home: SavedPlacesScreen(
            repository: repository,
            onChooseOnMap: ({initialLatitude, initialLongitude}) async =>
                picks[pick++],
            // The geocoder knows the first corner, not the second.
            onResolveAddress: (lat, _) async => lat == _lat ? _street : null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), 'Parada');
        await tester.tap(find.text('Tap to select on map'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Save'));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
      }

      expect(find.widgetWithText(SavedPlaceTile, 'Parada'), findsNWidgets(2));
      expect(find.widgetWithText(SavedPlaceTile, _street), findsOneWidget);
      expect(
        find.widgetWithText(SavedPlaceTile, '-17.37000, -66.15000'),
        findsOneWidget,
      );
      final stored = await repository.getOtherPlaces();
      expect(stored.map((p) => p.address), [_street, '-17.37000, -66.15000']);
    });
  });
}
