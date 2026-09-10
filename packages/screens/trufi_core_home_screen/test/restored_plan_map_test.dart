import 'dart:async';
import 'dart:convert';

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

/// #995: a plan restored from the previous session has to reach the map the
/// way a fresh one does — route layers AND a fitted camera — although the
/// restore completes before the map has reported any camera. Drives the real
/// [HomeScreen] over a fake map engine that records what it is handed.

// Sana'a: the app's default viewport vs the university trip (trufi-sanaa#2),
// which lies entirely outside that viewport.
const _defaultCenter = LatLng(15.3470, 44.2050);
const _defaultZoom = 14.0;
const _origin = LatLng(15.2952334, 44.2623529);
const _boarding = LatLng(15.2990, 44.2580);
const _transfer = LatLng(15.3150, 44.2250);
const _alighting = LatLng(15.3500, 44.1830);
const _destination = LatLng(15.3536032, 44.1786948);

routing.Place _place(String id, LatLng p) =>
    routing.Place(name: id, lat: p.latitude, lon: p.longitude, stopId: id);

routing.Leg _leg(
  List<LatLng> points, {
  String? route,
  required int startMinute,
  required int minutes,
}) {
  final start = DateTime(2026, 9, 10, 12, startMinute);
  return routing.Leg(
    mode: route == null ? 'WALK' : 'BUS',
    startTime: start,
    endTime: start.add(Duration(minutes: minutes)),
    duration: Duration(minutes: minutes),
    distance: 1000,
    transitLeg: route != null,
    encodedPoints: routing.PolylineCodec.encode(points),
    decodedPoints: points,
    route: route == null
        ? null
        : routing.Route(gtfsId: route, shortName: route),
    shortName: route,
    fromPlace: _place('from-$startMinute', points.first),
    toPlace: _place('to-$startMinute', points.last),
  );
}

/// walk → bus [first] → bus [second] → walk (the "7 → 14, 57 min" trip of the
/// report; other route names give an alternative over the same stops).
routing.Itinerary _universityItinerary({
  String first = '7',
  String second = '14',
}) => routing.Itinerary(
  legs: [
    _leg([_origin, _boarding], startMinute: 0, minutes: 5),
    _leg([_boarding, _transfer], route: first, startMinute: 5, minutes: 20),
    _leg([_transfer, _alighting], route: second, startMinute: 25, minutes: 27),
    _leg([_alighting, _destination], startMinute: 52, minutes: 5),
  ],
  startTime: DateTime(2026, 9, 10, 12),
  endTime: DateTime(2026, 9, 10, 12, 57),
  walkTime: const Duration(minutes: 10),
  duration: const Duration(minutes: 57),
  walkDistance: 833,
);

routing.Plan _universityPlan({bool withAlternative = false}) => routing.Plan(
  itineraries: [
    _universityItinerary(),
    if (withAlternative) _universityItinerary(first: '9', second: '21'),
  ],
);

const _from = TrufiLocation(
  description: 'Origen',
  latitude: 15.2952334,
  longitude: 44.2623529,
);
const _to = TrufiLocation(
  description: 'Universidad',
  latitude: 15.3536032,
  longitude: 44.1786948,
);

/// Stores JSON like [HomeScreenRepositoryImpl] does, so the restored plan
/// went through the same round trip as on a device. [gate] lets a test hold
/// the restore until after the home screen's first frame.
class _JsonRepository implements HomeScreenRepository {
  String? planJson;
  String? selectedJson;
  TrufiLocation? from;
  TrufiLocation? to;
  Completer<void>? gate;

  void seed(routing.Plan plan) {
    planJson = jsonEncode(plan.toJson());
    selectedJson = jsonEncode(plan.itineraries!.first.toJson());
    from = _from;
    to = _to;
  }

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
  Future<void> savePlan(routing.Plan? data) async =>
      planJson = data == null ? null : jsonEncode(data.toJson());
  @override
  Future<routing.Plan?> getPlan() async {
    await gate?.future;
    return planJson == null
        ? null
        : routing.Plan.fromJson(jsonDecode(planJson!) as Map<String, dynamic>);
  }

