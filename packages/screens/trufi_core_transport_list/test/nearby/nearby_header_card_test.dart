import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

NearbyLinesState state({
  NearbyAnchorSource source = NearbyAnchorSource.device,
  bool isLocating = false,
  bool locationDenied = false,
  NearbyStreetAnchor? street,
}) => NearbyLinesState(
  anchor: const LatLng(-17.39, -66.15),
  anchorSource: source,
  radius: NearbyRadius.m300,
  availability: NearbyAvailability.available,
  street: street,
  isLocating: isLocating,
  locationDenied: locationDenied,
);

class _Calls {
  int menus = 0;
  int closes = 0;
  int locates = 0;
}

Future<_Calls> _pumpHeader(
  WidgetTester tester,
  NearbyLinesState state, {
  Locale? locale,
  bool elevated = true,
}) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: TransportListLocalizations.localizationsDelegates,
      supportedLocales: TransportListLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: NearbyHeaderCard(
            state: state,
            elevated: elevated,
            onMenu: () => calls.menus++,
            onClose: () => calls.closes++,
            onUseMyLocation: () => calls.locates++,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return calls;
}

/// The title card: the Material that holds the screen title.
Finder _titleCard() => find
    .ancestor(of: find.text('Nearby lines'), matching: find.byType(Material))
    .first;

/// The title card whatever the language: the Material around the header's
/// only [Column].
Finder _titleCardOfAnyLocale() => find
    .ancestor(of: find.byType(Column), matching: find.byType(Material))
    .first;

/// The laid-out paragraph of [text]: line count and truncation.
RenderParagraph _paragraph(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text));

