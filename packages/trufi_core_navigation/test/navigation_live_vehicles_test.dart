import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
// The navigation package takes `trufi_core_interfaces` for this feature; the
// test only needs the vehicle types the screen is handed.
// ignore: depend_on_referenced_packages
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show RealtimeVehiclesProvider, TrufiLatLng, VehiclePosition;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'support/navigation_fixtures.dart';

/// trufi-lima#10: in navigation mode no live bus was ever drawn (the layer
/// only knew the route and the rider). With a live-vehicles source the screen
/// draws the buses of the ride leg's route, the rider's own and the ones ahead
/// included (`liveVehiclesOnTrip`; the home's boarding-stop filter of
/// trufi-lima#7 does not apply while riding); without one nothing changes.
/// Driven through `NavigationScreen.showFromItinerary`, the call an app
/// makes, over a map engine that records the layers it is handed.
class _FakeRealtime implements RealtimeVehiclesProvider {
  _FakeRealtime(this._latest);
  List<VehiclePosition> _latest;
  final _controller = StreamController<List<VehiclePosition>>.broadcast();

  void feed(List<VehiclePosition> positions) {
    _latest = positions;
    _controller.add(positions);
  }

  @override
  List<VehiclePosition> get latest => _latest;
  @override
  Stream<List<VehiclePosition>> get positionsStream => _controller.stream;
  @override
  Future<void> start() async {}
  @override
  void stop() {}
}

class _RecordingEngine extends ITrufiMapEngine {
  List<TrufiLayer> layers = const [];

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
    this.layers = layers;
    return const SizedBox.expand();
  }
}

class _RecordingMapManager extends Fake implements MapEngineManager {
  final engine = _RecordingEngine();
  @override
  ITrufiMapEngine get currentEngine => engine;
}

class _NoWakelock extends WakelockPlusMacOSPlugin {
  @override
  Future<void> toggle({required bool enable}) async {}
  @override
  Future<bool> get enabled async => false;
}

void main() {
  final realWakelock = wakelockPlusPlatformInstance;
  setUp(() => wakelockPlusPlatformInstance = _NoWakelock());
  tearDown(() => wakelockPlusPlatformInstance = realWakelock);

  // Boarding stop of line 7 (the ride leg of the Sana'a-like trip).
  const boarding = SanaaTrip.boarding;

  VehiclePosition bus(
    String id,
    String route, {
    required double heading,
    double lon = 44.195,
  }) => VehiclePosition(
    vehicleId: id,
    position: TrufiLatLng(boarding.latitude, lon),
    routeId: route,
    heading: heading,
    speed: 8,
  );

  // ~500 m west of the boarding stop, driving east (towards it) or west.
  final comingOn7 = bus('coming', '1:7', heading: 90);
  final leavingOn7 = bus('leaving', '1:7', heading: 270);
  final otherLine = bus('other', '1:99', heading: 90);

  Future<_RecordingMapManager> startNavigation(
    WidgetTester tester, {
    RealtimeVehiclesProvider? liveVehicles,
    routing.Itinerary? itinerary,
  }) async {
    final maps = _RecordingMapManager();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: NavigationLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => NavigationScreen.showFromItinerary(
                context,
                itinerary: itinerary ?? SanaaTrip.itinerary(),
                locationService: FakeLocationService(initial: SanaaTrip.origin),
                mapEngineManager: maps,
                liveVehicles: liveVehicles,
              ),
              child: const Text('Start'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    return maps;
  }

  List<String> drawnVehicles(_RecordingMapManager maps) => [
    for (final layer in maps.engine.layers)
      for (final marker in layer.markers)
        if (marker.id.startsWith('vehicle-')) marker.id,
  ];

  testWidgets('with a source: the buses of the leg\'s route are drawn, '
      'wherever they head', (tester) async {
    final realtime = _FakeRealtime([comingOn7, leavingOn7, otherLine]);
    final maps = await startNavigation(tester, liveVehicles: realtime);

    expect(drawnVehicles(maps), ['vehicle-coming', 'vehicle-leaving']);
  });

  testWidgets('a known opposite direction is not drawn, an unknown one is', (
    tester,
  ) async {
    final base = SanaaTrip.itinerary();
    final withDirection = SanaaTrip.itineraryOf([
      for (final leg in base.legs)
        leg.transitLeg ? leg.copyWith(directionId: 0) : leg,
    ]);
    final realtime = _FakeRealtime([
      comingOn7.copyWith(vehicleId: 'same', directionId: 0),
      comingOn7.copyWith(vehicleId: 'opposite', directionId: 1),
      comingOn7.copyWith(vehicleId: 'unknown'),
    ]);

    final maps = await startNavigation(
      tester,
      liveVehicles: realtime,
      itinerary: withDirection,
    );

    expect(drawnVehicles(maps), ['vehicle-same', 'vehicle-unknown']);
  });

  testWidgets('a later snapshot redraws the buses', (tester) async {
    final realtime = _FakeRealtime(const []);
    final maps = await startNavigation(tester, liveVehicles: realtime);
    expect(drawnVehicles(maps), isEmpty);

    realtime.feed([comingOn7, otherLine]);
    await tester.pumpAndSettle();

    expect(drawnVehicles(maps), ['vehicle-coming']);
  });

  testWidgets('a source with no bus of the route draws none', (tester) async {
    final maps = await startNavigation(
      tester,
      liveVehicles: _FakeRealtime([otherLine]),
    );

    expect(drawnVehicles(maps), isEmpty);
  });

  testWidgets('without a source no bus is drawn (today\'s behaviour)', (
    tester,
  ) async {
    final maps = await startNavigation(tester);

    expect(maps.engine.layers, isNotEmpty, reason: 'the route is drawn');
    expect(drawnVehicles(maps), isEmpty);
  });
}
