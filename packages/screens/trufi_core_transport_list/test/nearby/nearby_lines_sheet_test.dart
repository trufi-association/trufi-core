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
          onRetry: () => calls.retries++,
        ),
      ),
    ),
  );
  await tester.pump();
  return calls;
}

/// Short names of the rows that wear the highlight, among the rows on
/// screen (or among every built row with [onScreen] false).
List<String> selectedRows(WidgetTester tester, {bool onScreen = true}) => tester
    .widgetList<NearbyLineTile>(
      find.byType(NearbyLineTile, skipOffstage: onScreen),
    )
    .where((tile) => tile.isSelected)
    .map((tile) => tile.line.displayName)
    .toList();

/// Forty lines 7 m apart, all within 300 m: a list far longer than a phone
/// viewport, so most rows are not built until the list scrolls to them.
List<NearbyLine> manyLines() => [
  for (var i = 0; i < 40; i++)
    NearbyLine(
      lineKey: 'n:L$i',
      routeId: 'r$i',
      patternId: i,
      shortName: 'L$i',
      longName: 'Línea L$i',
      routeType: GtfsRouteType.bus,
      distanceMeters: 10.0 + i * 7,
      kind: NearbyMatchKind.stop,
      stopId: 'S$i',
      stopName: 'Parada $i',
      nearestPoint: const LatLng(-17.3893, -66.15),
    ),
];

/// The sheet on a 360x640 phone, fed from a notifier so a test can emit new
/// states the way the cubit does, with the controller the draggable sheet
/// would pass.
class _ScrollHost {
  _ScrollHost(NearbyLinesState initial) : states = ValueNotifier(initial);

  final ValueNotifier<NearbyLinesState> states;
  final ScrollController controller = ScrollController();
}