  @override
  Future<void> saveSelectedItinerary(routing.Itinerary? data) async =>
      selectedJson = data == null ? null : jsonEncode(data.toJson());
  @override
  Future<routing.Itinerary?> getSelectedItinerary() async =>
      selectedJson == null
      ? null
      : routing.Itinerary.fromJson(
          jsonDecode(selectedJson!) as Map<String, dynamic>,
        );
  @override
  Future<void> clear() async {
    planJson = null;
    selectedJson = null;
    from = null;
    to = null;
  }
}

class _FakePlanService implements RequestPlanService {
  _FakePlanService(this.plan);
  final routing.Plan plan;
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
    return plan;
  }
}

/// What the home screen handed to the map on its latest build, plus a way to
/// play the map's own camera report (the moment the real map becomes "ready"
/// from the screen's point of view).
class _MapCalls {
  List<TrufiLayer> layers = const [];
  TrufiCameraPosition? camera;
  TrufiCameraPosition? initialCamera;
  ValueChanged<TrufiCameraPosition>? _onCameraChanged;
  int reports = 0;

  TrufiLayer? layer(String id) {
    final hits = layers.where((l) => l.id == id).toList();
    return hits.isEmpty ? null : hits.single;
  }

  void report(TrufiCameraPosition position) {
    reports++;
    _onCameraChanged?.call(position);
  }
}

class _FakeEngine extends ITrufiMapEngine {
  _FakeEngine(this.calls);
  final _MapCalls calls;

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
    calls.layers = layers;
    calls.camera = camera;
    calls.initialCamera = initialCamera;
    calls._onCameraChanged = onCameraChanged;
    return _FakeMap(
      controller: controller,
      initialCamera: initialCamera,
      camera: camera,
    );
  }
}

/// Mirrors TrufiMap's controller lifecycle and keeps the controlled camera
/// it was last given, like the real map does until its style has loaded.
class _FakeMap extends StatefulWidget {
  const _FakeMap({
    required this.controller,
    required this.initialCamera,
    required this.camera,
  });
  final TrufiMapController? controller;
  final TrufiCameraPosition initialCamera;
  final TrufiCameraPosition? camera;

  @override
  State<_FakeMap> createState() => _FakeMapState();
}

class _FakeMapState extends State<_FakeMap> implements TrufiMapDelegate {
  late TrufiCameraPosition _camera;

  @override
  void initState() {
    super.initState();
    _camera = widget.camera ?? widget.initialCamera;
    widget.controller?.attach(this);
  }