/// Sizes the test view like a phone of [width] logical pixels.
void _usePhone(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// `bodySmall` line height: the anchor label and the hint.
const double _line = 16;

void main() {
  testWidgets('menu, locate and close buttons report', (tester) async {
    final calls = await _pumpHeader(tester, state());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.tap(find.byTooltip('Use my location'));
    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    expect(calls.menus, 1);
    expect(calls.locates, 1);
    expect(calls.closes, 1);
  });

  testWidgets('GPS anchor: title, "Your location" and no pin hint', (
    tester,
  ) async {
    await _pumpHeader(tester, state());
    expect(find.text('Nearby lines'), findsOneWidget);
    expect(find.text('Your location'), findsOneWidget);
    expect(find.text('Long-press the map to move the pin'), findsNothing);
    // The anchor glyph in the card and the locate button.
    expect(find.byIcon(Icons.my_location_rounded), findsNWidgets(2));
    expect(NearbyHeaderCard.heightFor(state()), NearbyHeaderCard.cardHeight);
    expect(
      tester.getSize(_titleCard()).height,
      lessThanOrEqualTo(NearbyHeaderCard.cardHeight),
    );
  });

  testWidgets('while locating the button spins and ignores taps', (
    tester,
  ) async {
    final calls = await _pumpHeader(tester, state(isLocating: true));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byTooltip('Use my location'));
    await tester.pump();
    expect(calls.locates, 0);
  });

  testWidgets('fallback anchor: the pin hint under the anchor line', (
    tester,
  ) async {
    final fallback = state(source: NearbyAnchorSource.fallback);
    await _pumpHeader(tester, fallback);
    expect(find.text('City center (no location)'), findsOneWidget);
    expect(find.text('Long-press the map to move the pin'), findsOneWidget);
    expect(find.byIcon(Icons.location_searching_rounded), findsOneWidget);
    // The fallback label may take a second line: the reserve counts it.
    expect(
      NearbyHeaderCard.heightFor(fallback),
      NearbyHeaderCard.cardHeightWithHint +
          NearbyHeaderCard.anchorSecondLineHeight,
    );
    expect(
      tester.getSize(_titleCard()).height,
      lessThanOrEqualTo(NearbyHeaderCard.heightFor(fallback)),
    );
  });

  test('the reserved height follows the anchor: one line for a fix or a '
      'pin, two for the fallback label and a street, plus the hint', () {
    final street = NearbyStreetAnchor(
      name: 'Avenida Heroínas',
      corners: const [LatLng(-17.3925, -66.1588), LatLng(-17.3907, -66.1571)],
    );
    expect(NearbyHeaderCard.heightFor(state()), 58);
    expect(
      NearbyHeaderCard.heightFor(state(source: NearbyAnchorSource.pin)),
      58,
    );
    expect(
      NearbyHeaderCard.heightFor(
        state(source: NearbyAnchorSource.pin, locationDenied: true),
      ),
      108,
    );
    expect(
      NearbyHeaderCard.heightFor(state(source: NearbyAnchorSource.fallback)),
      124,
    );
    expect(
      NearbyHeaderCard.heightFor(
        state(source: NearbyAnchorSource.street, street: street),
      ),
      74,
    );
    // A failed fix keeps the street and adds the hint.
    expect(
      NearbyHeaderCard.heightFor(
        state(
          source: NearbyAnchorSource.street,
          street: street,
          locationDenied: true,
        ),
      ),
      124,
    );
  });

  group('the anchor label wraps instead of ending in an ellipsis '
      '(trufi-app#79)', () {
    // The test font is a 1 em square per glyph, about twice as wide as
    // Roboto, so a real 360 dp phone cannot be reproduced here; a 502 px
    // view leaves the label 270 px, where every language's fallback label
    // needs exactly its two lines.
    for (final locale in TransportListLocalizations.supportedLocales) {
      testWidgets('$locale: the fallback label takes its second line and '
          'is shown whole, with the hint under it', (tester) async {
        _usePhone(tester, 502);
        final l10n = lookupTransportListLocalizations(locale);
        final fallback = state(source: NearbyAnchorSource.fallback);
        await _pumpHeader(tester, fallback, locale: locale);

        final label = _paragraph(tester, l10n.nearbyAnchorDefault);
        expect(label.maxLines, 2);
        expect(label.size.height, 2 * _line);
        expect(label.didExceedMaxLines, isFalse);
        // Long-press still shows it whole, as for a street name.
        expect(find.byTooltip(l10n.nearbyAnchorDefault), findsOneWidget);

        final hint = _paragraph(tester, l10n.nearbyMovePinHint);
        expect(hint.maxLines, 3);
        expect(hint.didExceedMaxLines, isFalse);
        // The hint starts under the label's last line, not over it.
        expect(
          tester.getTopLeft(find.text(l10n.nearbyMovePinHint)).dy,
          greaterThanOrEqualTo(
            tester.getBottomLeft(find.text(l10n.nearbyAnchorDefault)).dy,
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a short label keeps its single line and the card its '
        'height', (tester) async {
      _usePhone(tester, 502);
      await _pumpHeader(tester, state());
      expect(_paragraph(tester, 'Your location').size.height, _line);
      expect(tester.getSize(_titleCard()).height, NearbyHeaderCard.cardHeight);
    });

    testWidgets('a street name longer than two lines still ellipsizes and '
        'keeps its tooltip', (tester) async {
      _usePhone(tester, 360);
      final street = NearbyStreetAnchor(
        name: 'Avenida Circunvalación II Doctor Martín Cárdenas Hermosa',
        subtitle: 'Cochabamba',
        corners: const [LatLng(-17.39, -66.15), LatLng(-17.38, -66.14)],
      );
      final along = state(source: NearbyAnchorSource.street, street: street);
      await _pumpHeader(tester, along);

      const text =
          'Along Avenida Circunvalación II Doctor Martín Cárdenas Hermosa '
          '· Cochabamba';
      final label = _paragraph(tester, text);
      expect(label.size.height, 2 * _line);
      expect(label.didExceedMaxLines, isTrue);
      expect(find.byTooltip(text), findsOneWidget);
      expect(
        tester.getSize(_titleCard()).height,
        lessThanOrEqualTo(NearbyHeaderCard.heightFor(along)),
      );
    });

    // The translators' budget, the one figure the template ARB states for
    // this label: two lines of at most 18 characters each. On a 360 dp
    // phone the text box is 128 px. A label with a 19-character line
    // ("Centro de la ciudad (sin ubicación)") still fit with Roboto at
    // font size 1.0 but was cut at a slightly larger Android font size;
    // with 18 per line the German label, the longest kept, stays whole up
    // to 1.5. The test font cannot show a real phone's line breaks; this
    // wraps the words the way the phone does and counts the lines.
    test('every language keeps the fallback label within two lines of 18 '
        'characters', () {
      const lineBudget = 18;
      int linesOf(String label) {
        var lines = 1;
        var used = 0; // characters on the current line
        for (final word in label.split(' ')) {
          if (used > 0 && used + 1 + word.length > lineBudget) {
            lines++;
            used = 0;
          }
          used += (used > 0 ? 1 : 0) + word.length;
          // A word longer than a line is broken mid-word.
          while (used > lineBudget) {
            lines++;
            used -= lineBudget;
          }
        }
        return lines;
      }

      // The budget tells the labels this fix replaced from the ones it
      // keeps: each of the old ones needed a third line.
      expect(linesOf('City center (location unavailable)'), 3);
      expect(linesOf('Centro de la ciudad (ubicación no disponible)'), 3);
      expect(linesOf('Stadtzentrum (Standort nicht verfügbar)'), 3);
      // And the first shortening of the Spanish one, cut on a phone too.
      expect(linesOf('Centro de la ciudad (sin ubicación)'), 3);

      for (final locale in TransportListLocalizations.supportedLocales) {
        final label = lookupTransportListLocalizations(
          locale,
        ).nearbyAnchorDefault;
        expect(linesOf(label), lessThanOrEqualTo(2), reason: '$locale: $label');
      }
    });
  });

  testWidgets('a denied location on a pinned anchor also shows the hint', (
    tester,
  ) async {
    await _pumpHeader(
      tester,
      state(source: NearbyAnchorSource.pin, locationDenied: true),
    );
    expect(find.text('Pinned location'), findsOneWidget);
    expect(find.text('Long-press the map to move the pin'), findsOneWidget);
    expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
  });

  for (final locale in const [Locale('en'), Locale('es'), Locale('de')]) {
    testWidgets('$locale: no overflow on a 360 px phone with the hint, and '
        'the card stays within the height the screen reserves', (tester) async {
      _usePhone(tester, 360);
      final fallback = state(source: NearbyAnchorSource.fallback);

      await _pumpHeader(tester, fallback, locale: locale);
      expect(tester.takeException(), isNull);
      // The wide test font fills every allowed line here: two of label,
      // three of hint — the tallest the card gets.
      expect(
        tester.getSize(_titleCardOfAnyLocale()).height,
        NearbyHeaderCard.heightFor(fallback),
      );
    });
  }

  testWidgets('flat variant (side panel) keeps the same controls', (
    tester,
  ) async {
    final calls = await _pumpHeader(tester, state(), elevated: false);
    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    expect(calls.closes, 1);
    expect(find.text('Nearby lines'), findsOneWidget);
  });
}
