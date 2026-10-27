import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart'
    show TrufiBottomSheet;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// trufi-sanaa#18: a feed whose stops are synthetic (the GTFS builder
/// invents one every 100 m along the shape) must be able to keep them out
/// of the route detail. `showStops: false` drops the timeline sheet / side
/// panel list, the stop count and the map dots; the line, its end pins, the
/// route identity, distance and mode stay. Drives the real
/// [TransportDetailScreen] over a fake map engine that records the layers
/// it is handed, both ways.
class _FakeEngine extends ITrufiMapEngine {
  List<TrufiLayer> lastLayers = const [];

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
    return const SizedBox.expand();
  }
}

/// Minimal list provider so the `/routes/:id` sub-route can be built
/// without a `RoutingEngineManager`.
class _FakeProvider extends TransportListDataProvider {
  @override
  Future<void> load() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<TransportRouteDetails?> getRouteDetails(String code) async => null;
}

const _stops = [
  TransportStop(
    id: 's1',
    name: 'Parada Central',
    latitude: -17.39,
    longitude: -66.15,
  ),
  // Bab al-Yemen, Sana'a.
  TransportStop(
    id: 's2',
    name: 'محطة باب اليمن',
    latitude: -17.395,
    longitude: -66.155,
  ),
  TransportStop(
    id: 's3',
    name: 'Parada Final',
    latitude: -17.40,
    longitude: -66.16,
  ),
];

/// The shape's ends deliberately differ from the first/last stop, so a
/// test can tell which of the two the terminal pins come from.
const _geometry = [
  (latitude: -17.389, longitude: -66.149),
  (latitude: -17.395, longitude: -66.155),
  (latitude: -17.401, longitude: -66.161),
];

TransportRouteDetails _details({String? longName}) => TransportRouteDetails(
  id: 'r1',
  code: 'A1',
  name: 'Linea A',
  shortName: 'A',
  longName: longName,
  stops: _stops,
  geometry: _geometry,
  modeName: 'Bus',
);

const _phone = Size(400, 800);

Future<_FakeEngine> _pumpDetail(
  WidgetTester tester, {
  required bool showStops,
  String? longName = 'Terminal Norte → Plaza Principal',
  Size? size,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final engine = _FakeEngine();
  final manager = MapEngineManager(
    engines: [engine],
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
          getRouteDetails: (_) async => _details(longName: longName),
          showStops: showStops,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return engine;
}

Iterable<TrufiMarker> _markers(_FakeEngine engine) =>
    engine.lastLayers.expand((layer) => layer.markers);

TrufiMarker _marker(_FakeEngine engine, String id) =>
    _markers(engine).firstWhere((marker) => marker.id == id);

Iterable<String> _stopDotIds(_FakeEngine engine) =>
    _markers(engine).map((m) => m.id).where((id) => id.startsWith('stop-'));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('default (showStops: true)', () {
    testWidgets('phone: the stops sheet, the count, the names and the map '
        'dots are all there', (tester) async {
      final engine = await _pumpDetail(tester, showStops: true, size: _phone);

      expect(find.byType(TrufiBottomSheet), findsOneWidget);
      // Stat label + section label.
      expect(find.text('Stops'), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('محطة باب اليمن'), findsWidgets);
      // Terminals are the first/last stop, not the long name.
      expect(find.text('Parada Central'), findsWidgets);
      expect(find.text('Terminal Norte'), findsNothing);

      expect(_stopDotIds(engine), ['stop-1']);
      expect(
        _marker(engine, 'origin-marker').position,
        const LatLng(-17.39, -66.15),
        reason: 'the origin pin sits on the first stop',
      );
      expect(
        _marker(engine, 'destination-marker').position,
        const LatLng(-17.40, -66.16),
      );
      expect(engine.lastLayers.single.lines.single.id, 'route-line');
    });

    testWidgets('wide: the side panel lists the stops with their count', (
      tester,
    ) async {
      // The default 800×600 surface is the wide layout (≥ 600 px).
      final engine = await _pumpDetail(tester, showStops: true);

      expect(find.text('Stops'), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('محطة باب اليمن'), findsOneWidget);
      expect(_stopDotIds(engine), ['stop-1']);
    });
  });

  group('showStops: false', () {
    testWidgets('phone: no sheet, no "Stops", no names, no dots; the line, '
        'its end pins and the summary stay', (tester) async {
      final engine = await _pumpDetail(tester, showStops: false, size: _phone);

      expect(find.byType(TrufiBottomSheet), findsNothing);
      expect(find.text('Stops'), findsNothing);
      expect(find.text('3'), findsNothing);
      for (final stop in _stops) {
        expect(find.text(stop.name), findsNothing, reason: stop.name);
      }
      // The summary card: terminals from the long name, distance, mode.
      expect(find.text('Terminal Norte'), findsOneWidget);
      expect(find.text('Plaza Principal'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Mode'), findsOneWidget);
      expect(find.text('Bus'), findsOneWidget);

      expect(_stopDotIds(engine), isEmpty);
      expect(
        _markers(engine).map((m) => m.id),
        unorderedEquals(['origin-marker', 'destination-marker']),
      );
      expect(
        _marker(engine, 'origin-marker').position,
        const LatLng(-17.389, -66.149),
        reason: 'the origin pin sits on the shape, not on the first stop',
      );
      expect(
        _marker(engine, 'destination-marker').position,
        const LatLng(-17.401, -66.161),
      );
      expect(engine.lastLayers.single.lines.single.position, hasLength(3));
    });

    testWidgets('phone, long name without "A → B" (Sana\'a uses "⟵"): no '
        'terminal labels at all — the stop names never fill in', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        showStops: false,
        longName: 'الحثيلي ⟵ باب اليمن',
        size: _phone,
      );

      // The identity in the top bar is the whole long name.
      expect(find.text('الحثيلي ⟵ باب اليمن'), findsOneWidget);
      for (final stop in _stops) {
        expect(find.text(stop.name), findsNothing, reason: stop.name);
      }
      expect(find.byType(TrufiBottomSheet), findsNothing);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Mode'), findsOneWidget);
    });

    testWidgets('wide: the side panel keeps identity and stats and drops '
        'the stops section', (tester) async {
      final engine = await _pumpDetail(tester, showStops: false);

      expect(find.text('Stops'), findsNothing);
      expect(find.text('3'), findsNothing);
      for (final stop in _stops) {
        expect(find.text(stop.name), findsNothing, reason: stop.name);
      }
      expect(find.text('Terminal Norte'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Mode'), findsOneWidget);
      expect(_stopDotIds(engine), isEmpty);
      expect(
        _marker(engine, 'origin-marker').position,
        const LatLng(-17.389, -66.149),
      );
    });
  });

  testWidgets('TransportListTrufiScreen forwards showStops to /routes/:id', (
    tester,
  ) async {
    Future<TransportDetailScreen> detailOf(
      TransportListTrufiScreen screen,
    ) async {
      late Widget built;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              built = screen.subRoutes.single.builder(context, {'id': 'A1'});
              return const SizedBox();
            },
          ),
        ),
      );
      return built as TransportDetailScreen;
    }

    final byDefault = await detailOf(
      TransportListTrufiScreen(dataProviderBuilder: (_) => _FakeProvider()),
    );
    expect(byDefault.showStops, isTrue);

    final hidden = await detailOf(
      TransportListTrufiScreen(
        dataProviderBuilder: (_) => _FakeProvider(),
        showStops: false,
      ),
    );
    expect(hidden.showStops, isFalse);
  });
}
