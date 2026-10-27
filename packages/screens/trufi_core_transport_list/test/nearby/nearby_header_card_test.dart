import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

NearbyLinesState state({
  NearbyAnchorSource source = NearbyAnchorSource.device,
  bool isLocating = false,
  bool locationDenied = false,
}) => NearbyLinesState(
  anchor: const LatLng(-17.39, -66.15),
  anchorSource: source,
  radius: NearbyRadius.m300,
  availability: NearbyAvailability.available,
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
    expect(find.text('City center (location unavailable)'), findsOneWidget);
    expect(find.text('Long-press the map to move the pin'), findsOneWidget);
    expect(find.byIcon(Icons.location_searching_rounded), findsOneWidget);
    expect(
      NearbyHeaderCard.heightFor(fallback),
      NearbyHeaderCard.cardHeightWithHint,
    );
    expect(
      tester.getSize(_titleCard()).height,
      lessThanOrEqualTo(NearbyHeaderCard.cardHeightWithHint),
    );
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
    testWidgets('$locale: no overflow on a 360 px phone with the hint', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpHeader(
        tester,
        state(source: NearbyAnchorSource.fallback),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
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
