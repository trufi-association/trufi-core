import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// trufi-lima#3: on a phone with a system navigation bar, scrolling the
/// route detail's stops sheet to the end left the last stop (the terminal
/// card) under the bar, unreachable. The list must end with the bottom
/// system inset as extra room. Drives the real [TransportDetailScreen] on a
/// 400x800 phone with a 48 px navigation bar, both with and without it.
class _FakeEngine extends ITrufiMapEngine {
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
  }) => const SizedBox.expand();
}

const _stopCount = 30;
const _lastStopName = 'Parada 30';

final _stops = [
  for (var i = 1; i <= _stopCount; i++)
    TransportStop(
      id: 's$i',
      name: 'Parada $i',
      latitude: -17.39 - i * 0.001,
      longitude: -66.15,
    ),
];

final _details = TransportRouteDetails(
  id: 'r1',
  code: 'A1',
  name: 'Linea A',
  shortName: 'A',
  stops: _stops,
  geometry: [
    for (final s in _stops) (latitude: s.latitude, longitude: s.longitude),
  ],
  modeName: 'Bus',
);

const _screenHeight = 800.0;

Future<void> _pump(WidgetTester tester, {required double navBar}) async {
  tester.view.physicalSize = const Size(400, _screenHeight);
  tester.view.devicePixelRatio = 1.0;
  tester.view.viewPadding = FakeViewPadding(bottom: navBar);
  tester.view.padding = FakeViewPadding(bottom: navBar);
  addTearDown(tester.view.reset);

  final manager = MapEngineManager(
    engines: [_FakeEngine()],
    defaultCenter: const LatLng(-17.39, -66.15),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider<MapEngineManager>.value(
      value: manager,
      child: MaterialApp(
        localizationsDelegates:
            TransportListLocalizations.localizationsDelegates,
        supportedLocales: TransportListLocalizations.supportedLocales,
        home: TransportDetailScreen(
          routeCode: 'A1',
          getRouteDetails: (_) async => _details,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the sheet fully, then scrolls its list to the very end.
Future<void> _scrollStopsToEnd(WidgetTester tester) async {
  final list = find.byType(CustomScrollView);
  expect(list, findsOneWidget);
  for (var i = 0; i < 25; i++) {
    await tester.drag(list, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
}

double _lastStopBottom(WidgetTester tester) {
  // The pinned header also shows the end stop's name; take the list's.
  final name = find.descendant(
    of: find.byType(SliverList),
    matching: find.text(_lastStopName),
  );
  expect(name, findsOneWidget, reason: 'the last stop is built at the end');
  final card = find.ancestor(of: name, matching: find.byType(InkWell));
  return tester.getRect(card.first).bottom;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('with a 48 px navigation bar the last stop ends above it', (
    tester,
  ) async {
    await _pump(tester, navBar: 48);
    await _scrollStopsToEnd(tester);

    expect(
      _lastStopBottom(tester),
      lessThanOrEqualTo(_screenHeight - 48),
      reason: 'the last stop must be scrollable clear of the system bar',
    );
  });

  testWidgets('without a navigation bar the last stop still reaches the '
      'bottom edge (no extra gap invented)', (tester) async {
    await _pump(tester, navBar: 0);
    await _scrollStopsToEnd(tester);

    final bottom = _lastStopBottom(tester);
    expect(bottom, lessThanOrEqualTo(_screenHeight));
    expect(
      bottom,
      greaterThan(_screenHeight - 48),
      reason: 'no inset, so no bar-sized room below the last stop',
    );
  });
}
