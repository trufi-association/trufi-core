import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsRouteType;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart'
    show RouteBadge;
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

const anchor = LatLng(-17.39, -66.15);

const rows = [
  NearbyLine(
    lineKey: 'n:201',
    routeId: 'a',
    patternId: 0,
    shortName: '201',
    longName: 'Línea 201',
    routeType: GtfsRouteType.bus,
    distanceMeters: 80,
    kind: NearbyMatchKind.stop,
    stopId: 'A1',
    stopName: 'Calle San Simón',
    nearestPoint: LatLng(-17.3893, -66.15),
  ),
  NearbyLine(
    lineKey: 'n:X10',
    routeId: 'b',
    patternId: 1,
    shortName: 'X10',
    longName: 'Línea X10',
    headsign: 'Av. Humberto Asin',
    routeType: GtfsRouteType.bus,
    distanceMeters: 133,
    kind: NearbyMatchKind.passes,
    nearestPoint: LatLng(-17.3888, -66.15),
  ),
  NearbyLine(
    lineKey: 'n:18',
    routeId: 'c',
    patternId: 2,
    shortName: '18',
    longName: 'Línea 18',
    routeType: GtfsRouteType.bus,
    distanceMeters: 380,
    kind: NearbyMatchKind.stop,
    stopId: 'C1',
    stopName: 'Av. Blanco Galindo',
    nearestPoint: LatLng(-17.3866, -66.15),
  ),
];

const counts = {
  NearbyRadius.m100: 1,
  NearbyRadius.m300: 2,
  NearbyRadius.m500: 3,
};

NearbyLinesState state({
  List<NearbyLine> lines = rows,
  NearbyRadius radius = NearbyRadius.m300,
  NearbyAvailability availability = NearbyAvailability.available,
  String? selectedLineKey,
  bool isLoading = false,
  String? errorMessage,
}) => NearbyLinesState(
  anchor: anchor,
  anchorSource: NearbyAnchorSource.device,
  radius: radius,
  availability: availability,
  lines: lines,
  counts: counts,
  selectedLineKey: selectedLineKey,
  isLoading: isLoading,
  errorMessage: errorMessage,
);

class _Calls {
  final radii = <NearbyRadius>[];
  final taps = <NearbyLine>[];
  final details = <NearbyLine>[];
  int clears = 0;
  int retries = 0;
}

Future<_Calls> _pumpSheet(WidgetTester tester, NearbyLinesState state) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: TransportListLocalizations.localizationsDelegates,
      supportedLocales: TransportListLocalizations.supportedLocales,
      home: Scaffold(
        body: NearbyLinesSheet(
          state: state,
          onRadiusChanged: calls.radii.add,
          onLineTap: calls.taps.add,
          onLineDetails: calls.details.add,
          onClearSelection: () => calls.clears++,
          onRetry: () => calls.retries++,
        ),
      ),
    ),
  );
  await tester.pump();
  return calls;
}

