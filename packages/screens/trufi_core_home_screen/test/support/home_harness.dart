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

/// Shared pieces to drive the real [HomeScreen] over a fake map engine
/// (copied in shape from `restored_plan_map_test.dart`): a repository that
/// keeps nothing, a plan service that fails or answers on demand, a map that
/// records every camera move, and a geolocator that reports a fix.

const homeFrom = TrufiLocation(
  description: 'Origen',
  latitude: -12.0464,
  longitude: -77.0428,
);
const homeTo = TrufiLocation(
  description: 'Destino',
  latitude: -12.1000,
  longitude: -77.0000,
);

class MemoryHomeRepository implements HomeScreenRepository {
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

/// Throws [failure] while it is set, otherwise answers [plan]; counts calls.
class ScriptedPlanService implements RequestPlanService {
  ScriptedPlanService({this.failure, this.plan});
  Object? failure;
  routing.Plan? plan;
  int calls = 0;

  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async {
    calls++;
    final error = failure;
    if (error != null) throw error;
    return plan!;
  }
}

/// Every call the screen makes on the map's controller.
class MapMoves {
  final List<TrufiCameraPosition> moves = [];
  final List<LatLngBounds> fits = [];

  /// The map's own camera report, as when the user pans it.
  ValueChanged<TrufiCameraPosition>? onCameraChanged;
}

class _RecordingEngine extends ITrufiMapEngine {
  _RecordingEngine(this.moves);
  final MapMoves moves;

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
    moves.onCameraChanged = onCameraChanged;
    return _RecordingMap(controller: controller, moves: moves);
  }
}

class _RecordingMap extends StatefulWidget {
  const _RecordingMap({required this.controller, required this.moves});
  final TrufiMapController? controller;
  final MapMoves moves;

  @override
  State<_RecordingMap> createState() => _RecordingMapState();
}

class _RecordingMapState extends State<_RecordingMap>
    implements TrufiMapDelegate {
  TrufiCameraPosition _camera = const TrufiCameraPosition(
    target: LatLng(0, 0),
    zoom: 1,
  );

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
  void moveCamera(TrufiCameraPosition position) {
    _camera = position;
    widget.moves.moves.add(position);
  }

  @override
  void fitBounds(
    LatLngBounds bounds, {
    EdgeInsets padding = EdgeInsets.zero,
    double minZoom = 2.0,
    double maxZoom = 20.0,
  }) => widget.moves.fits.add(bounds);

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

/// Geolocator answering "service on, permission granted, here is [fix]", so
/// the location service auto-starts tracking and the my-location button
/// takes the real path.
void mockGeolocatorWithFix(LatLng fix) {
  final position = <String, dynamic>{
    'latitude': fix.latitude,
    'longitude': fix.longitude,
    'timestamp': DateTime(2026, 11, 26, 12).millisecondsSinceEpoch,
    'accuracy': 5.0,
    'altitude': 0.0,
    'altitude_accuracy': 0.0,
    'heading': 0.0,
    'heading_accuracy': 0.0,
    'speed': 0.0,
    'speed_accuracy': 0.0,
    'is_mocked': true,
  };
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/geolocator'),
    (call) async {
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return true;
        case 'checkPermission':
        case 'requestPermission':
          return 3; // LocationPermission.always
        case 'getLastKnownPosition':
        case 'getCurrentPosition':
          return position;
        case 'getLocationAccuracy':
          return 0;
      }
      return null;
    },
  );
  const updates = EventChannel('flutter.baseflow.com/geolocator_updates');
  messenger.setMockStreamHandler(
    updates,
    MockStreamHandler.inline(
      onListen: (args, events) => events.success(position),
      onCancel: (args) {},
    ),
  );
  addTearDown(() => messenger.setMockStreamHandler(updates, null));
}

/// What the tests that pump the home need before anything else: empty prefs
/// and a geolocator that answers "service off" (no auto-start tracking).
void installHomeTestDefaults() {
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
}

/// Pumps the real [HomeScreen] (phone size) and returns what it does to the
/// map.
Future<MapMoves> pumpHome(
  WidgetTester tester,
  RoutePlannerCubit cubit, {
  HomeScreenConfig config = const HomeScreenConfig(),
  LatLng defaultCenter = const LatLng(-12.0464, -77.0428),
  double defaultZoom = 14,
}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final moves = MapMoves();
  final manager = MapEngineManager(
    engines: [_RecordingEngine(moves)],
    defaultCenter: defaultCenter,
    defaultZoom: defaultZoom,
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
  return moves;
}
