import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show TrufiLocation, VehicleEtaProvider;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart'
    show SearchLocationsLocalizations;

import 'support/vehicle_eta_fakes.dart';

/// #1018: the live ETA badges (#1004) follow the SELECTED routing engine.
/// An engine with telemetry (OTP 2.8 over GTFS-RT) shows them; switching to
/// one without (offline planner, OTP 1.5) hides them and switching back asks
/// the new engine again. The config's provider stays as a legacy override
/// for apps that wire one source for every engine. Drives the real
/// [HomeScreen] with a restored plan over fakes.
class _Engine extends routing.IRoutingProvider {
  _Engine(this.id, this.plan, {this.eta});
  @override
  final String id;
  final routing.Plan plan;
  final VehicleEtaProvider? eta;

  @override
  String get name => id;
  @override
  String get description => 'Fake $id';
  @override
  bool get supportsTransitRoutes => true;
  @override
  bool get requiresInternet => false;
  @override
  VehicleEtaProvider? get vehicleEtaProvider => eta;

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

/// walk → bus 7: the badge of route 7 is what the engines decide about.
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
  _Harness({this.override}) {
    engines = routing.RoutingEngineManager(
      engines: [
        _Engine('otp', plan, eta: otpEta),
        _Engine('offline', plan),
      ],
    );
  }

  final VehicleEtaProvider? override;
  final plan = _plan();
  final otpEta = FakeVehicleEtaProvider()..answer = (_) => [eta('1:7', 240)];
  late final routing.RoutingEngineManager engines;
  late final etaCubit = VehicleEtaCubit(provider: override, now: () => etaT0);

  void select(String id) => engines.setEngineById(id);
}

Future<_Harness> _pumpRestoredHome(
  WidgetTester tester, {
  FakeVehicleEtaProvider? override,
}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final h = _Harness(override: override);
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
          config: HomeScreenConfig(vehicleEtaProvider: override),
        ),
      ),
    ),
  );
  await _settle(tester);
  return h;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

  testWidgets('the badge follows the selected engine: shown with telemetry, '
      'hidden without, asked again on the way back', (tester) async {
    final h = await _pumpRestoredHome(tester);

    expect(h.etaCubit.provider, same(h.otpEta));
    expect(h.otpEta.calls, 1, reason: 'the restored plan asked OTP once');
    expect(find.text('Arrives in ~4 min'), findsOneWidget);

    h.select('offline');
    await _settle(tester);
    expect(h.etaCubit.provider, isNull);
    expect(find.text('Arrives in ~4 min'), findsNothing);
    expect(
      tester.widget<EtaBadge>(find.byType(EtaBadge)).status,
      VehicleEtaStatus.idle,
      reason: 'idle paints nothing: the badge is hidden, not "unavailable"',
    );
    expect(h.otpEta.calls, 1, reason: 'no source: nothing was asked');

    h.select('otp');
    await _settle(tester);
    expect(h.otpEta.calls, 2, reason: 'back on OTP: the plan is asked again');
    expect(find.text('Arrives in ~4 min'), findsOneWidget);
  });

  testWidgets('the config provider is a legacy override for every engine', (
    tester,
  ) async {
    final override = FakeVehicleEtaProvider()
      ..answer = (_) => [eta('1:7', 120)];
    final h = await _pumpRestoredHome(tester, override: override);

    expect(override.calls, 1);
    expect(h.otpEta.calls, 0, reason: 'the override wins over the engine');
    expect(find.text('Arrives in ~2 min'), findsOneWidget);

    h.select('offline');
    await _settle(tester);
    expect(h.etaCubit.provider, same(override));
    expect(override.calls, 1, reason: 'same source: no new request');
    expect(find.text('Arrives in ~2 min'), findsOneWidget);
  });
}
