import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsRouteType;
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

import 'geolocator_mock.dart';

/// Drives the real [NearbyLinesTrufiScreen] (providers + builder) over a
/// fake map engine and a canned data source: the wiring between the cubit,
/// the header card, the sheet / side panel and the map layers.
class _FakeEngine extends ITrufiMapEngine {
  _FakeEngine({this.id = 'fake'});

  List<TrufiLayer> lastLayers = const [];

  /// The camera the screen last asked the map for.
  TrufiCameraPosition? lastCamera;

  /// What the map calls when the rider pans or zooms.
  ValueChanged<TrufiCameraPosition>? onCameraChanged;

  /// Where a long press anywhere on this map lands.
  static const longPressPoint = LatLng(-17.38, -66.14);

  @override
  final String id;
  @override
  String get name => 'Fake';
  @override
  String get description => 'Fake map';

  @override
  Widget buildMap({
    TrufiMapController? controller,
    required TrufiCameraPosition initialCamera,
    TrufiCameraPosition? camera,
    ValueChanged<TrufiCameraPosition>? onCameraChanged,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
    List<TrufiLayer> layers = const [],
    List<WidgetMarker> widgetMarkers = const [],
  }) {
    lastLayers = layers;
    lastCamera = camera ?? initialCamera;
    this.onCameraChanged = onCameraChanged;
    // Hit-testable like a real map: what the controls column leaves
    // uncovered must still reach it.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => onMapLongClick?.call(longPressPoint),
      child: const SizedBox.expand(),
    );
  }
}

/// `MapEngineManager.defaultCenter` of every pump: the fallback anchor.
const defaultCenter = LatLng(-17.39, -66.15);

NearbyLine row(String name, double distance, {String? stopName}) => NearbyLine(
  lineKey: 'n:$name',
  routeId: name,
  patternId: 0,
  shortName: name,
  longName: 'Line $name',
  routeType: GtfsRouteType.bus,
  distanceMeters: distance,
  kind: stopName == null ? NearbyMatchKind.passes : NearbyMatchKind.stop,
  stopName: stopName,
  nearestPoint: LatLng(-17.39 + distance / 111195, -66.15),
);

class _FakeDataSource implements NearbyLinesDataSource {
  /// Every anchor queried, in order (a street visit queries its corners).
  final anchors = <LatLng>[];

  @override
  NearbyAvailability get availability => NearbyAvailability.available;

  @override
  Future<void> ensureLoaded() async {}

  @override
  NearbyLinesResult findNearby(
    LatLng anchor, {
    double maxRadiusMeters = NearbyRadius.maxMeters,
  }) {
    anchors.add(anchor);
    return NearbyLinesResult(
      anchor: anchor,
      maxRadiusMeters: maxRadiusMeters,
      lines: [
        row('201', 80, stopName: 'Calle San Simón'),
        row('X10', 150),
        row('18', 380, stopName: 'Av. Blanco Galindo'),
      ],
    );
  }

  @override
  NearbyLineGeometry? geometryOf(NearbyLine line) => const NearbyLineGeometry(
    polyline: [LatLng(-17.39, -66.15), LatLng(-17.38, -66.14)],
    stops: [],
  );
}

/// [locationGranted] false is a device with location switched off (the
/// pin fallback). A test that needs another kind of device calls
/// [mockGeolocator] itself and passes [mockLocation] false.
Future<_FakeEngine> _pumpScreen(
  WidgetTester tester, {
  bool withDataSource = true,
  bool locationGranted = false,
  bool mockLocation = true,
  Locale? locale,
  NearbyLineDetailsCallback? onLineDetails,
  bool showStops = true,
  int engines = 1,
  TextDirection? textDirection,
}) async {
  if (mockLocation) mockGeolocator(serviceEnabled: locationGranted);
  final engine = _FakeEngine();
  // A second engine makes the screen show the map type switcher.
  final manager = MapEngineManager(
    engines: [
      engine,
      for (var i = 1; i < engines; i++) _FakeEngine(id: 'fake-$i'),
    ],
    defaultCenter: defaultCenter,
  );
  final screen = NearbyLinesTrufiScreen(
    dataSourceBuilder: withDataSource ? (_) => _FakeDataSource() : null,
    onLineDetails: onLineDetails,
    showStops: showStops,
  );
  addTearDown(screen.dispose);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MapEngineManager>.value(value: manager),
        ...screen.providers,
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: screen.localizationsDelegates,
        supportedLocales: TransportListLocalizations.supportedLocales,
        // What GlobalWidgetsLocalizations gives an Arabic app (trufi-sanaa).
        builder: textDirection == null
            ? null
            : (context, child) =>
                  Directionality(textDirection: textDirection, child: child!),
        home: Scaffold(body: Builder(builder: screen.builder)),
      ),
    ),
  );
  // start(): ensureLoaded → locate → query.
  await tester.pumpAndSettle();
  return engine;
}

const cornerA = LatLng(-17.3925, -66.1588);
const cornerB = LatLng(-17.3907, -66.1571);

/// Horizontal screen position of [longitude] under [camera] on a map
/// [mapWidth] logical pixels wide (web mercator, 256 px tiles, bearing 0).
double screenX(TrufiCameraPosition camera, double longitude, double mapWidth) {
  final worldPx = 256 * math.pow(2.0, camera.zoom);
  return mapWidth / 2 + (longitude - camera.target.longitude) / 360 * worldPx;
}

/// Vertical screen position of [latitude] under [camera] on a map
/// [mapHeight] logical pixels tall (same projection as [screenX]).
double screenY(TrufiCameraPosition camera, double latitude, double mapHeight) {
  double mercatorY(double degrees) {
    final radians = degrees * math.pi / 180;
    return (1 - math.log(math.tan(radians) + 1 / math.cos(radians)) / math.pi) /
        2;
  }

  final worldPx = 256 * math.pow(2.0, camera.zoom);
  return mapHeight / 2 +
      (mercatorY(latitude) - mercatorY(camera.target.latitude)) * worldPx;
}

/// Sizes the test view like a phone: the narrow layout (under 600 px).
void usePhone(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Hosts the real screen under a `GoRouter`, the way `TrufiApp` does, and
/// opens it from a first route: through [NearbyLinesTrufiScreen.showAlongStreet]
/// when [street] is given, as a plain `/nearby` push (a drawer visit) when not.
Future<({_FakeEngine engine, _FakeDataSource source})> _pumpRouted(
  WidgetTester tester, {
  NearbyStreetAnchor? street,
  bool mockLocation = true,
}) async {
  if (mockLocation) mockGeolocator();
  final engine = _FakeEngine();
  final source = _FakeDataSource();
  final manager = MapEngineManager(
    engines: [engine],
    defaultCenter: defaultCenter,
  );
  final screen = NearbyLinesTrufiScreen(dataSourceBuilder: (_) => source);
  addTearDown(screen.dispose);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: TextButton(
            onPressed: () => street == null
                ? context.push(NearbyLinesTrufiScreen.routePath)
                : NearbyLinesTrufiScreen.showAlongStreet(context, street),
            child: const Text('open'),
          ),
        ),
      ),
      GoRoute(
        path: NearbyLinesTrufiScreen.routePath,
        builder: (context, _) => Scaffold(body: screen.builder(context)),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MapEngineManager>.value(value: manager),
        ...screen.providers,
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: screen.localizationsDelegates,
        supportedLocales: TransportListLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return (engine: engine, source: source);
}

