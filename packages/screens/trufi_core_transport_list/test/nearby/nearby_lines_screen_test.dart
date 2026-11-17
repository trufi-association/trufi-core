import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsRouteType;
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// Drives the real [NearbyLinesTrufiScreen] (providers + builder) over a
/// fake map engine and a canned data source: the wiring between the cubit,
/// the header card, the sheet / side panel and the map layers.
class _FakeEngine extends ITrufiMapEngine {
  List<TrufiLayer> lastLayers = const [];

  /// The camera the screen last asked the map for.
  TrufiCameraPosition? lastCamera;

  @override
  String get id => 'fake';
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
    return const SizedBox.expand();
  }
}

const deviceFix = LatLng(-17.40, -66.16);

/// `MapEngineManager.defaultCenter` of every pump: the fallback anchor.
const defaultCenter = LatLng(-17.39, -66.15);

/// Answers geolocator's method channel in-process: without a handler the
/// real channel never replies under the test's fake async, so the screen
/// would spin on "locating" forever. [granted] drives the GPS path; false
/// reports location services off (the pin fallback).
void mockGeolocator({required bool granted}) {
  const channel = MethodChannel('flutter.baseflow.com/geolocator');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  // `LocationPermission.whileInUse` is index 2 of geolocator's enum.
  final replies = <String, Object?>{
    'isLocationServiceEnabled': granted,
    'checkPermission': 2,
    'requestPermission': 2,
    'getCurrentPosition': {
      'latitude': deviceFix.latitude,
      'longitude': deviceFix.longitude,
      'timestamp': 0,
      'accuracy': 10.0,
    },
  };
  messenger.setMockMethodCallHandler(
    channel,
    (call) async => replies[call.method],
  );
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
}

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

Future<_FakeEngine> _pumpScreen(
  WidgetTester tester, {
  bool withDataSource = true,
  bool locationGranted = false,
  NearbyLineDetailsCallback? onLineDetails,
  bool showStops = true,
}) async {
  mockGeolocator(granted: locationGranted);
  final engine = _FakeEngine();
  final manager = MapEngineManager(
    engines: [engine],
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
        localizationsDelegates: screen.localizationsDelegates,
        supportedLocales: TransportListLocalizations.supportedLocales,
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
}) async {
  mockGeolocator(granted: true);
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

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('wide layout: side panel with header, chips, rows and the '
      'map layers of the fallback anchor', (tester) async {
    final engine = await _pumpScreen(tester);

    // Header row: the title once (the sheet no longer repeats it), the
    // anchor line with its hint, the locate and close buttons.
    expect(find.text('Nearby lines'), findsOneWidget);
    expect(find.text('City center (location unavailable)'), findsOneWidget);
    expect(find.text('Long-press the map to move the pin'), findsOneWidget);
    expect(find.byTooltip('Use my location'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byType(TrufiBottomSheet), findsNothing);
    // The panel insets the flat header like the route detail (12 px):
    // the buttons are not glued to the panel's edges. The panel is
    // 340 px wide under 900 px.
    final menuTopLeft = tester.getTopLeft(
      find.byTooltip('Open navigation menu'),
    );
    expect(menuTopLeft.dx, greaterThanOrEqualTo(12));
    expect(menuTopLeft.dy, greaterThanOrEqualTo(12));
    expect(
      tester.getTopRight(find.byTooltip('Close')).dx,
      lessThanOrEqualTo(340 - 12),
    );
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
    expect(find.text('Highlighted: 201'), findsOneWidget);
    final ids = engine.lastLayers.map((l) => l.id).toList();
    expect(ids, contains('nearby-selected-line'));
    final selected = engine.lastLayers.firstWhere(
      (l) => l.id == 'nearby-selected-line',
    );
    expect(selected.lines.single.position, hasLength(2));
    expect(selected.lines.single.lineWidth, 5);

    await tester.tap(find.textContaining('At 80 m'));
    await tester.pumpAndSettle();
    expect(find.text('Highlighted: 201'), findsNothing);

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
      await tester.tap(find.text(chip));
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
    expect(find.text('City center (location unavailable)'), findsOneWidget);
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

    testWidgets('closing the street visit returns to the caller', (
      tester,
    ) async {
      await _pumpRouted(tester, street: street);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
      expect(find.textContaining('Along Avenida Heroínas'), findsNothing);
    });
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
