import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

// #985: every icon the edit dialog offers must render back on the tile after
// saving. The selector and the tile used to keep separate icon lists, and the
// five keys missing from the tile ('favorite', 'bookmark', 'cafe', 'parking',
// 'gas') silently fell back to the generic pin.

SavedPlace _place(String? iconName) => SavedPlace(
  id: 'id-$iconName',
  name: 'Test place',
  latitude: -17.39,
  longitude: -66.16,
  type: SavedPlaceType.other,
  iconName: iconName,
  createdAt: DateTime.utc(2026, 8, 14),
);

void main() {
  test('every selectable icon resolves to its own rounded variant', () {
    for (final icon in savedPlaceIcons) {
      expect(
        savedPlaceRoundedIcon(icon.name),
        icon.rounded,
        reason: "key '${icon.name}' must resolve to its rounded variant",
      );
    }
  });

  test('no selectable icon other than the pin falls back to the pin', () {
    for (final icon in savedPlaceIcons.where((i) => i.name != 'place')) {
      expect(
        savedPlaceRoundedIcon(icon.name),
        isNot(Icons.place_rounded),
        reason: "key '${icon.name}' must not render as the default pin",
      );
    }
  });

  test('selectable icon keys are unique', () {
    final names = savedPlaceIcons.map((i) => i.name).toSet();
    expect(names.length, savedPlaceIcons.length);
  });

  test('unknown and null keys fall back to the pin', () {
    expect(savedPlaceRoundedIcon('no-such-icon'), Icons.place_rounded);
    expect(savedPlaceRoundedIcon(null), Icons.place_rounded);
  });

  testWidgets('SavedPlaceTile renders the icon the user picked', (
    tester,
  ) async {
    for (final icon in savedPlaceIcons) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [SavedPlacesLocalizations.delegate],
          home: Scaffold(body: SavedPlaceTile(place: _place(icon.name))),
        ),
      );

      expect(
        find.byIcon(icon.rounded),
        findsOneWidget,
        reason: "tile with iconName '${icon.name}' must show ${icon.rounded}",
      );
    }
  });

  testWidgets('SavedPlaceTile falls back to the pin for unknown keys', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [SavedPlacesLocalizations.delegate],
        home: Scaffold(body: SavedPlaceTile(place: _place('legacy-key'))),
      ),
    );

    expect(find.byIcon(Icons.place_rounded), findsOneWidget);
  });
}
