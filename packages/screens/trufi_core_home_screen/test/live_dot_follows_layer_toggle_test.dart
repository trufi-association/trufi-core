import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show
        RealtimeVehiclesProvider,
        TrufiLatLng,
        TrufiLocation,
        VehicleEtaProvider,
        VehicleEtaRequest,
        VehicleEtaSnapshot,
        VehiclePosition;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart'
    show LiveBusBadge;
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart'
    show SearchLocationsLocalizations;

import 'support/vehicle_eta_fakes.dart';

/// #1004 review: `OtpVehiclePositionsProvider.fetchOnce` feeds `latest` and
/// `positionsStream` while the "Live buses" layer is off, so the first ETA
/// snapshot used to light the pulsing "live" dot on the route chips — and
/// leave it frozen until the next plan, contradicting the toggle. The dot now
/// follows the toggle: off → no dot (the ETA badge still shows), on → dot and
/// poller. Drives the real [HomeScreen] with a restored plan over fakes.

/// Realtime provider the ETA source feeds on demand, like
/// `RealtimeVehiclesEtaProvider(snapshotLoader: fetchOnce)` does.
class _FakeRealtime implements RealtimeVehiclesProvider {
  final _controller = StreamController<List<VehiclePosition>>.broadcast();
  List<VehiclePosition> _latest = const [];
  int startCalls = 0;

  void feed(List<VehiclePosition> positions) {
    _latest = positions;
    _controller.add(positions);
  }

  @override
  List<VehiclePosition> get latest => _latest;
  @override
  Stream<List<VehiclePosition>> get positionsStream => _controller.stream;
  @override
  Future<void> start() async => startCalls++;
  @override
  void stop() {}
  Future<void> dispose() => _controller.close();
}

/// Each ETA request takes a fleet snapshot (a bus on route 7) and answers
/// for it — the on-demand path of #1004 with the live layer off.
class _SnapshotEtaProvider implements VehicleEtaProvider {
  _SnapshotEtaProvider(this.realtime);
  final _FakeRealtime realtime;
  int calls = 0;

  @override
  Future<VehicleEtaSnapshot> fetchEtas(VehicleEtaRequest request) async {
    calls++;
    realtime.feed([
      VehiclePosition(
        vehicleId: 'bus-7',
        position: const TrufiLatLng(-17.3900, -66.1500),
        routeId: '1:7',
      ),
    ]);
    return VehicleEtaSnapshot(etas: [eta('1:7', 240)], fetchedAt: etaT0);
  }
}

class _FakeRoutingEngine extends routing.IRoutingProvider {
  _FakeRoutingEngine(this.plan, this.realtime);
  final routing.Plan plan;
  final _FakeRealtime realtime;

  @override
  String get id => 'fake';
  @override
  String get name => 'Fake';
  @override
  String get description => 'Fake routing';
  @override
  bool get supportsTransitRoutes => true;
  @override
  bool get requiresInternet => false;
  @override
  RealtimeVehiclesProvider? get realtimeVehiclesProvider => realtime;