void main() {
  testWidgets('chips carry cumulative counts and rows follow the radius', (
    tester,
  ) async {
    await _pumpSheet(tester, state());

    // The screen title lives in the floating header; the sheet opens with
    // the count pill and the radius pills.
    expect(find.text('Nearby lines'), findsNothing);
    expect(find.text('2 lines within 300 m'), findsOneWidget);
    expect(find.byType(NearbyRadiusPill), findsNWidgets(3));
    expect(find.text('100 m (1)'), findsOneWidget);
    expect(find.text('300 m (2)'), findsOneWidget);
    expect(find.text('500 m (3)'), findsOneWidget);

    // Each row: badge (mode icon + short name), the line's name as title,
    // the walk and the place as subtitle.
    expect(find.byType(RouteBadge), findsNWidgets(2));
    expect(find.byIcon(Icons.directions_bus), findsNWidgets(2));
    expect(find.text('201'), findsOneWidget);
    expect(find.text('Línea 201'), findsOneWidget);
    expect(find.textContaining('At 80 m'), findsOneWidget);
    expect(find.textContaining('Stop Calle San Simón'), findsOneWidget);
    expect(find.text('Línea X10'), findsOneWidget);
    expect(find.textContaining('Passes by at 133 m'), findsOneWidget);
    expect(find.textContaining('To Av. Humberto Asin'), findsOneWidget);
    expect(find.textContaining('At 380 m'), findsNothing);
    expect(find.text('Based on GTFS routes and schedules'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a passing line without headsign shows the walk alone', (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      state(
        lines: const [
          NearbyLine(
            lineKey: 'n:7',
            routeId: 'd',
            patternId: 0,
            shortName: '7',
            longName: 'Línea 7',
            routeType: GtfsRouteType.tram,
            distanceMeters: 40,
            kind: NearbyMatchKind.passes,
            nearestPoint: LatLng(-17.3893, -66.15),
          ),
        ],
      ),
    );
    expect(find.text('Línea 7'), findsOneWidget);
    expect(find.textContaining('Passes by at 40 m'), findsOneWidget);
    expect(find.textContaining(' · '), findsNothing);
    expect(find.byIcon(Icons.tram), findsOneWidget);
    expect(find.text('1 line within 300 m'), findsOneWidget);
  });

  testWidgets('phone width: a selected row, a long place and the chip do '
      'not overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpSheet(
      tester,
      state(
        lines: [
          rows.first,
          const NearbyLine(
            lineKey: 'n:huay',
            routeId: 'e',
            patternId: 0,
            shortName: 'HUAY',
            longName: 'Asociación Mixta de Transporte Huayñacota',
            headsign: 'Plaza 14 de Septiembre → Hospital Viedma',
            routeType: GtfsRouteType.bus,
            distanceMeters: 120,
            kind: NearbyMatchKind.passes,
            nearestPoint: LatLng(-17.3888, -66.15),
          ),
        ],
        selectedLineKey: 'n:huay',
      ),
    );
    expect(find.byTooltip('Clear highlight'), findsOneWidget);
    expect(find.text('Highlighted: HUAY'), findsOneWidget);
    // The chip's avatar and the row's badge both carry the short name.
    expect(find.text('HUAY'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a wider radius shows the farther rows', (tester) async {
    await _pumpSheet(tester, state(radius: NearbyRadius.m500));
    expect(find.textContaining('At 380 m'), findsOneWidget);
    expect(find.textContaining('Stop Av. Blanco Galindo'), findsOneWidget);
  });

  testWidgets('tapping a chip reports the radius', (tester) async {
    final calls = await _pumpSheet(tester, state());
    await tester.tap(find.text('500 m (3)'));
    await tester.pump();
    expect(calls.radii, [NearbyRadius.m500]);
  });

  testWidgets('tapping a row toggles it, the chevron opens the detail', (
    tester,
  ) async {
    final calls = await _pumpSheet(tester, state());
    await tester.tap(find.textContaining('At 80 m'));
    await tester.pump();
    expect(calls.taps.map((l) => l.displayName), ['201']);
    expect(calls.details, isEmpty);

    await tester.tap(find.byTooltip('Line details').first);
    await tester.pump();
    expect(calls.details.map((l) => l.displayName), ['201']);
  });

  testWidgets('the highlighted line gets a banner whose × clears it', (
    tester,
  ) async {
    final calls = await _pumpSheet(tester, state(selectedLineKey: 'n:201'));
    expect(find.text('Highlighted: 201'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear highlight'));
    await tester.pump();
    expect(calls.clears, 1);
  });

  testWidgets('no line within 500 m shows the empty state and the pin hint', (
    tester,
  ) async {
    await _pumpSheet(tester, state(lines: const []));
    expect(find.text('No lines pass within 500 m'), findsOneWidget);
    expect(find.text('Long-press the map to move the pin'), findsOneWidget);
    expect(find.byType(NearbyRadiusPill), findsNWidgets(3));
    expect(find.byType(RouteCountIndicator), findsNothing);
  });

  testWidgets('lines beyond the selected radius only: suggest widening', (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      state(lines: [rows.last], radius: NearbyRadius.m100),
    );
    expect(
      find.text('No lines within 100 m. Try a larger radius.'),
      findsOneWidget,
    );
    expect(find.textContaining('At 380 m'), findsNothing);
  });

  testWidgets('no offline planner: explanation, no chips', (tester) async {
    await _pumpSheet(
      tester,
      state(lines: const [], availability: NearbyAvailability.missing),
    );
    expect(
      find.text('Nearby lines need the offline GTFS planner'),
      findsOneWidget,
    );
    expect(find.textContaining('TrufiPlannerProvider'), findsOneWidget);
    expect(find.byType(NearbyRadiusPill), findsNothing);
  });

  testWidgets('loading the feed shows the offline-data message', (
    tester,
  ) async {
    await _pumpSheet(
      tester,
      state(
        lines: const [],
        availability: NearbyAvailability.loading,
        isLoading: true,
      ),
    );
    expect(find.text('Loading offline data…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a query error is reported with its message and a retry', (
    tester,
  ) async {
    final calls = await _pumpSheet(
      tester,
      state(lines: const [], errorMessage: 'boom'),
    );
    expect(find.text('Could not load routes'), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(calls.retries, 1);
  });

  testWidgets('Spanish copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates:
            TransportListLocalizations.localizationsDelegates,
        supportedLocales: TransportListLocalizations.supportedLocales,
        home: Scaffold(
          body: NearbyLinesSheet(
            state: state(),
            onRadiusChanged: (_) {},
            onLineTap: (_) {},
            onLineDetails: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('2 líneas a 300 m'), findsOneWidget);
    expect(find.textContaining('A 80 m'), findsOneWidget);
    expect(find.textContaining('Parada Calle San Simón'), findsOneWidget);
    expect(find.textContaining('Pasa a 133 m'), findsOneWidget);
    expect(find.textContaining('Hacia Av. Humberto Asin'), findsOneWidget);
    expect(find.text('Basado en rutas y horarios GTFS'), findsOneWidget);
  });
}