Future<_ScrollHost> _pumpScrolling(
  WidgetTester tester,
  NearbyLinesState initial, {
  bool settle = true,
  double bottomInset = 0,
}) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final host = _ScrollHost(initial);
  addTearDown(host.states.dispose);
  addTearDown(host.controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: TransportListLocalizations.localizationsDelegates,
      supportedLocales: TransportListLocalizations.supportedLocales,
      home: Scaffold(
        body: ValueListenableBuilder<NearbyLinesState>(
          valueListenable: host.states,
          // The phone sheet runs under the navigation bar: its MediaQuery
          // keeps the bottom padding.
          builder: (context, state, _) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(padding: EdgeInsets.only(bottom: bottomInset)),
            child: NearbyLinesSheet(
              state: state,
              scrollController: host.controller,
              onRadiusChanged: (_) {},
              onLineTap: (_) {},
              onLineDetails: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  // A loading state spins forever: one frame is all it needs.
  settle ? await tester.pumpAndSettle() : await tester.pump();
  return host;
}

Rect _viewport(WidgetTester tester) =>
    tester.getRect(find.byType(CustomScrollView));

Rect _row(WidgetTester tester, String title) => tester.getRect(
  find.ancestor(of: find.text(title), matching: find.byType(NearbyLineTile)),
);

/// The row is whole inside the list's viewport.
void expectRowWhole(WidgetTester tester, String title) {
  final viewport = _viewport(tester);
  final row = _row(tester, title);
  expect(row.top, greaterThanOrEqualTo(viewport.top - 0.5), reason: title);
  expect(row.bottom, lessThanOrEqualTo(viewport.bottom + 0.5), reason: title);
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

  testWidgets('phone width: a selected row and a long place do not overflow', (
    tester,
  ) async {
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
    // No banner over the list: the row's badge is the only short name.
    expect(find.text('HUAY'), findsOneWidget);
    expect(selectedRows(tester), ['HUAY']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without its header the list starts at the count: the screen '
      'pins the radius pills outside it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates:
            TransportListLocalizations.localizationsDelegates,
        supportedLocales: TransportListLocalizations.supportedLocales,
        home: Scaffold(
          body: NearbyLinesSheet(
            state: state(),
            showHeader: false,
            onRadiusChanged: (_) {},
            onLineTap: (_) {},
            onLineDetails: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(NearbyLinesHeader), findsNothing);
    expect(find.byType(NearbyRadiusPill), findsNothing);
    // The count stays in the list, above the note.
    expect(find.text('2 lines within 300 m'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(RouteCountIndicator)).dy,
      lessThan(
        tester.getTopLeft(find.text('Based on GTFS routes and schedules')).dy,
      ),
    );
    expect(find.byType(NearbyLineTile), findsNWidgets(2));
  });

  testWidgets('a wider radius shows the farther rows', (tester) async {
    await _pumpSheet(tester, state(radius: NearbyRadius.m500));
    expect(find.textContaining('At 380 m'), findsOneWidget);
    expect(find.textContaining('Stop Av. Blanco Galindo'), findsOneWidget);
  });

  testWidgets('tapping a chip reports the radius', (tester) async {
    final calls = await _pumpSheet(tester, state());
    await tapPill(tester, '500 m (3)');
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

  testWidgets('the highlighted line is its row, with no banner over the list; '
      'a tap on it reports the toggle that clears it', (tester) async {
    final calls = await _pumpSheet(tester, state(selectedLineKey: 'n:201'));
    expect(selectedRows(tester), ['201']);
    expect(find.textContaining('Highlighted'), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    // The list opens with the count pill, as without a highlight.
    final count = tester.getTopLeft(find.byType(RouteCountIndicator));
    final firstRow = tester.getTopLeft(find.byType(NearbyLineTile).first);
    expect(count.dy, lessThan(firstRow.dy));

    await tester.tap(find.textContaining('At 80 m'));
    await tester.pump();
    expect(calls.taps.map((l) => l.displayName), ['201']);
  });

  testWidgets('a screen reader hears which row is highlighted', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpSheet(tester, state(selectedLineKey: 'n:X10'));
    expect(
      tester.getSemantics(find.text('Línea X10')),
      isSemantics(isSelected: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.text('Línea 201')),
      isSemantics(
        hasSelectedState: true,
        isSelected: false,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('a highlight beyond the radius gets its row after the others, '
      'with the plain distance, and the count stays the radius\'s', (
    tester,
  ) async {
    await _pumpSheet(tester, state(selectedLineKey: 'n:18'));
    expect(find.text('2 lines within 300 m'), findsOneWidget);
    final tiles = tester
        .widgetList<NearbyLineTile>(find.byType(NearbyLineTile))
        .toList();
    expect(tiles.map((t) => t.line.displayName), ['201', 'X10', '18']);
    expect(tiles.map((t) => t.isInsideRadius), [true, true, false]);
    expect(selectedRows(tester), ['18']);
    expect(
      NearbyLinesSheet.rowsOf(
        state(selectedLineKey: 'n:18'),
      ).map((l) => l.displayName),
      ['201', 'X10', '18'],
    );
    // Within the radius it is just one of the rows.
    expect(
      NearbyLinesSheet.rowsOf(
        state(selectedLineKey: 'n:X10'),
      ).map((l) => l.displayName),
      ['201', 'X10'],
    );
  });

  testWidgets('nothing within the radius but a highlight beyond: the empty '
      'message, then its row', (tester) async {
    await _pumpSheet(
      tester,
      state(
        lines: [rows.last],
        radius: NearbyRadius.m100,
        selectedLineKey: 'n:18',
      ),
    );
    final empty = find.text('No lines within 100 m. Try a larger radius.');
    expect(empty, findsOneWidget);
    expect(find.byType(RouteCountIndicator), findsNothing);
    expect(find.textContaining('At 380 m'), findsOneWidget);
    expect(
      tester.getTopLeft(empty).dy,
      lessThan(tester.getTopLeft(find.byType(NearbyLineTile)).dy),
    );
    expect(selectedRows(tester), ['18']);
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

  group('the list keeps the highlighted row in view', () {
    testWidgets('a highlight set from the map brings in a row the lazy list '
        'had not built, just to the bottom edge', (tester) async {
      final lines = manyLines();
      final host = await _pumpScrolling(tester, state(lines: lines));
      expect(find.text('Línea L30', skipOffstage: false), findsNothing);

      host.states.value = state(lines: lines, selectedLineKey: 'n:L30');
      await tester.pumpAndSettle();
      expectRowWhole(tester, 'Línea L30');
      // Just enough: it came from below, so it rests on the bottom edge.
      expect(
        _row(tester, 'Línea L30').bottom,
        closeTo(_viewport(tester).bottom, 0.5),
      );
      expect(selectedRows(tester), ['L30']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('under a navigation bar the row stops above it, the last '
        'row too', (tester) async {
      final lines = manyLines();
      final host = await _pumpScrolling(
        tester,
        state(lines: lines),
        bottomInset: 48,
      );
      host.states.value = state(lines: lines, selectedLineKey: 'n:L30');
      await tester.pumpAndSettle();
      final clear = _viewport(tester).bottom - 48;
      expect(_row(tester, 'Línea L30').bottom, closeTo(clear, 0.5));

      // The list leaves room under the last row for the bar.
      host.states.value = state(lines: lines, selectedLineKey: 'n:L39');
      await tester.pumpAndSettle();
      expect(_row(tester, 'Línea L39').bottom, closeTo(clear, 0.5));
      expect(
        host.controller.offset,
        lessThan(host.controller.position.maxScrollExtent),
      );

      // A row whole on screen but behind the bar comes up above it: the
      // list is put where L6 ends 10 px above the viewport's bottom edge,
      // inside the 48 px the bar covers.
      host.controller.jumpTo(0);
      await tester.pumpAndSettle();
      host.states.value = state(lines: lines);
      await tester.pumpAndSettle();
      final l6 = tester.getRect(
        find.ancestor(
          of: find.text('Línea L6', skipOffstage: false),
          matching: find.byType(NearbyLineTile, skipOffstage: false),
        ),
      );
      host.controller.jumpTo(l6.bottom - _viewport(tester).bottom + 10);
      await tester.pumpAndSettle();
      final behind = _row(tester, 'Línea L6');
      expect(behind.bottom, greaterThan(clear));
      expect(behind.bottom, lessThanOrEqualTo(_viewport(tester).bottom));
      host.states.value = state(lines: lines, selectedLineKey: 'n:L6');
      await tester.pumpAndSettle();
      expect(_row(tester, 'Línea L6').bottom, closeTo(clear, 0.5));
    });

    testWidgets('a row above the viewport comes down to the top edge', (
      tester,
    ) async {
      final lines = manyLines();
      final host = await _pumpScrolling(
        tester,
        state(lines: lines, selectedLineKey: 'n:L35'),
      );
      expectRowWhole(tester, 'Línea L35');

      host.states.value = state(lines: lines, selectedLineKey: 'n:L3');
      await tester.pumpAndSettle();
      expectRowWhole(tester, 'Línea L3');
      expect(_row(tester, 'Línea L3').top, closeTo(_viewport(tester).top, 0.5));
    });

    testWidgets('a row already whole on screen does not move the list', (
      tester,
    ) async {
      final lines = manyLines();
      final host = await _pumpScrolling(tester, state(lines: lines));
      expectRowWhole(tester, 'Línea L1');

      host.states.value = state(lines: lines, selectedLineKey: 'n:L1');
      await tester.pumpAndSettle();
      expect(host.controller.offset, 0);
      expect(selectedRows(tester), ['L1']);
    });

    testWidgets('a row cut by the bottom edge scrolls just enough to be '
        'whole', (tester) async {
      final lines = manyLines();
      final host = await _pumpScrolling(tester, state(lines: lines));
      final viewport = _viewport(tester);
      // The first row the bottom edge cuts.
      var cut = -1;
      for (var i = 0; i < lines.length; i++) {
        final row = _row(tester, 'Línea L$i');
        if (row.bottom > viewport.bottom) {
          cut = i;
          break;
        }
      }
      expect(cut, greaterThan(0));

      host.states.value = state(lines: lines, selectedLineKey: 'n:L$cut');
      await tester.pumpAndSettle();
      expectRowWhole(tester, 'Línea L$cut');
      expect(host.controller.offset, greaterThan(0));
      expect(host.controller.offset, lessThan(100));
    });

    testWidgets('a radius change keeps the scroll: the rider is at the pills', (
      tester,
    ) async {
      final lines = manyLines();
      final host = await _pumpScrolling(
        tester,
        state(lines: lines, selectedLineKey: 'n:L30'),
      );
      host.controller.jumpTo(0);
      await tester.pumpAndSettle();

      host.states.value = state(
        lines: lines,
        radius: NearbyRadius.m500,
        selectedLineKey: 'n:L30',
      );
      await tester.pumpAndSettle();
      expect(host.controller.offset, 0);
    });

    testWidgets('new rows that keep the highlight (a moved pin, a revisit) '
        'bring it back into view', (tester) async {
      final host = await _pumpScrolling(
        tester,
        state(lines: manyLines(), selectedLineKey: 'n:L30'),
      );
      host.controller.jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.text('Línea L30'), findsNothing);

      // What the cubit emits for a new query: loading, then the rows (a
      // state equal to the current one is never emitted).
      host.states.value = state(
        lines: host.states.value.lines,
        isLoading: true,
        selectedLineKey: 'n:L30',
      );
      await tester.pump();
      host.states.value = state(lines: manyLines(), selectedLineKey: 'n:L30');
      await tester.pumpAndSettle();
      expectRowWhole(tester, 'Línea L30');
    });

    testWidgets('a list built with a highlight (a revisit, the phone and '
        'side-panel swap) opens on it', (tester) async {
      await _pumpScrolling(
        tester,
        state(lines: manyLines(), selectedLineKey: 'n:L33'),
      );
      expectRowWhole(tester, 'Línea L33');
    });

    testWidgets('a list built while the query runs reveals the row once it '
        'arrives', (tester) async {
      final host = await _pumpScrolling(
        tester,
        state(lines: const [], isLoading: true, selectedLineKey: 'n:L33'),
        settle: false,
      );
      host.states.value = state(lines: manyLines(), selectedLineKey: 'n:L33');
      await tester.pumpAndSettle();
      expectRowWhole(tester, 'Línea L33');
    });

    testWidgets('back from a screen pushed on top (a line\'s detail), the '
        'list returns to the highlighted row', (tester) async {
      final host = await _pumpScrolling(
        tester,
        state(lines: manyLines(), selectedLineKey: 'n:L30'),
      );
      // The rider scrolls up and opens another line's detail.
      host.controller.jumpTo(0);
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
      await tester.pumpAndSettle();
      expect(host.controller.offset, 0);

      navigator.pop();
      await tester.pumpAndSettle();
      expectRowWhole(tester, 'Línea L30');
    });

    testWidgets('clearing the highlight leaves the list where it is', (
      tester,
    ) async {
      final lines = manyLines();
      final host = await _pumpScrolling(
        tester,
        state(lines: lines, selectedLineKey: 'n:L30'),
      );
      final offset = host.controller.offset;
      expect(offset, greaterThan(0));

      host.states.value = state(lines: lines);
      await tester.pumpAndSettle();
      expect(host.controller.offset, offset);
      expect(selectedRows(tester, onScreen: false), isEmpty);
    });

    testWidgets('a drag by the rider during a reveal wins: the list stays '
        'where the rider takes it', (tester) async {
      final lines = manyLines();
      final host = await _pumpScrolling(tester, state(lines: lines));
      host.states.value = state(lines: lines, selectedLineKey: 'n:L30');
      // The reveal starts its hop toward the row, not built yet.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      // The rider grabs the list and pulls it back toward the pills.
      final gesture = await tester.startGesture(const Offset(180, 300));
      for (var i = 0; i < 25; i++) {
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(host.controller.offset, 0);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(host.controller.offset, 0);
      expect(find.text('Línea L30'), findsNothing);
    });

    testWidgets('a list too short for the row shows the row\'s top (the '
        'sheet at its min snap, over a navigation bar)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final lines = manyLines();
      final states = ValueNotifier(state(lines: lines));
      addTearDown(states.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates:
              TransportListLocalizations.localizationsDelegates,
          supportedLocales: TransportListLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 66,
                child: ValueListenableBuilder<NearbyLinesState>(
                  valueListenable: states,
                  builder: (context, s, _) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(padding: const EdgeInsets.only(bottom: 48)),
                    child: NearbyLinesSheet(
                      state: s,
                      onRadiusChanged: (_) {},
                      onLineTap: (_) {},
                      onLineDetails: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // A row the list has built (inside its cache extent), then one it
      // has to hop to: both rest with their top on the top edge.
      for (final key in ['L1', 'L10']) {
        states.value = state(lines: lines, selectedLineKey: 'n:$key');
        await tester.pumpAndSettle();
        expect(
          _row(tester, 'Línea $key').top,
          closeTo(_viewport(tester).top, 0.5),
          reason: key,
        );
      }
    });

    testWidgets('a highlight beyond the radius scrolls to its row at the '
        'end', (tester) async {
      final lines = [
        ...manyLines(),
        const NearbyLine(
          lineKey: 'n:far',
          routeId: 'far',
          patternId: 0,
          shortName: 'FAR',
          longName: 'Línea lejana',
          routeType: GtfsRouteType.bus,
          distanceMeters: 450,
          kind: NearbyMatchKind.stop,
          stopId: 'F1',
          stopName: 'Lejos',
          nearestPoint: LatLng(-17.386, -66.15),
        ),
      ];
      final host = await _pumpScrolling(tester, state(lines: lines));
      host.states.value = state(lines: lines, selectedLineKey: 'n:far');
      await tester.pumpAndSettle();
      expectRowWhole(tester, 'Línea lejana');
      expect(
        tester
            .widget<NearbyLineTile>(
              find.ancestor(
                of: find.text('Línea lejana'),
                matching: find.byType(NearbyLineTile),
              ),
            )
            .isInsideRadius,
        isFalse,
      );
    });
  });
}