  @override
  Future<routing.Plan> fetchPlan({
    required routing.RoutingLocation from,
    required routing.RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async => plan;
  @override
  Future<List<routing.TransitRoute>> fetchTransitRoutes() async => const [];
  @override
  Future<routing.TransitRoute?> fetchTransitRouteById(String id) async => null;
}

class _MemoryRepository implements HomeScreenRepository {
  routing.Plan? plan;
  routing.Itinerary? selected;
  TrufiLocation? from;
  TrufiLocation? to;

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> saveFromPlace(TrufiLocation? data) async => from = data;
  @override
  Future<TrufiLocation?> getFromPlace() async => from;
  @override
  Future<void> saveToPlace(TrufiLocation? data) async => to = data;
  @override
  Future<TrufiLocation?> getToPlace() async => to;
  @override
  Future<void> savePlan(routing.Plan? data) async => plan = data;
  @override
  Future<routing.Plan?> getPlan() async => plan;
  @override
  Future<void> saveSelectedItinerary(routing.Itinerary? data) async =>
      selected = data;
  @override
  Future<routing.Itinerary?> getSelectedItinerary() async => selected;
  @override
  Future<void> clear() async {
    plan = null;
    selected = null;
    from = null;
    to = null;
  }
}

class _FakePlanService implements RequestPlanService {
  _FakePlanService(this.plan);
  final routing.Plan plan;

  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async => plan;
}

class _FakeMapEngine extends ITrufiMapEngine {
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

/// walk → bus 7: the chip of route 7 is where the live dot would show.
routing.Plan _plan() => routing.Plan(
  itineraries: [
    itinerary([walkLeg(), busLeg('7')]),
  ],
);

const _from = TrufiLocation(
  description: 'Origen',
  latitude: -17.3936,
  longitude: -66.1570,
);
const _to = TrufiLocation(
  description: 'Destino',
  latitude: -17.3700,
  longitude: -66.1400,
);

class _Harness {
  final realtime = _FakeRealtime();
  late final etaProvider = _SnapshotEtaProvider(realtime);
  late final plan = _plan();
  late final engines = routing.RoutingEngineManager(
    engines: [_FakeRoutingEngine(plan, realtime)],
  );
  late final etaCubit = VehicleEtaCubit(
    provider: etaProvider,
    now: () => etaT0,
  );
}

Future<_Harness> _pumpRestoredHome(WidgetTester tester) async {
  // Phone layout: results in the bottom sheet.
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final h = _Harness();
  addTearDown(h.realtime.dispose);
  addTearDown(h.etaCubit.close);
  final repository = _MemoryRepository()
    ..plan = h.plan
    ..selected = h.plan.itineraries!.single
    ..from = _from
    ..to = _to;
  final cubit = RoutePlannerCubit(
    repository: repository,
    requestService: _FakePlanService(h.plan),
  );
  addTearDown(cubit.close);
  await cubit.initialize();
  expect(cubit.state.plan, isNotNull, reason: 'the plan must be restored');

  final maps = MapEngineManager(
    engines: [_FakeMapEngine()],
    defaultCenter: const LatLng(-17.3936, -66.1570),
    defaultZoom: 14,
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MapEngineManager>.value(value: maps),
        ChangeNotifierProvider<routing.RoutingEngineManager>.value(
          value: h.engines,
        ),
        BlocProvider<RoutePlannerCubit>.value(value: cubit),
        BlocProvider<VehicleEtaCubit>.value(value: h.etaCubit),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          ...HomeScreenLocalizations.localizationsDelegates,
          MapsLocalizations.delegate,
          SearchLocationsLocalizations.delegate,
          routing.RoutingLocalizations.delegate,
        ],
        supportedLocales: HomeScreenLocalizations.supportedLocales,
        home: HomeScreen(
          onMenuPressed: () {},
          config: HomeScreenConfig(vehicleEtaProvider: h.etaProvider),
        ),
      ),
    ),
  );
  // No pumpAndSettle: a visible LiveBusBadge pulses forever. A few frames
  // cover the post-frame ETA sync, the prefs restore and the sheet.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  return h;
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (call) async => false,
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          null,
        );
  });

  testWidgets('live layer off: the ETA snapshot shows the badge but no live '
      'dot and no poller', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final h = await _pumpRestoredHome(tester);

    expect(h.etaProvider.calls, 1, reason: 'the restored plan asked once');
    expect(
      h.realtime.latest,
      isNotEmpty,
      reason: 'the on-demand snapshot did feed the realtime provider',
    );
    expect(find.text('Arrives in ~4 min'), findsOneWidget);
    expect(
      find.byType(LiveBusBadge),
      findsNothing,
      reason:
          'with the layer off a snapshot taken for the badges must not '
          'light the "live" dot on the 7 chip',
    );
    expect(h.realtime.startCalls, 0, reason: 'layer off: no polling');
  });

  testWidgets('live layer on: the dot shows on the chip and the poller runs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'trufi_live_vehicles_enabled': true,
    });
    final h = await _pumpRestoredHome(tester);

    expect(find.text('Arrives in ~4 min'), findsOneWidget);
    expect(find.byType(LiveBusBadge), findsWidgets);
    expect(h.realtime.startCalls, 1);
  });
}
