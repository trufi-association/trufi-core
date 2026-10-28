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
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// trufi-sanaa#20: the home screen hands its `onLinesAlongStreet` to the
/// search screen it opens, so the "Lines along <street>" row shows inside a
/// street's corners list with the handler, and does not without it. Drives
/// the real [HomeScreen] over a fake map and a search service that knows one
/// street with two corners.
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

class _NullRepository implements HomeScreenRepository {
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

class _NeverPlanService implements RequestPlanService {
  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) => throw StateError('no plan is requested in this test');
}

const _street = SearchLocation(
  id: 'street:s1',
  displayName: 'Avenida Ayacucho',
  address: 'Cercado',
  latitude: -17.3925,
  longitude: -66.1588,
);
const _corners = [
  SearchLocation(
    id: 'junction:s1:s3',
    displayName: 'Avenida Ayacucho & Avenida Aroma',
    latitude: -17.3907,
    longitude: -66.1571,
  ),
  SearchLocation(
    id: 'junction:s1:s2',
    displayName: 'Avenida Ayacucho & Avenida Heroínas',
    latitude: -17.3927,
    longitude: -66.1587,
  ),
];

class _DrillDownService
    with SearchLocationDrillDown
    implements SearchLocationService {
  @override
  Future<List<SearchLocation>> search(String query) async => [_street];
  @override
  bool canDrillDown(SearchLocation location) => location.id == _street.id;
  @override
  Future<List<SearchLocation>> drillDown(SearchLocation location) async =>
      _corners;
  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async =>
      null;
  @override
  void dispose() {}
}

Future<void> _pumpHome(
  WidgetTester tester, {
  LinesAlongStreetCallback? onLinesAlongStreet,
}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final manager = MapEngineManager(
    engines: [_FakeEngine()],
    defaultCenter: const LatLng(-17.39, -66.15),
  );
  final planner = RoutePlannerCubit(
    repository: _NullRepository(),
    requestService: _NeverPlanService(),
  );
  addTearDown(planner.close);
  await planner.initialize();
  final search = SearchLocationsCubit(
    searchLocationService: _DrillDownService(),
  );
  addTearDown(search.close);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MapEngineManager>.value(value: manager),
        BlocProvider<RoutePlannerCubit>.value(value: planner),
        BlocProvider<SearchLocationsCubit>.value(value: search),
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
          onLinesAlongStreet: onLinesAlongStreet,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Origin field → search screen → the street → its corners list.
  await tester.tap(find.text('Select origin'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, 'ayacucho');
  // Debounce (300 ms) + the async search.
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Avenida Ayacucho'));
  await tester.pumpAndSettle();
  expect(find.text('& Avenida Aroma'), findsOneWidget);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // LocationService's auto-start asks geolocator whether the service is
    // enabled; without a plugin that call would hang the test. Answer "no".
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

  testWidgets('the handler given to HomeScreen reaches the corners list and '
      'receives the street with every corner', (tester) async {
    SearchLocation? street;
    List<SearchLocation>? corners;
    await _pumpHome(
      tester,
      onLinesAlongStreet: (_, s, c) {
        street = s;
        corners = c;
      },
    );

    await tester.tap(find.text('Lines along Avenida Ayacucho'));
    await tester.pumpAndSettle();

    expect(street, _street);
    expect(corners, _corners);
    // Nothing was picked: the search screen is still open on the corners.
    expect(find.text('& Avenida Heroínas'), findsOneWidget);
  });

  testWidgets('without a handler the corners list has no such row', (
    tester,
  ) async {
    await _pumpHome(tester);

    expect(find.textContaining('Lines along'), findsNothing);
  });
}