  @override
  void didUpdateWidget(_FakeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.camera != null && widget.camera != _camera) {
      _camera = widget.camera!;
    }
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

Future<_MapCalls> _pumpHome(
  WidgetTester tester,
  RoutePlannerCubit cubit, {
  bool phone = true,
}) async {
  if (phone) {
    // The report's device: 1080×2424 @ 2.625 → narrow layout, bottom sheet.
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final calls = _MapCalls();
  final manager = MapEngineManager(
    engines: [_FakeEngine(calls)],
    defaultCenter: _defaultCenter,
    defaultZoom: _defaultZoom,
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
          config: const HomeScreenConfig(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return calls;
}

void _expectRouteDrawnAndFitted(_MapCalls calls) {
  final lines = calls.layer('route-lines-layer');
  expect(lines, isNotNull, reason: 'the itinerary polyline layer is missing');
  expect(lines!.lines, hasLength(4), reason: 'one line per leg');

  final markers = calls.layer('route-markers-layer');
  expect(markers, isNotNull, reason: 'the route markers layer is missing');
  expect(
    markers!.markers.map((m) => m.id),
    containsAll([
      'start-marker',
      'end-marker',
      'transit-label-1',
      'transit-label-2',
      'boarding-1',
      'alighting-2',
    ]),
  );
  expect(
    calls.layer('location-markers-layer'),
    isNull,
    reason: 'origin/destination previews give way to the route markers',
  );

  final camera = calls.camera;
  expect(camera, isNotNull, reason: 'no camera fit was handed to the map');
  expect(camera!.target.latitude, inInclusiveRange(15.29, 15.36));
  expect(camera.target.longitude, inInclusiveRange(44.17, 44.27));
  expect(
    camera.zoom,
    lessThan(_defaultZoom),
    reason: 'the trip spans ~11 km: fitting it must zoom out from 14',
  );
  expect(
    camera.bearing,
    0,
    reason: 'the fit keeps the base camera bearing: the map is not rotated',
  );
}

/// Any HomeScreen rebuild — here a viewport change (keyboard, rotation); on a
/// device also every GPS tick, which calls setState.
Future<void> _rebuildHome(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2000);
  await tester.pumpAndSettle();
}

/// The recentre button is faded out while the route is in focus.
double _recentreOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byIcon(Icons.crop_free_rounded),
        matching: find.byType(AnimatedOpacity),
      ),
    )
    .opacity;

/// Geolocator answering "service on, permission granted, here is a fix", so
/// LocationService auto-starts tracking and the my-location button takes the
/// real path.
void _mockGeolocatorWithFix(LatLng fix) {
  final position = <String, dynamic>{
    'latitude': fix.latitude,
    'longitude': fix.longitude,
    'timestamp': DateTime(2026, 9, 10, 12).millisecondsSinceEpoch,
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

  group('plan restored from the previous session (#995)', () {
    testWidgets('restored after the first frame, before any camera report: '
        'route drawn and camera fitted', (tester) async {
      // The device timeline: first frame → restore emits ~3 ms later →
      // the map's first camera report ~500 ms after that.
      final repository = _JsonRepository()
        ..seed(_universityPlan())
        ..gate = Completer<void>();
      final cubit = RoutePlannerCubit(
        repository: repository,
        requestService: _FakePlanService(_universityPlan()),
      );
      addTearDown(cubit.close);
      unawaited(cubit.initialize());

      final calls = await _pumpHome(tester, cubit);
      expect(calls.layer('route-lines-layer'), isNull);
      expect(calls.camera, isNull);

      repository.gate!.complete();
      await tester.pumpAndSettle();

      expect(calls.reports, 0, reason: 'the map is not "ready" yet');
      _expectRouteDrawnAndFitted(calls);
      expect(find.textContaining('57'), findsWidgets);
    });

    testWidgets('restored before the screen exists (state already set when the '
        'listener subscribes): route drawn and camera fitted', (tester) async {
      final repository = _JsonRepository()..seed(_universityPlan());
      final cubit = RoutePlannerCubit(
        repository: repository,
        requestService: _FakePlanService(_universityPlan()),
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      expect(cubit.state.selectedItinerary, isNotNull);

      final calls = await _pumpHome(tester, cubit);

      expect(calls.reports, 0);
      _expectRouteDrawnAndFitted(calls);
    });

    testWidgets('wide layout (side panel) fits the restored plan too', (
      tester,
    ) async {
      final repository = _JsonRepository()..seed(_universityPlan());
      final cubit = RoutePlannerCubit(
        repository: repository,
        requestService: _FakePlanService(_universityPlan()),
      );
      addTearDown(cubit.close);
      await cubit.initialize();

      final calls = await _pumpHome(tester, cubit, phone: false);
      _expectRouteDrawnAndFitted(calls);
    });

    testWidgets('the map reporting its camera afterwards keeps the fitted view '
        '(the screen does not re-drive it to the default)', (tester) async {
      final repository = _JsonRepository()..seed(_universityPlan());
      final cubit = RoutePlannerCubit(
        repository: repository,
        requestService: _FakePlanService(_universityPlan()),
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      final calls = await _pumpHome(tester, cubit);
      final fitted = calls.camera!;

      // The real map applies the controlled camera once its style loads and
      // then reports it (its own idle for the initial position is ignored
      // while the controlled camera is pending — see TrufiMap).
      calls.report(fitted);
      await tester.pumpAndSettle();
      // Once the map has reported the fit the screen releases it: a later
      // rebuild hands no controlled camera, and the map keeps its view.
      await _rebuildHome(tester);

      expect(
        calls.camera,
        isNull,
        reason: 'the screen keeps re-driving the fit',
      );
      final held =
          (tester.state(find.byType(_FakeMap)) as _FakeMapState).cameraPosition;
      expect(held, equals(fitted));
      expect(calls.layer('route-lines-layer'), isNotNull);
    });

    testWidgets('clearing the plan clears the route from the map as well', (
      tester,
    ) async {
      final repository = _JsonRepository()..seed(_universityPlan());
      final cubit = RoutePlannerCubit(
        repository: repository,
        requestService: _FakePlanService(_universityPlan()),
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      final calls = await _pumpHome(tester, cubit);
      _expectRouteDrawnAndFitted(calls);

      await cubit.clearPlan();
      await tester.pumpAndSettle();

      expect(calls.layer('route-lines-layer'), isNull);
      expect(calls.layer('route-markers-layer'), isNull);
      expect(calls.camera, isNull, reason: 'nothing left to fit');
      // The places stay, so the map shows their previews — panel and map agree.
      final previews = calls.layer('location-markers-layer');
      expect(previews, isNotNull);
      expect(
        previews!.markers.map((m) => m.id),
        containsAll(['origin-preview', 'destination-preview']),
      );
      expect(find.textContaining('57'), findsNothing);
    });
  });

  group('after the fit', () {
    testWidgets(
      'my-location, then a rebuild (a GPS tick): the map stays on the '
      'user, the screen does not hand the fit back',
      (tester) async {
        const fix = LatLng(15.40, 44.24);
        _mockGeolocatorWithFix(fix);
        final repository = _JsonRepository()..seed(_universityPlan());
        final cubit = RoutePlannerCubit(
          repository: repository,
          requestService: _FakePlanService(_universityPlan()),
        );
        addTearDown(cubit.close);
        await cubit.initialize();
        final calls = await _pumpHome(tester, cubit);
        _expectRouteDrawnAndFitted(calls);
        final map = tester.state(find.byType(_FakeMap)) as _FakeMapState;

        // Tracking auto-started with the granted permission: filled icon, and
        // the tap takes the "already tracking" path of _onMyLocationPressed.
        final myLocation = find.byIcon(Icons.my_location_rounded);
        expect(myLocation, findsOneWidget, reason: 'tracking should be on');
        await tester.tap(myLocation);
        await tester.pumpAndSettle();
        expect(map.cameraPosition.target, equals(fix));
        expect(map.cameraPosition.zoom, 16);

        await _rebuildHome(tester);

        expect(
          calls.camera,
          isNull,
          reason: 'a programmatic move must drop the controlled camera',
        );
        expect(
          map.cameraPosition.target,
          equals(fix),
          reason: 'a rebuild must not yank the camera back to the route fit',
        );
        expect(map.cameraPosition.zoom, 16);
      },
    );

    testWidgets('panning away shows the recentre button; fitting another '
        'itinerary hides it again', (tester) async {
      final plan = _universityPlan(withAlternative: true);
      final repository = _JsonRepository()..seed(plan);
      final cubit = RoutePlannerCubit(
        repository: repository,
        requestService: _FakePlanService(plan),
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      final calls = await _pumpHome(tester, cubit);
      _expectRouteDrawnAndFitted(calls);
      expect(_recentreOpacity(tester), 0.0);

      // The user pans ~50 km away: the map reports a camera off the fit.
      calls.report(
        const TrufiCameraPosition(target: LatLng(15.80, 44.60), zoom: 16),
      );
      await tester.pumpAndSettle();
      expect(_recentreOpacity(tester), 1.0, reason: 'route out of focus');

      // Selecting the other itinerary fits it from the reported camera (no
      // intermediate loading state): the route is in focus again.
      await cubit.selectItinerary(cubit.state.plan!.itineraries![1]);
      await tester.pumpAndSettle();
      _expectRouteDrawnAndFitted(calls);
      expect(_recentreOpacity(tester), 0.0, reason: 'the fit resets focus');
    });
  });

  group('fresh search (unchanged)', () {
    testWidgets('planning after the map reported its camera draws and fits', (
      tester,
    ) async {
      final service = _FakePlanService(_universityPlan());
      final cubit = RoutePlannerCubit(
        repository: _JsonRepository(),
        requestService: service,
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      final calls = await _pumpHome(tester, cubit);
      expect(calls.layer('route-lines-layer'), isNull);

      calls.report(
        const TrufiCameraPosition(target: _defaultCenter, zoom: _defaultZoom),
      );
      await cubit.setFromPlace(_from);
      await cubit.setToPlace(_to);
      await tester.pumpAndSettle();
      expect(calls.layer('location-markers-layer'), isNotNull);
      expect(calls.camera, isNull, reason: 'no fit for previews alone');

      await cubit.fetchPlan();
      await tester.pumpAndSettle();

      expect(service.calls, 1);
      _expectRouteDrawnAndFitted(calls);
    });
  });
}
