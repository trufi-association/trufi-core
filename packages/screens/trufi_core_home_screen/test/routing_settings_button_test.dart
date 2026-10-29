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

/// trufi-sanaa#23: the route-settings (tune) button of the search bar only
/// earns its place when the sheet it opens has something to act on — an
/// engine selector (several engines) or the current engine's preferences.
/// An offline-only app on the local Trufi planner has neither.

class _FakeProvider extends routing.IRoutingProvider {
  _FakeProvider(this.id, {this.configurable = false});

  @override
  final String id;
  final bool configurable;

  @override
  String get name => 'Engine $id';
  @override
  String get description => 'Fake engine $id';
  @override
  bool get supportsTransitRoutes => false;
  @override
  bool get requiresInternet => false;

  @override
  bool get hasConfigurablePreferences => configurable;

  /// The non-configurable shape is the local Trufi planner's: a panel that
  /// is not null but only informs, so the home has to read the flag and not
  /// `buildPreferencesUI != null`.
  @override
  Widget? buildPreferencesUI(BuildContext context) => configurable
      ? const Text('fake preferences form')
      : const Text('fake info panel');

  @override
  Future<routing.Plan> fetchPlan({
    required routing.RoutingLocation from,
    required routing.RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async => routing.Plan(itineraries: []);

  @override
  Future<List<routing.TransitRoute>> fetchTransitRoutes() async => [];

  @override
  Future<routing.TransitRoute?> fetchTransitRouteById(String id) async => null;
}

class _FakePlanService implements RequestPlanService {
  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async => routing.Plan(itineraries: []);
}

/// No platform view: the controller no-ops while nothing is attached.
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

Future<void> _pumpHome(
  WidgetTester tester, {
  required List<routing.IRoutingProvider>? engines,
  bool phone = true,
}) async {
  if (phone) {
    // 1080×2424 @ 2.625: the narrow layout; the default 800×600 is the
    // wide one (side panel), which has its own copy of the search bar.
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final cubit = RoutePlannerCubit(requestService: _FakePlanService());
  addTearDown(cubit.close);
  final maps = MapEngineManager(
    engines: [_FakeMapEngine()],
    defaultCenter: const LatLng(15.3470, 44.2050),
    defaultZoom: 14,
  );
  await tester.pumpWidget(
    MultiProvider(
      // A fresh key per pump: a second pump in the same test would otherwise
      // reuse the provider elements, and `create` would not run again.
      key: UniqueKey(),
      providers: [
        ChangeNotifierProvider<MapEngineManager>.value(value: maps),
        if (engines != null)
          ChangeNotifierProvider<routing.RoutingEngineManager>(
            create: (_) => routing.RoutingEngineManager(engines: engines),
          ),
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
          config: const HomeScreenConfig(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _tuneButton => find.byIcon(Icons.tune_rounded);
Finder get _swapButton => find.byIcon(Icons.swap_vert_rounded);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // LocationService's auto-start asks geolocator whether the service is
    // enabled; without a plugin that call would throw. Answer "no".
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

  group('route-settings button (trufi-sanaa#23)', () {
    testWidgets(
      'a single engine with nothing to configure: no button, swap stays',
      (tester) async {
        await _pumpHome(tester, engines: [_FakeProvider('local')]);

        expect(_tuneButton, findsNothing);
        expect(_swapButton, findsOneWidget);
      },
    );

    testWidgets('a single engine with preferences keeps the button, and the '
        'sheet shows its form without an engine selector', (tester) async {
      await _pumpHome(
        tester,
        engines: [_FakeProvider('otp', configurable: true)],
      );

      expect(_tuneButton, findsOneWidget);
      await tester.tap(_tuneButton);
      await tester.pumpAndSettle();

      expect(find.text('Route Settings'), findsOneWidget);
      expect(find.text('fake preferences form'), findsOneWidget);
      expect(find.text('Routing Provider'), findsNothing);
    });

    testWidgets('several engines keep the button even when none has '
        'preferences: the sheet is where the user switches', (tester) async {
      await _pumpHome(
        tester,
        engines: [_FakeProvider('local'), _FakeProvider('remote')],
      );

      expect(_tuneButton, findsOneWidget);
      await tester.tap(_tuneButton);
      await tester.pumpAndSettle();

      expect(find.text('Routing Provider'), findsOneWidget);
      expect(find.text('fake preferences form'), findsNothing);
      // The current engine's informational panel is still part of the sheet.
      expect(find.text('fake info panel'), findsOneWidget);
    });

    testWidgets('the wide layout follows the same rule', (tester) async {
      await _pumpHome(tester, engines: [_FakeProvider('local')], phone: false);
      expect(_tuneButton, findsNothing);
      expect(_swapButton, findsOneWidget);

      await _pumpHome(
        tester,
        engines: [_FakeProvider('otp', configurable: true)],
        phone: false,
      );
      expect(_tuneButton, findsOneWidget);
    });

    testWidgets('without a RoutingEngineManager there is no button either '
        '(the sheet could not be built)', (tester) async {
      await _pumpHome(tester, engines: null);

      expect(_tuneButton, findsNothing);
      expect(_swapButton, findsOneWidget);
    });
  });
}
