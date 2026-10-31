import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show AppConfiguration, TrufiLocation;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart'
    show SearchLocationsLocalizations;

/// #1057 (trufi-sanaa#18): a feed whose "stops" are OSM way nodes placed
/// along each line has nothing worth listing under a leg. `showStops: false`
/// drops the "`N` stops" toggle and the list behind it from the itinerary
/// detail; the default keeps them. The knob lives in [HomeScreenConfig] and
/// has to reach the inline detail through the real [HomeScreen], in both
/// layouts.
void main() {
  final day = DateTime(2026, 10, 30, 9);

  routing.Place place(String name) =>
      routing.Place(name: name, lat: 15.35, lon: 44.20, stopId: name);

  const origin = LatLng(15.2952, 44.2623);
  const boarding = LatLng(15.2990, 44.2580);
  const alighting = LatLng(15.3500, 44.1830);

  routing.Leg leg({
    required String mode,
    required List<LatLng> points,
    required int startMinute,
    required int minutes,
  }) => routing.Leg(
    mode: mode,
    startTime: day.add(Duration(minutes: startMinute)),
    endTime: day.add(Duration(minutes: startMinute + minutes)),
    duration: Duration(minutes: minutes),
    distance: minutes * 150.0,
    transitLeg: mode != 'WALK',
    encodedPoints: routing.PolylineCodec.encode(points),
    decodedPoints: points,
  );

  final walk = leg(
    mode: 'WALK',
    points: [origin, boarding],
    startMinute: 0,
    minutes: 4,
  ).copyWith(fromPlace: place('Origin'), toPlace: place('Boarding stop'));

  // 44 synthetic way nodes between the terminals, like a Sana'a line.
  final bus =
      leg(
        mode: 'BUS',
        points: [boarding, alighting],
        startMinute: 4,
        minutes: 30,
      ).copyWith(
        route: routing.Route(gtfsId: '1:7', shortName: '7', longName: 'Line 7'),
        shortName: '7',
        routeLongName: 'Line 7',
        fromPlace: place('Boarding stop'),
        toPlace: place('Alighting stop'),
        intermediatePlaces: [
          for (var i = 1; i <= 44; i++) place('Way node $i'),
        ],
        agency: routing.Agency(gtfsId: 'a1', name: 'Sanaa Transit'),
      );

  final itinerary = routing.Itinerary(
    legs: [walk, bus],
    startTime: day,
    endTime: day.add(const Duration(minutes: 34)),
    walkTime: const Duration(minutes: 4),
    duration: const Duration(minutes: 34),
    walkDistance: 300,
  );

  final stopCount = find.text('44 stops');
  final expandIcon = find.byIcon(Icons.expand_more_rounded);
  final collapseIcon = find.byIcon(Icons.expand_less_rounded);
  final firstNode = find.text('Way node 1');

  /// With the stops hidden the leg is still a leg: line, terminals and
  /// operator stay (the duration and the walk row are in the same column).
  void expectLegStillDescribed() {
    expect(find.text('Line 7'), findsOneWidget);
    expect(find.text('Boarding stop'), findsOneWidget);
    expect(find.text('Alighting stop'), findsOneWidget);
    expect(find.text('Operated by Sanaa Transit'), findsOneWidget);
    expect(find.textContaining('Walk'), findsOneWidget);
  }

  void expectNoStopRows() {
    expect(stopCount, findsNothing);
    expect(find.textContaining('stops'), findsNothing);
    expect(expandIcon, findsNothing);
    expect(collapseIcon, findsNothing);
    expect(firstNode, findsNothing);
  }

  Widget host(Widget body) => Provider<AppConfiguration?>.value(
    value: AppConfiguration(appName: 'Test', screens: const []),
    child: MaterialApp(
      localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
      supportedLocales: HomeScreenLocalizations.supportedLocales,
      home: body,
    ),
  );

  group('ItineraryDetailContent.showStops', () {
    testWidgets('default: the leg counts its stops and unfolds them on tap '
        '(unchanged)', (tester) async {
      await tester.pumpWidget(
        host(Scaffold(body: ItineraryDetailContent(itinerary: itinerary))),
      );
      await tester.pumpAndSettle();

      expect(stopCount, findsOneWidget);
      expect(expandIcon, findsOneWidget);
      expect(firstNode, findsNothing);
      expectLegStillDescribed();

      await tester.tap(stopCount);
      await tester.pumpAndSettle();
      expect(firstNode, findsOneWidget);
      expect(find.text('Way node 44'), findsOneWidget);
      expect(collapseIcon, findsOneWidget);
    });

    testWidgets('false: no count, no toggle, no list; the leg is still '
        'described', (tester) async {
      await tester.pumpWidget(
        host(
          Scaffold(
            body: ItineraryDetailContent(
              itinerary: itinerary,
              showStops: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expectNoStopRows();
      expectLegStillDescribed();
    });

    testWidgets('the full-screen ItineraryDetailScreen takes the same knob', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(ItineraryDetailScreen(itinerary: itinerary)),
      );
      await tester.pumpAndSettle();
      expect(stopCount, findsOneWidget);

      await tester.pumpWidget(
        host(ItineraryDetailScreen(itinerary: itinerary, showStops: false)),
      );
      await tester.pumpAndSettle();
      expectNoStopRows();
      expect(find.text('Line 7'), findsOneWidget);
    });
  });

  group('HomeScreenConfig.showStops reaches the inline detail', () {
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

    const from = TrufiLocation(
      description: 'Origin',
      latitude: 15.2952,
      longitude: 44.2623,
    );
    const to = TrufiLocation(
      description: 'University',
      latitude: 15.3536,
      longitude: 44.1787,
    );

    Future<RoutePlannerCubit> planCubit() async {
      final cubit = RoutePlannerCubit(
        repository: _MemoryRepository(),
        requestService: _FakePlanService(
          routing.Plan(itineraries: [itinerary]),
        ),
      );
      addTearDown(cubit.close);
      await cubit.setFromPlace(from);
      await cubit.setToPlace(to);
      await cubit.fetchPlan();
      expect(cubit.state.plan?.itineraries, hasLength(1));
      return cubit;
    }

    /// The real [HomeScreen] over a fake map engine: [phone] is the
    /// 1080×2424 @ 2.625 narrow layout (results in the bottom sheet), the
    /// default test surface is the wide layout (results in the side panel).
    Future<void> pumpHome(
      WidgetTester tester, {
      required HomeScreenConfig config,
      required bool phone,
    }) async {
      if (phone) {
        tester.view.physicalSize = const Size(1080, 2424);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }
      final cubit = await planCubit();
      final manager = MapEngineManager(
        engines: [_FakeEngine()],
        defaultCenter: const LatLng(15.347, 44.205),
        defaultZoom: 14,
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
            home: HomeScreen(onMenuPressed: () {}, config: config),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// A tap on the result card opens the inline detail in place.
    Future<void> openInlineDetail(WidgetTester tester) async {
      await tester.tap(find.byType(ItineraryCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(ItineraryDetailContent), findsOneWidget);
    }

    testWidgets('phone layout (results sheet): showStops false hides the '
        'rows', (tester) async {
      await pumpHome(
        tester,
        config: const HomeScreenConfig(showStops: false),
        phone: true,
      );
      await openInlineDetail(tester);

      expectNoStopRows();
      expect(find.text('Line 7'), findsOneWidget);
      expect(find.text('Alighting stop'), findsOneWidget);
    });

    testWidgets('wide layout (side panel): showStops false hides the rows', (
      tester,
    ) async {
      await pumpHome(
        tester,
        config: const HomeScreenConfig(showStops: false),
        phone: false,
      );
      await openInlineDetail(tester);

      expectNoStopRows();
      expect(find.text('Line 7'), findsOneWidget);
    });

    testWidgets('the default config keeps the stop rows (unchanged)', (
      tester,
    ) async {
      await pumpHome(tester, config: const HomeScreenConfig(), phone: true);
      await openInlineDetail(tester);

      expect(stopCount, findsOneWidget);
      expect(expandIcon, findsOneWidget);
    });
  });
}

/// A map engine that draws nothing but attaches a delegate, so the home
/// screen's camera fit lands somewhere instead of being retried every frame
/// (which keeps `pumpAndSettle` from ever settling).
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
  }) => _FakeMap(controller: controller, camera: camera ?? initialCamera);
}

class _FakeMap extends StatefulWidget {
  const _FakeMap({required this.controller, required this.camera});
  final TrufiMapController? controller;
  final TrufiCameraPosition camera;

  @override
  State<_FakeMap> createState() => _FakeMapState();
}

class _FakeMapState extends State<_FakeMap> implements TrufiMapDelegate {
  late TrufiCameraPosition _camera = widget.camera;

  @override
  void initState() {
    super.initState();
    widget.controller?.attach(this);
  }

  @override
  void dispose() {
    widget.controller?.detach(this);
    super.dispose();
  }

  @override
  TrufiCameraPosition get cameraPosition => _camera;
  @override
  void moveCamera(TrufiCameraPosition position) => _camera = position;
  @override
  void fitBounds(
    LatLngBounds bounds, {
    EdgeInsets padding = EdgeInsets.zero,
    double minZoom = 2.0,
    double maxZoom = 20.0,
  }) {}
  @override
  List<TrufiMarker> pickMarkersAt(
    LatLng tap, {
    double hitboxPx = 24.0,
    int? perLayerLimit,
    int? globalLimit,
  }) => const [];

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class _MemoryRepository implements HomeScreenRepository {
  TrufiLocation? from;
  TrufiLocation? to;
  routing.Plan? plan;
  routing.Itinerary? selected;

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
    from = null;
    to = null;
    plan = null;
    selected = null;
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
