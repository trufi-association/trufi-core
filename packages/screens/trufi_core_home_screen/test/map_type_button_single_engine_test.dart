import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show TrufiLocation;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart'
    show SearchLocationsLocalizations;

/// #1021: the map-type button is the only way to the layer toggles (POIs,
/// live buses, app extras). It used to appear only with two or more map
/// engines, so a single-engine app with layers had no way to toggle them.

class _EmptyRepository implements HomeScreenRepository {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> saveFromPlace(TrufiLocation? data) async {}
  @override
  Future<TrufiLocation?> getFromPlace() async => null;
  @override
  Future<void> saveToPlace(TrufiLocation? data) async {}
  @override
  Future<TrufiLocation?> getToPlace() async => null;
  @override
  Future<void> savePlan(routing.Plan? data) async {}
  @override
  Future<routing.Plan?> getPlan() async => null;
  @override
  Future<void> saveSelectedItinerary(routing.Itinerary? data) async {}
  @override
  Future<routing.Itinerary?> getSelectedItinerary() async => null;
  @override
  Future<void> clear() async {}
}

class _NoPlanService implements RequestPlanService {
  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) => throw UnimplementedError();
}

class _FakeEngine extends ITrufiMapEngine {
  _FakeEngine(this.id);
  @override
  final String id;
  @override
  String get name => 'Map $id';
  @override
  String get description => 'Fake map $id';

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

Future<void> _pumpHome(
  WidgetTester tester, {
  required int engines,
  Widget? extras,
}) async {
  final cubit = RoutePlannerCubit(
    repository: _EmptyRepository(),
    requestService: _NoPlanService(),
  );
  addTearDown(cubit.close);
  await cubit.initialize();
  final manager = MapEngineManager(
    engines: [for (var i = 0; i < engines; i++) _FakeEngine('e$i')],
    defaultCenter: const LatLng(-17.39, -66.16),
    defaultZoom: 13,
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MapEngineManager>.value(value: manager),
        BlocProvider<RoutePlannerCubit>.value(value: cubit),
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
          config: HomeScreenConfig(extraMapLayerSettings: extras),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    // HomeScreen starts the location service and the map engine manager
    // reads its preferences: without these mocks the platform-channel
    // futures never complete (the test hangs rather than throws), and
    // pumpAndSettle does not wait for them.
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

  testWidgets('one engine, no layers: no map-type button', (tester) async {
    await _pumpHome(tester, engines: 1);
    expect(find.byIcon(Icons.layers), findsNothing);
  });

  testWidgets('one engine with a layer extra: the button is there and the '
      'sheet shows the extra without a style list', (tester) async {
    await _pumpHome(tester, engines: 1, extras: const Text('layer toggles'));
    expect(find.byIcon(Icons.layers), findsOneWidget);
    expect(
      tester
          .widget<Tooltip>(
            find.ancestor(
              of: find.byIcon(Icons.layers),
              matching: find.byType(Tooltip),
            ),
          )
          .message,
      'Map Settings',
      reason: 'nothing to change with one engine: the sheet is settings',
    );

    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle();
    expect(find.text('layer toggles'), findsOneWidget);
    expect(find.text('Map e0'), findsNothing);
  });

  testWidgets('two engines: unchanged, the button lists both styles', (
    tester,
  ) async {
    await _pumpHome(tester, engines: 2);
    expect(find.byIcon(Icons.layers), findsOneWidget);
    expect(
      tester
          .widget<Tooltip>(
            find.ancestor(
              of: find.byIcon(Icons.layers),
              matching: find.byType(Tooltip),
            ),
          )
          .message,
      'Change map type',
    );
    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle();
    expect(find.text('Map e0'), findsOneWidget);
  });
}