/// The header's title card: the Material that holds the screen title.
Finder _titleCard() => find
    .ancestor(of: find.text('Nearby lines'), matching: find.byType(Material))
    .first;

/// Short names of the rows that wear the highlight, among the rows on
/// screen (or among every built row with [onScreen] false): the list is
/// where a highlight shows, there is no banner above it.
List<String> highlightedRows(WidgetTester tester, {bool onScreen = true}) =>
    tester
        .widgetList<NearbyLineTile>(
          find.byType(NearbyLineTile, skipOffstage: onScreen),
        )
        .where((tile) => tile.isSelected)
        .map((tile) => tile.line.displayName)
        .toList();

/// Pumps the screen with the default detail navigation and taps the first
/// row's chevron; returns the [TransportDetailScreen] it pushed.
Future<TransportDetailScreen> openDetailViaChevron(
  WidgetTester tester, {
  required bool showStops,
}) async {
  await _pumpScreen(tester, showStops: showStops);
  await tester.tap(find.byTooltip('Line details').first);
  await tester.pumpAndSettle();
  return tester.widget<TransportDetailScreen>(
    find.byType(TransportDetailScreen),
  );
}

/// Taps a radius pill. The pills are one line that scrolls sideways (the
/// test font is wider than a real one, so the last pill can start out of
/// view), as a rider would: bring it in, then tap it.
Future<void> tapPill(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('wide layout: side panel with header, chips, rows and the '
      'map layers of the fallback anchor', (tester) async {
    final engine = await _pumpScreen(tester);

    // Header row: the menu button, the title once (the sheet no longer
    // repeats it), the anchor line with its hint. No close button.
    expect(find.text('Nearby lines'), findsOneWidget);
    expect(find.text('City center (no location)'), findsOneWidget);
    expect(find.text('Long-press the map to move the pin'), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
    expect(find.byType(TrufiBottomSheet), findsNothing);
    // The panel insets the flat header like the route detail (12 px):
    // the menu button and the card are not glued to the panel's edges.
    // The panel is 340 px wide under 900 px.
    final menuTopLeft = tester.getTopLeft(
      find.byTooltip('Open navigation menu'),
    );
    expect(menuTopLeft.dx, greaterThanOrEqualTo(12));
    expect(menuTopLeft.dy, greaterThanOrEqualTo(12));
    expect(tester.getTopRight(_titleCard()).dx, 340 - 12);
    // "Use my location" is a map control: top right of the map, 16 px in,
    // outlined while the search is not on the device position.
    final locate = find.byTooltip('Use my location');
    expect(locate, findsOneWidget);
    expect(tester.getTopRight(locate).dx, 800 - 16);
    expect(tester.getTopLeft(locate).dx, greaterThan(340));
    expect(find.byIcon(Icons.my_location_outlined), findsOneWidget);
    expect(find.text('2 lines within 300 m'), findsOneWidget);

    expect(find.text('100 m (1)'), findsOneWidget);
    expect(find.text('300 m (2)'), findsOneWidget);
    expect(find.text('500 m (3)'), findsOneWidget);
    expect(find.textContaining('At 80 m'), findsOneWidget);
    expect(find.textContaining('Passes by at 150 m'), findsOneWidget);
    expect(find.textContaining('At 380 m'), findsNothing);

    final ids = engine.lastLayers.map((l) => l.id).toList();
    expect(ids, ['nearby-rings', 'nearby-points', 'nearby-anchor']);
    // Only the selected radius is drawn, with its label (trufi-app#80).
    final ring = engine.lastLayers.first;
    expect(ring.lines.map((l) => l.id), ['nearby-ring-300']);
    expect(ring.lines.single.lineWidth, 3);
    expect(
      ring.lines.single.position,
      NearbyGeometry.circlePolygon(defaultCenter, 300),
    );
    expect(ring.markers.map((m) => m.id), ['nearby-ring-label']);
    final points = engine.lastLayers[1];
    expect(points.markers.map((m) => m.id), [
      'nearby-point-n:201',
      'nearby-point-n:X10',
      'nearby-point-n:18',
    ]);
    // Badge with the mode glyph plus the distance chip need the wider box.
    expect(points.markers.first.size, const Size(130, 32));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a row highlights it on the map; the chevron opens the '
      'detail through the callback', (tester) async {
    final opened = <NearbyLine>[];
    final engine = await _pumpScreen(
      tester,
      onLineDetails: (_, line) => opened.add(line),
    );

    await tester.tap(find.textContaining('At 80 m'));
    await tester.pumpAndSettle();
    expect(highlightedRows(tester), ['201']);
    final ids = engine.lastLayers.map((l) => l.id).toList();
    expect(ids, contains('nearby-selected-line'));
    final selected = engine.lastLayers.firstWhere(
      (l) => l.id == 'nearby-selected-line',
    );
    expect(selected.lines.single.position, hasLength(2));
    expect(selected.lines.single.lineWidth, 5);

    await tester.tap(find.textContaining('At 80 m'));
    await tester.pumpAndSettle();
    expect(highlightedRows(tester, onScreen: false), isEmpty);

    await tester.tap(find.byTooltip('Line details').first);
    await tester.pumpAndSettle();
    expect(opened.map((l) => l.displayName), ['201']);
  });

  // One test per value: a second pumpWidget would update the same
  // MaterialApp/Navigator in place and leave the first pushed detail on top.
  testWidgets('the default chevron navigation opens the detail with stops '
      'shown (the default)', (tester) async {
    expect(
      (await openDetailViaChevron(tester, showStops: true)).showStops,
      isTrue,
    );
  });

  testWidgets("the default chevron navigation forwards the screen's "
      'showStops: false (trufi-sanaa#18)', (tester) async {
    expect(
      (await openDetailViaChevron(tester, showStops: false)).showStops,
      isFalse,
    );
  });

  testWidgets('radius chips filter the rows and the map draws only the ring '
      'of the selected radius (trufi-app#80)', (tester) async {
    final engine = await _pumpScreen(tester);

    // Every bracket in turn, ending on one that was already shown: the
    // ring follows the chip and the other two never stay behind.
    for (final (chip, meters) in const [
      ('500 m (3)', 500.0),
      ('100 m (1)', 100.0),
      ('300 m (2)', 300.0),
    ]) {
      await tapPill(tester, chip);
      await tester.pumpAndSettle();

      final ring = engine.lastLayers.first;
      expect(ring.id, 'nearby-rings');
      expect(ring.lines.map((l) => l.id), ['nearby-ring-${meters.round()}']);
      expect(
        ring.lines.single.position,
        NearbyGeometry.circlePolygon(defaultCenter, meters),
      );
      expect(ring.lines.single.lineWidth, 3);
      expect(ring.markers.map((m) => m.id), ['nearby-ring-label']);
      expect(
        find.textContaining('At 380 m'),
        meters == 500 ? findsOneWidget : findsNothing,
      );
    }
  });

  testWidgets('with a GPS fix the anchor is the device position', (
    tester,
  ) async {
    final engine = await _pumpScreen(tester, locationGranted: true);
    expect(find.text('Your location'), findsOneWidget);
    expect(find.text('Long-press the map to move the pin'), findsNothing);
    // The locate control is filled, like the home screen's while tracking
    // (the card's anchor glyph is the other filled one).
    expect(
      find.descendant(
        of: find.byTooltip('Use my location'),
        matching: find.byIcon(Icons.my_location_rounded),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.my_location_outlined), findsNothing);
    final anchorLayer = engine.lastLayers.last;
    expect(anchorLayer.id, 'nearby-anchor');
    expect(anchorLayer.markers.single.position, deviceFix);
    expect(anchorLayer.markers.single.size, const Size(24, 24));
    final ring = engine.lastLayers.first;
    expect(ring.lines.single.position.first.longitude, deviceFix.longitude);
  });

  testWidgets('narrow layout: floating header card and the bottom sheet', (
    tester,
  ) async {
    usePhone(tester, const Size(400, 800));

    await _pumpScreen(tester);
    expect(find.byType(TrufiBottomSheet), findsOneWidget);
    expect(find.byType(NearbyHeaderCard), findsOneWidget);
    expect(find.text('Nearby lines'), findsOneWidget);
    expect(find.text('300 m (2)'), findsOneWidget);
    expect(find.textContaining('At 80 m'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a phone the card spans the width the menu button leaves '
      'and "Use my location" heads the map controls under it, 16 px from '
      'the edge like the home screen', (tester) async {
    usePhone(tester, const Size(360, 640));
    await _pumpScreen(tester, engines: 2);

    final card = tester.getRect(_titleCard());
    expect(card.left, 12 + 44 + 12);
    expect(card.right, 360 - 12);
    expect(find.byTooltip('Close'), findsNothing);

    // Layers, then locate, in one right-aligned column under the card.
    final layers = tester.getRect(find.byTooltip('Change map type'));
    final locate = tester.getRect(find.byTooltip('Use my location'));
    expect(layers.top, closeTo(card.bottom + 12, 0.5));
    expect(layers.right, 360 - 16);
    expect(locate.right, 360 - 16);
    expect(locate.top, closeTo(layers.bottom + 8, 0.5));
    expect(locate.size, const Size(48, 48));
    expect(layers.size, locate.size);
  });

  testWidgets('right to left (Arabic in trufi-sanaa): the header mirrors, '
      'the map controls stay on the right 16 px in, as on the home screen', (
    tester,
  ) async {
    usePhone(tester, const Size(360, 640));
    await _pumpScreen(tester, engines: 2, textDirection: TextDirection.rtl);

    expect(tester.getRect(find.byTooltip('Open navigation menu')).right, 348);
    expect(tester.getRect(find.byTooltip('Change map type')).right, 360 - 16);
    expect(tester.getRect(find.byTooltip('Use my location')).right, 360 - 16);
  });

  testWidgets('the map controls follow the card when its text grows', (
    tester,
  ) async {
    usePhone(tester, const Size(360, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpScreen(tester);

    final card = tester.getRect(_titleCard());
    final locate = tester.getRect(find.byTooltip('Use my location'));
    expect(locate.top, closeTo(card.bottom + 12, 0.5));
    // The test font is twice as wide as Roboto: at 1.5 the sheet's route
    // count pill overflows 360 px by 88 px, on main too (the header's own
    // overflow tests are in nearby_header_card_test.dart). Only the first
    // exception is kept, so pin that it is this one and not a new one.
    expect(
      tester.takeException().toString(),
      contains('A RenderFlex overflowed by 88 pixels on the right'),
    );
  });

  testWidgets('the controls column does not cover the map beside it: a '
      'long press there still moves the pin', (tester) async {
    usePhone(tester, const Size(360, 640));
    final engine = await _pumpScreen(tester);
    expect(find.text('Pinned location'), findsNothing);

    // Same height as the locate control, well left of it: the column spans
    // the screen's width there, but only its buttons take hits.
    final locate = tester.getRect(find.byTooltip('Use my location'));
    await tester.longPressAt(Offset(60, locate.center.dy));
    await tester.pumpAndSettle();

    expect(find.text('Pinned location'), findsOneWidget);
    expect(
      engine.lastLayers.last.markers.single.position,
      _FakeEngine.longPressPoint,
    );
  });

  testWidgets('with a fix, the first fit of a visit frames the ring under '
      'the one-line header it then has, not under the taller fallback '
      'header the screen starts on', (tester) async {
    usePhone(tester, const Size(360, 640));
    final engine = await _pumpScreen(tester, locationGranted: true);
    expect(find.text('Your location'), findsOneWidget);

    ({double top, double bottom}) ringEdges() {
      final camera = engine.lastCamera!;
      final latitudes = engine.lastLayers.first.lines.single.position.map(
        (point) => point.latitude,
      );
      return (
        top: screenY(camera, latitudes.reduce(math.max), 640),
        bottom: screenY(camera, latitudes.reduce(math.min), 640),
      );
    }

    // Before anything is tapped: 24 px of header margin and the 58 px
    // card above the ring, the sheet (35 % of 640) below it — a 334 px
    // ring. Fitted with the fallback header's reserve it was 268 px.
    final first = ringEdges();
    expect(first.top, closeTo(24 + NearbyHeaderCard.cardHeight, 0.5));
    expect(first.bottom, closeTo(640 * 0.65, 0.5));

    // And it is where the ring settles after any later fit.
    await tapPill(tester, '500 m (3)');
    await tester.pumpAndSettle();
    await tapPill(tester, '300 m (2)');
    await tester.pumpAndSettle();
    final settled = ringEdges();
    expect(settled.top, closeTo(first.top, 0.5));
    expect(settled.bottom, closeTo(first.bottom, 0.5));
  });

  testWidgets('on a phone the ring keeps the whole width of the map: the '
      'street margin does not shrink it', (tester) async {
    // Tall enough for the width to be what limits the ring.
    usePhone(tester, const Size(400, 1000));
    final engine = await _pumpScreen(tester);

    final camera = engine.lastCamera!;
    final ring = engine.lastLayers.first.lines.single.position;
    final longitudes = ring.map((p) => p.longitude);
    expect(screenX(camera, longitudes.reduce(math.min), 400), closeTo(0, 0.5));
    expect(
      screenX(camera, longitudes.reduce(math.max), 400),
      closeTo(400, 0.5),
    );
  });

  testWidgets('without a local planner the screen explains instead of '
      'failing', (tester) async {
    await _pumpScreen(tester, withDataSource: false);
    expect(
      find.text('Nearby lines need the offline GTFS planner'),
      findsOneWidget,
    );
    expect(find.byType(NearbyRadiusPill), findsNothing);
    expect(find.text('City center (no location)'), findsOneWidget);
  });

  group('lines along a street (trufi-sanaa#20)', () {
    final street = NearbyStreetAnchor(
      name: 'Avenida Heroínas',
      subtitle: 'Cercado',
      corners: const [cornerA, cornerB],
    );

    testWidgets('opened through showAlongStreet: every corner is queried, '
        'the header names the street, the map shows a dot per corner and '
        'neither rings nor a pin', (tester) async {
      final (:engine, :source) = await _pumpRouted(tester, street: street);

      expect(source.anchors, [cornerA, cornerB]);
      // The anchor line names the municipality too (same-named streets in
      // several municipalities) and carries the whole text as a tooltip.
      expect(find.text('Along Avenida Heroínas · Cercado'), findsOneWidget);
      expect(
        find.byTooltip('Along Avenida Heroínas · Cercado'),
        findsOneWidget,
      );
      expect(find.text('Your location'), findsNothing);
      expect(find.text('Long-press the map to move the pin'), findsNothing);
      // The same three lines from both corners collapse to three rows.
      expect(find.text('2 lines within 300 m'), findsOneWidget);
      expect(find.textContaining('At 80 m'), findsOneWidget);

      final ids = engine.lastLayers.map((l) => l.id).toList();
      expect(ids, ['nearby-street-corners', 'nearby-points']);
      final corners = engine.lastLayers.first;
      expect(corners.markers.map((m) => m.id), [
        'nearby-corner-0',
        'nearby-corner-1',
      ]);
      expect(corners.markers.map((m) => m.position), [cornerA, cornerB]);
      expect(corners.lines, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('on a phone the street is framed with half a line label '
        'of margin on each side, so the dot and the label of its '
        'outermost corners are not cut by the screen edge (#1054)', (
      tester,
    ) async {
      usePhone(tester, const Size(400, 800));
      // Runs east–west: the screen's width decides the zoom.
      const west = LatLng(-17.3700, -66.1900);
      const east = LatLng(-17.3705, -66.1500);
      final (:engine, :source) = await _pumpRouted(
        tester,
        street: NearbyStreetAnchor(
          name: 'Avenida Circunvalación',
          corners: const [west, LatLng(-17.3702, -66.1700), east],
        ),
      );
      expect(find.byType(TrufiBottomSheet), findsOneWidget);

      final camera = engine.lastCamera!;
      // The line label is a 130 px box centred on its point.
      expect(screenX(camera, west.longitude, 400), closeTo(65, 0.5));
      expect(screenX(camera, east.longitude, 400), closeTo(400 - 65, 0.5));
    });

    testWidgets('the first fit of a street visit sits under the street '
        "header's own reserve", (tester) async {
      usePhone(tester, const Size(400, 800));
      // Runs north–south: the screen's height decides the zoom.
      const north = LatLng(-17.3700, -66.1570);
      const south = LatLng(-17.4000, -66.1572);
      final (:engine, :source) = await _pumpRouted(
        tester,
        street: NearbyStreetAnchor(
          name: 'Avenida Ayacucho',
          corners: const [north, LatLng(-17.3850, -66.1571), south],
        ),
      );

      // 24 px of header margin and the two-line street card (74 px): the
      // fallback header the visit starts on would have put it at 148.
      final camera = engine.lastCamera!;
      expect(
        screenY(camera, north.latitude, 800),
        closeTo(
          24 +
              NearbyHeaderCard.cardHeight +
              NearbyHeaderCard.anchorSecondLineHeight,
          0.5,
        ),
      );
    });

    testWidgets('in the side-panel layout the street margin adds to the '
        "panel layout's own padding", (tester) async {
      const west = LatLng(-17.3700, -66.1900);
      const east = LatLng(-17.3705, -66.1500);
      final (:engine, :source) = await _pumpRouted(
        tester,
        street: NearbyStreetAnchor(
          name: 'Avenida Circunvalación',
          corners: const [west, east],
        ),
      );
      expect(find.byType(TrufiBottomSheet), findsNothing);

      // 800 px view, 340 px panel: a 460 px map padded 24 px all round.
      final camera = engine.lastCamera!;
      expect(screenX(camera, west.longitude, 460), closeTo(24 + 65, 0.5));
      expect(screenX(camera, east.longitude, 460), closeTo(460 - 24 - 65, 0.5));
    });

    testWidgets('"Use my location" leaves the street for the fix', (
      tester,
    ) async {
      final (:engine, :source) = await _pumpRouted(tester, street: street);

      await tester.tap(find.byTooltip('Use my location'));
      await tester.pumpAndSettle();

      expect(find.text('Your location'), findsOneWidget);
      expect(find.textContaining('Along Avenida Heroínas'), findsNothing);
      expect(source.anchors.last, deviceFix);
      final ids = engine.lastLayers.map((l) => l.id).toList();
      expect(ids, ['nearby-rings', 'nearby-points', 'nearby-anchor']);
    });

    testWidgets('a plain /nearby push (drawer visit) still locates', (
      tester,
    ) async {
      final (:engine, :source) = await _pumpRouted(tester);

      expect(find.text('Your location'), findsOneWidget);
      expect(source.anchors, [deviceFix]);
      final ids = engine.lastLayers.map((l) => l.id).toList();
      expect(ids, ['nearby-rings', 'nearby-points', 'nearby-anchor']);
    });

    testWidgets('with no close button, system back still returns from the '
        'street visit to the caller', (tester) async {
      await _pumpRouted(tester, street: street);
      expect(find.byTooltip('Close'), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
      expect(find.textContaining('Along Avenida Heroínas'), findsNothing);
    });

    testWidgets('the street visit leads with a back button: iOS has no '
        'system back, and the app shell drawer takes the edge swipe', (
      tester,
    ) async {
      await _pumpRouted(tester, street: street);
      expect(find.byTooltip('Open navigation menu'), findsNothing);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(find.textContaining('Along Avenida Heroínas'), findsNothing);
    });

    testWidgets('a drawer visit keeps the menu button', (tester) async {
      await _pumpRouted(tester);
      expect(find.byTooltip('Open navigation menu'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
    });
  });

  group('"Use my location" explains why there is no position '
      '(trufi-app#78)', () {
    const disabledTitle = 'Location disabled';
    const disabledMessage =
        'Location services are disabled on your device. Enable them to see '
        'the lines near you.';
    const permissionTitle = 'Location permission';
    const permissionMessage =
        'Location permission is permanently denied. Enable it in your '
        'device settings to see the lines near you.';
    const deniedMessage =
        'Location permission denied. Tap the button again to allow it, or '
        'long-press the map to move the pin.';
    const noFixMessage =
        "Couldn't get your location. Try again in a moment, or long-press "
        'the map to move the pin.';

    Future<void> tapUseMyLocation(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Use my location'));
      await tester.pumpAndSettle();
    }

    /// Lets the snack bar run out: its timer must not outlive the test.
    Future<void> expireSnackBar(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    }

    Iterable<String> settingsOpened(List<String> calls) =>
        calls.where((method) => method.startsWith('open'));

    // The locate of a visit is not the rider's request: whatever the
    // device answers, only the header and the pin say it.
    for (final (device, mock) in <(String, List<String> Function())>[
      (
        'with location switched off',
        () => mockGeolocator(serviceEnabled: false),
      ),
      (
        'whose prompt is answered "don\'t allow"',
        () => mockGeolocator(checkPermission: GeoPermission.denied),
      ),
      (
        'that denied the permission for good',
        () => mockGeolocator(
          checkPermission: GeoPermission.denied,
          requestPermission: [GeoPermission.deniedForever],
        ),
      ),
      ('that gets no fix', () => mockGeolocator(fix: GeoFix.fails)),
    ]) {
      testWidgets('opening the screen on a device $device shows neither a '
          'dialog nor a snack bar', (tester) async {
        final calls = mock();
        await _pumpScreen(tester, mockLocation: false);

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
        expect(find.text('City center (no location)'), findsOneWidget);
        expect(find.text('Long-press the map to move the pin'), findsOneWidget);
        expect(settingsOpened(calls), isEmpty);
      });
    }

    testWidgets('location switched off: a dialog says so and its action '
        'opens the location settings', (tester) async {
      final calls = mockGeolocator(serviceEnabled: false);
      await _pumpScreen(tester, mockLocation: false);
      await tapUseMyLocation(tester);

      expect(find.widgetWithText(AlertDialog, disabledTitle), findsOneWidget);
      expect(find.text(disabledMessage), findsOneWidget);
      expect(find.byIcon(Icons.location_disabled_rounded), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      // A permission is not asked for while it could not be used.
      expect(calls, isNot(contains('requestPermission')));

      await tester.tap(find.widgetWithText(FilledButton, 'Open settings'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(settingsOpened(calls), ['openLocationSettings']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('permission denied for good, the Android way (the request '
        'comes back without a prompt): a dialog whose action opens the '
        "app's settings", (tester) async {
      final calls = mockGeolocator(
        checkPermission: GeoPermission.denied,
        requestPermission: [GeoPermission.deniedForever],
      );
      await _pumpScreen(tester, mockLocation: false);
      await tapUseMyLocation(tester);

      expect(find.widgetWithText(AlertDialog, permissionTitle), findsOneWidget);
      expect(find.text(permissionMessage), findsOneWidget);
      expect(find.byIcon(Icons.location_off_rounded), findsOneWidget);
      // Once for the visit, once for the tap.
      expect(calls.where((method) => method == 'requestPermission'), [
        'requestPermission',
        'requestPermission',
      ]);

      await tester.tap(find.widgetWithText(FilledButton, 'Open settings'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(settingsOpened(calls), ['openAppSettings']);
    });

    testWidgets('permission denied for good, the iOS way (the check already '
        'says so): the same dialog without asking again; "Cancel" closes it '
        'and opens nothing', (tester) async {
      final calls = mockGeolocator(
        checkPermission: GeoPermission.deniedForever,
      );
      await _pumpScreen(tester, mockLocation: false);
      await tapUseMyLocation(tester);

      expect(find.widgetWithText(AlertDialog, permissionTitle), findsOneWidget);
      expect(calls, isNot(contains('requestPermission')));

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(settingsOpened(calls), isEmpty);
      // The rider can ask again.
      await tapUseMyLocation(tester);
      expect(find.widgetWithText(AlertDialog, permissionTitle), findsOneWidget);
    });

    testWidgets('the prompt answered "don\'t allow": a snack bar says the '
        'button asks again, and no dialog piles on the prompt', (tester) async {
      mockGeolocator(checkPermission: GeoPermission.denied);
      await _pumpScreen(tester, mockLocation: false);
      await tapUseMyLocation(tester);

      expect(find.widgetWithText(SnackBar, deniedMessage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await expireSnackBar(tester);
    });

    testWidgets('the platform fails to give a position: a snack bar', (
      tester,
    ) async {
      mockGeolocator(fix: GeoFix.fails);
      await _pumpScreen(tester, mockLocation: false);
      await tapUseMyLocation(tester);

      expect(find.widgetWithText(SnackBar, noFixMessage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await expireSnackBar(tester);
    });

    testWidgets('no fix within 10 s: the button spins meanwhile, then the '
        'snack bar', (tester) async {
      mockGeolocator(fix: GeoFix.never);
      // The visit's own locate runs into the same time limit.
      await _pumpScreen(tester, mockLocation: false);

      await tester.tap(find.byTooltip('Use my location'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 9));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.widgetWithText(SnackBar, noFixMessage), findsOneWidget);
      await expireSnackBar(tester);
    });

    testWidgets('while locating, a second tap on the control does not start '
        'another locate', (tester) async {
      final calls = mockGeolocator(fix: GeoFix.never);
      await _pumpScreen(tester, mockLocation: false);

      await tester.tap(find.byTooltip('Use my location'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final asked = calls.length;
      await tester.tap(find.byTooltip('Use my location'));
      await tester.pump();
      expect(calls.length, asked);

      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      await expireSnackBar(tester);
    });

    testWidgets('on a phone the snack bar shows over the sheet', (
      tester,
    ) async {
      usePhone(tester, const Size(400, 800));
      mockGeolocator(checkPermission: GeoPermission.denied);
      await _pumpScreen(tester, mockLocation: false);
      expect(find.byType(TrufiBottomSheet), findsOneWidget);
      await tapUseMyLocation(tester);

      expect(find.widgetWithText(SnackBar, deniedMessage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expireSnackBar(tester);
    });

    testWidgets('the prompt denied on the visit and allowed on the tap: '
        'the anchor moves to the fix and nothing else is shown', (
      tester,
    ) async {
      final calls = mockGeolocator(
        checkPermission: GeoPermission.denied,
        requestPermission: [GeoPermission.denied, GeoPermission.whileInUse],
      );
      final engine = await _pumpScreen(tester, mockLocation: false);
      expect(find.text('City center (no location)'), findsOneWidget);

      await tapUseMyLocation(tester);
      expect(find.text('Your location'), findsOneWidget);
      expect(find.text('Long-press the map to move the pin'), findsNothing);
      expect(engine.lastLayers.last.markers.single.position, deviceFix);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      // The tap asked the system again: that is the prompt the rider sees.
      expect(calls.where((method) => method == 'requestPermission'), [
        'requestPermission',
        'requestPermission',
      ]);
    });

    testWidgets('denied on the visit, denied again on the tap (Android 11+ '
        'turns the second "don\'t allow" into deniedForever): the visit stays '
        'quiet and the tap shows the dialog with "Open settings"', (
      tester,
    ) async {
      final calls = mockGeolocator(
        checkPermission: GeoPermission.denied,
        requestPermission: [GeoPermission.denied, GeoPermission.deniedForever],
      );
      await _pumpScreen(tester, mockLocation: false);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('City center (no location)'), findsOneWidget);

      await tapUseMyLocation(tester);
      // No memory between the two requests: the answer of the tap alone
      // decides, and deniedForever is the settings dialog right away.
      expect(find.widgetWithText(AlertDialog, permissionTitle), findsOneWidget);
      expect(find.text(permissionMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(calls.where((method) => method == 'requestPermission'), [
        'requestPermission',
        'requestPermission',
      ]);

      await tester.tap(find.widgetWithText(FilledButton, 'Open settings'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(settingsOpened(calls), ['openAppSettings']);
    });

    testWidgets('with a fix nothing is shown: the anchor just moves', (
      tester,
    ) async {
      final engine = await _pumpScreen(tester, locationGranted: true);
      await tapUseMyLocation(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Your location'), findsOneWidget);
      expect(engine.lastLayers.last.markers.single.position, deviceFix);
    });

    testWidgets('a rider who left the screen before the answer gets no '
        'message on the next one', (tester) async {
      mockGeolocator(fix: GeoFix.never);
      await _pumpRouted(tester, mockLocation: false);

      await tester.tap(find.byTooltip('Use my location'));
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);

      await tester.pump(const Duration(seconds: 11));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the messages come from the package l10n (Spanish)', (
      tester,
    ) async {
      mockGeolocator(serviceEnabled: false);
      await _pumpScreen(
        tester,
        mockLocation: false,
        locale: const Locale('es'),
      );
      await tester.tap(find.byTooltip('Usar mi ubicación'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AlertDialog, 'Ubicación desactivada'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Los servicios de ubicación están desactivados en tu dispositivo. '
          'Actívalos para ver las líneas cercanas a ti.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Cancelar'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Abrir configuración'),
        findsOneWidget,
      );
    });
  });

  // Every fit runs on the build after the state change, not in the bloc
  // listener. The first fit and the street fits are pinned above; these
  // two pin the later ones. They fail when a radius change no longer
  // refits, when highlighting a line or clearing it moves the camera, and
  // when the street margin survives the street.
  testWidgets('a new radius refits the ring; highlighting a line and '
      'clearing it leave the camera where it is', (tester) async {
    usePhone(tester, const Size(360, 640));
    final engine = await _pumpScreen(tester, locationGranted: true);
    const top = 24 + NearbyHeaderCard.cardHeight; // 82
    const bottom = 640 * 0.65; // 416: the sheet's initial 35 %

    void expectRingFramed(String id) {
      final ring = engine.lastLayers.first.lines.single;
      expect(ring.id, id);
      final camera = engine.lastCamera!;
      final latitudes = ring.position.map((p) => p.latitude);
      expect(
        screenY(camera, latitudes.reduce(math.max), 640),
        closeTo(top, 0.5),
      );
      expect(
        screenY(camera, latitudes.reduce(math.min), 640),
        closeTo(bottom, 0.5),
      );
    }

    expectRingFramed('nearby-ring-300');

    await tapPill(tester, '500 m (3)');
    await tester.pumpAndSettle();
    expectRingFramed('nearby-ring-500');

    // The row is under the sheet's fold at 360x640: toggle it the way a
    // row tap or a label tap does.
    NearbyLinesCubit cubit() =>
        tester.element(find.byType(NearbyHeaderCard)).read<NearbyLinesCubit>();
    // The camera the 500 m fit left: the zoom and the target do not move.
    final ringCamera = engine.lastCamera!;
    void expectCameraKept() {
      final camera = engine.lastCamera!;
      expect(camera.zoom, ringCamera.zoom);
      expect(camera.target, ringCamera.target);
    }

    cubit().toggleLine('n:201');
    await tester.pumpAndSettle();
    expect(highlightedRows(tester), ['201']);
    // The route is drawn (it runs far past the ring) but not framed.
    expect(
      engine.lastLayers.map((l) => l.id),
      contains('nearby-selected-line'),
    );
    expectCameraKept();

    // Another line, then none: still the same camera.
    cubit().toggleLine('n:X10');
    await tester.pumpAndSettle();
    expect(highlightedRows(tester), ['X10']);
    expectCameraKept();
    cubit().toggleLine('n:X10');
    await tester.pumpAndSettle();
    expect(highlightedRows(tester, onScreen: false), isEmpty);
    expectCameraKept();
    expectRingFramed('nearby-ring-500');
  });

  testWidgets('a line tapped after the rider zoomed in keeps that zoom and '
      'that view (the camera used to zoom out to the whole route)', (
    tester,
  ) async {
    usePhone(tester, const Size(360, 640));
    final engine = await _pumpScreen(tester, locationGranted: true);

    // The rider zooms in on a corner of the ring.
    final riderCamera = TrufiCameraPosition(
      target: const LatLng(-17.3895, -66.1490),
      zoom: 17.5,
    );
    engine.onCameraChanged!(riderCamera);
    await tester.pump();

    // A tap on a row and a tap on a map label: both go through toggleLine.
    tester
        .element(find.byType(NearbyHeaderCard))
        .read<NearbyLinesCubit>()
        .toggleLine('n:201');
    await tester.pumpAndSettle();
    expect(highlightedRows(tester), ['201']);
    expect(engine.lastCamera!.zoom, riderCamera.zoom);
    expect(engine.lastCamera!.target, riderCamera.target);
  });

  testWidgets('a line highlighted from the map comes whole into the phone '
      'sheet, above the navigation bar, and the sheet keeps its size', (
    tester,
  ) async {
    // A small phone: one line of pinned pills leaves room for the row at
    // the mid snap, above a 48 px bar.
    usePhone(tester, const Size(360, 640));
    // A three-button navigation bar: the sheet runs under it.
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await _pumpScreen(tester, locationGranted: true);
    await tapPill(tester, '500 m (3)');
    await tester.pumpAndSettle();

    final list = find.byType(CustomScrollView);
    Rect row(String title) => tester.getRect(
      find.ancestor(
        of: find.text(title, skipOffstage: false),
        matching: find.byType(NearbyLineTile, skipOffstage: false),
      ),
    );
    bool whole(String title) {
      final viewport = tester.getRect(list);
      final rect = row(title);
      return rect.top >= viewport.top - 0.5 &&
          rect.bottom <= viewport.bottom - 48 + 0.5;
    }

    // At the mid snap the farthest row is below the fold.
    expect(whole('Line 18'), isFalse);
    final sheetTop = tester.getTopLeft(list).dy;

    // What a tap on its label on the map does.
    tester
        .element(find.byType(NearbyHeaderCard))
        .read<NearbyLinesCubit>()
        .toggleLine('n:18');
    await tester.pumpAndSettle();
    expect(whole('Line 18'), isTrue);
    expect(highlightedRows(tester), ['18']);
    // The list scrolled inside the sheet; the sheet did not grow.
    expect(tester.getTopLeft(list).dy, sheetTop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the radius pills are pinned in the phone sheet: a reveal '
      'leaves them in view, and dragging them opens the sheet the scrolled '
      'list no longer does', (tester) async {
    usePhone(tester, const Size(360, 800));
    await _pumpScreen(tester, locationGranted: true);
    await tapPill(tester, '500 m (3)');
    await tester.pumpAndSettle();

    final header = find.byType(NearbyLinesHeader);
    final list = find.byType(CustomScrollView);
    // Above the rows, not among them.
    expect(find.descendant(of: list, matching: header), findsNothing);
    expect(
      tester.getRect(header).bottom,
      lessThanOrEqualTo(tester.getTopLeft(list).dy + 0.5),
    );
    // One line of pills; the count stays at the top of the list.
    expect(tester.getRect(header).height, lessThan(60));
    expect(
      find.descendant(of: list, matching: find.byType(RouteCountIndicator)),
      findsOneWidget,
    );
    final headerTop = tester.getTopLeft(header).dy;
    ScrollPosition listPosition() => tester
        .state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)).first,
        )
        .position;

    tester
        .element(find.byType(NearbyHeaderCard))
        .read<NearbyLinesCubit>()
        .toggleLine('n:18');
    await tester.pumpAndSettle();
    // The list scrolled to the row; the pills stayed where they were.
    expect(listPosition().pixels, greaterThan(0));
    expect(tester.getTopLeft(header).dy, headerTop);
    expect(find.text('500 m (3)'), findsOneWidget);

    // A drag on the rows scrolls the list, so the pills are the handle.
    await tester.dragFrom(tester.getCenter(header), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(header).dy, lessThan(headerTop - 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a sideways drag on the pinned pills scrolls them and leaves '
      'the sheet where it is; an upward drag on them still opens it', (
    tester,
  ) async {
    // The test font is wide enough for the pills to overflow 360 px.
    usePhone(tester, const Size(360, 640));
    await _pumpScreen(tester, locationGranted: true);
    final header = find.byType(NearbyLinesHeader);
    ScrollPosition strip() => tester
        .state<ScrollableState>(
          find.descendant(of: header, matching: find.byType(Scrollable)),
        )
        .position;
    NearbyLinesCubit cubit() =>
        tester.element(find.byType(NearbyHeaderCard)).read<NearbyLinesCubit>();
    expect(strip().maxScrollExtent, greaterThan(0));
    final headerTop = tester.getTopLeft(header).dy;

    await tester.dragFrom(
      tester.getCenter(find.text('100 m (1)')),
      const Offset(-150, 0),
    );
    await tester.pumpAndSettle();
    expect(strip().pixels, greaterThan(0));
    expect(tester.getTopLeft(header).dy, headerTop);
    expect(cubit().state.radius, NearbyRadius.m300);

    // The last pill came in with the rider's drag: a plain tap reaches it.
    await tester.tap(find.text('500 m (3)'));
    await tester.pumpAndSettle();
    expect(cubit().state.radius, NearbyRadius.m500);

    await tester.dragFrom(
      tester.getCenter(find.text('500 m (3)')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(header).dy, lessThan(headerTop - 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a rebuild of the screen during a reveal does not stop it (the '
      'sheet keeps the same snap sizes, a new list would snap it again)', (
    tester,
  ) async {
    usePhone(tester, const Size(360, 800));
    final engine = await _pumpScreen(tester, locationGranted: true);
    await tapPill(tester, '500 m (3)');
    await tester.pumpAndSettle();
    final list = find.byType(CustomScrollView);
    bool whole(String title) {
      final viewport = tester.getRect(list);
      final rect = tester.getRect(
        find.ancestor(
          of: find.text(title, skipOffstage: false),
          matching: find.byType(NearbyLineTile, skipOffstage: false),
        ),
      );
      return rect.top >= viewport.top - 0.5 &&
          rect.bottom <= viewport.bottom + 0.5;
    }

    expect(whole('Line 18'), isFalse);
    tester
        .element(find.byType(NearbyHeaderCard))
        .read<NearbyLinesCubit>()
        .toggleLine('n:18');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // The rider pans the map meanwhile: the recenter control shows up and
    // the screen rebuilds while the list is still on its way.
    engine.onCameraChanged!(
      TrufiCameraPosition(target: const LatLng(-17.30, -66.10), zoom: 12),
    );
    await tester.pumpAndSettle();
    final recenter = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byIcon(Icons.crop_free_rounded),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(recenter.opacity, 1);
    expect(whole('Line 18'), isTrue);
  });

  testWidgets('the collapsed phone sheet keeps the pinned pills whole above '
      'the navigation bar', (tester) async {
    usePhone(tester, const Size(360, 640));
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await _pumpScreen(tester, locationGranted: true);

    final header = find.byType(NearbyLinesHeader);
    // Down to the min snap, by the pills.
    await tester.drag(find.text('100 m (1)'), const Offset(0, 400));
    await tester.pumpAndSettle();
    final pills = tester.getRect(header);
    expect(pills.bottom, lessThanOrEqualTo(640 - 48 + 0.5));
    // Collapsed: the sheet went down, to just the grabber and the pills.
    expect(pills.top, greaterThan(640 * (1 - 0.35)));
    expect(pills.bottom, closeTo(640 - 48, 0.5));
    expect(tester.takeException(), isNull);
  });

  // A status bar takes its height off the sheet (TrufiBottomSheet's
  // SafeArea): the sheet's sizes are fractions of what is left. A min
  // measured on the whole screen came out a few pixels short: the pills
  // ended under the navigation bar, and without a bottom inset (no
  // navigation bar under the app, as on the iPhone SE) the sheet's column
  // overflowed. Without a bottom inset the floor (0.14) already covers one
  // line of pills on a phone-sized screen, so that case runs on a short
  // window (a split-screen half), where the min is above the floor.
  for (final (bottom, height) in [(48.0, 720.0), (0.0, 380.0)]) {
    testWidgets('under a status bar, the collapsed phone sheet keeps the '
        'pinned pills whole above the bottom inset ($bottom px, $height '
        'px tall)', (tester) async {
      usePhone(tester, Size(360, height));
      tester.view.padding = FakeViewPadding(top: 24, bottom: bottom);
      tester.view.viewPadding = FakeViewPadding(top: 24, bottom: bottom);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      await _pumpScreen(tester, locationGranted: true);

      await tester.drag(find.text('100 m (1)'), const Offset(0, 400));
      await tester.pumpAndSettle();
      final pills = tester.getRect(find.byType(NearbyLinesHeader));
      expect(pills.bottom, closeTo(height - bottom, 0.5));
      // Collapsed: the sheet went down past the mid snap.
      expect(pills.top, greaterThan(24 + (height - 24) * (1 - 0.35)));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the collapsed sheet follows the pinned pills when the text '
      'size changes: one line at 2x, whole above the bar, and back', (
    tester,
  ) async {
    usePhone(tester, const Size(360, 640));
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpScreen(tester, locationGranted: true);
    // The route count pill at the top of the list overflows 360 px at this
    // size with the test font, on main too (see the 1.5x test above). Pin
    // that the one exception kept is that one, not the sheet's column.
    expect(
      tester.takeException().toString(),
      allOf(contains('A RenderFlex overflowed by'), contains('on the right')),
    );

    final header = find.byType(NearbyLinesHeader);
    await tester.dragFrom(tester.getCenter(header), const Offset(0, 400));
    await tester.pumpAndSettle();
    final large = tester.getRect(header);
    // One line of pills (a pill is about 36 px at this size).
    expect(large.height, lessThan(80));
    expect(large.bottom, closeTo(640 - 48, 0.5));

    // Back to the default size: the min shrinks with the pills. A sheet
    // already collapsed keeps its size until the next drag (a lower min
    // does not move it), so the pills only have to stay whole.
    tester.platformDispatcher.textScaleFactorTestValue = 1.0;
    await tester.pumpAndSettle();
    final small = tester.getRect(header);
    expect(small.height, lessThan(large.height));
    expect(small.bottom, lessThanOrEqualTo(640 - 48 + 0.5));
    await tester.dragFrom(tester.getCenter(header), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(tester.getRect(header).bottom, closeTo(640 - 48, 0.5));
    expect(tester.takeException(), isNull);
  });

  for (final direction in TextDirection.values) {
    testWidgets('the pinned pills start at the sheet\'s leading edge, like '
        'the count under them (${direction.name})', (tester) async {
      // Wide enough for the three pills with room to spare (the narrow
      // layout runs up to 600), so a centred strip would show.
      usePhone(tester, const Size(590, 800));
      await _pumpScreen(
        tester,
        locationGranted: true,
        textDirection: direction,
      );
      final first = tester.getRect(find.byType(NearbyRadiusPill).first);
      final count = tester.getRect(find.byType(RouteCountIndicator));
      if (direction == TextDirection.ltr) {
        expect(first.left, 16);
        expect(count.left, 0);
      } else {
        expect(first.right, 590 - 16);
        expect(count.right, 590);
      }
    });
  }

  testWidgets('the side panel pins the radius pills above its rows too', (
    tester,
  ) async {
    await _pumpScreen(tester, locationGranted: true);
    expect(find.byType(TrufiBottomSheet), findsNothing);
    final header = find.byType(NearbyLinesHeader);
    final list = find.byType(CustomScrollView);
    expect(header, findsOneWidget);
    expect(find.descendant(of: list, matching: header), findsNothing);
    expect(
      tester.getRect(header).bottom,
      lessThanOrEqualTo(tester.getTopLeft(list).dy + 0.5),
    );
    expect(
      find.descendant(of: list, matching: find.byType(NearbyRadiusPill)),
      findsNothing,
    );
  });

  testWidgets('with a line highlighted, a new radius and a moved pin still '
      'frame the search area: only the highlight keeps the camera', (
    tester,
  ) async {
    usePhone(tester, const Size(360, 640));
    final engine = await _pumpScreen(tester, locationGranted: true);
    const top = 24 + NearbyHeaderCard.cardHeight; // 82
    const bottom = 640 * 0.65; // 416

    void expectRingFramed(String id, LatLng center) {
      final ring = engine.lastLayers
          .firstWhere((l) => l.id == 'nearby-rings')
          .lines
          .single;
      expect(ring.id, id);
      final camera = engine.lastCamera!;
      final latitudes = ring.position.map((p) => p.latitude);
      expect(
        screenY(camera, latitudes.reduce(math.max), 640),
        closeTo(top, 0.5),
      );
      expect(
        screenY(camera, latitudes.reduce(math.min), 640),
        closeTo(bottom, 0.5),
      );
      expect(camera.target.longitude, closeTo(center.longitude, 1e-9));
    }

    tester
        .element(find.byType(NearbyHeaderCard))
        .read<NearbyLinesCubit>()
        .toggleLine('n:201');
    await tester.pumpAndSettle();
    expect(highlightedRows(tester), ['201']);

    await tapPill(tester, '500 m (3)');
    await tester.pumpAndSettle();
    expect(highlightedRows(tester), ['201']);
    expectRingFramed('nearby-ring-500', deviceFix);

    // A long press on the map moves the pin; line 201 is still near it.
    await tester.longPressAt(const Offset(60, 300));
    await tester.pumpAndSettle();
    expect(find.text('Pinned location'), findsOneWidget);
    expect(highlightedRows(tester), ['201']);
    expectRingFramed('nearby-ring-500', _FakeEngine.longPressPoint);
    // Anchored on the pin, not the device position: the outlined control.
    expect(find.byIcon(Icons.my_location_outlined), findsOneWidget);
  });

  testWidgets('leaving a street for the device position frames the ring '
      'across the whole width again: the street margin does not stay', (
    tester,
  ) async {
    // Tall enough for the width to be what limits the ring.
    usePhone(tester, const Size(400, 1000));
    final (:engine, :source) = await _pumpRouted(
      tester,
      street: NearbyStreetAnchor(
        name: 'Avenida Heroínas',
        corners: const [cornerA, cornerB],
      ),
    );

    await tester.tap(find.byTooltip('Use my location'));
    await tester.pumpAndSettle();
    expect(find.text('Your location'), findsOneWidget);

    final camera = engine.lastCamera!;
    final longitudes = engine.lastLayers.first.lines.single.position.map(
      (p) => p.longitude,
    );
    expect(screenX(camera, longitudes.reduce(math.min), 400), closeTo(0, 0.5));
    expect(
      screenX(camera, longitudes.reduce(math.max), 400),
      closeTo(400, 0.5),
    );
  });

  test('screen identity and menu entry', () {
    final screen = NearbyLinesTrufiScreen();
    addTearDown(screen.dispose);
    expect(screen.id, 'nearby_lines');
    expect(screen.path, '/nearby');
    expect(NearbyLinesTrufiScreen.routePath, '/nearby');
    expect(screen.hasOwnAppBar, isTrue);
    expect(screen.menuItem?.order, 2);
    expect(screen.menuItem?.icon, Icons.near_me_rounded);
    expect(screen.providers, hasLength(1));
  });
}
