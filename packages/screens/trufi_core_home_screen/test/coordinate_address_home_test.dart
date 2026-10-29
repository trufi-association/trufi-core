// The real HomeScreen over a fake map engine, a fake plan service and a real
// SearchLocationsCubit over a fake geocoder whose reverse answers are
// completed by the test, so "the reverse answered later" (#1023) is played
// by hand: a bare "Go to lat, lon" pair gains its address without a second
// plan request, a camera re-fit or a sheet re-expand.
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
    show TrufiLocation;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

import 'in_memory_storage.dart';

// Sana'a fixtures of restored_plan_map_test.dart: the trip lies outside the
// default viewport, so a fit visibly zooms out from 14.
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

routing.Plan _plan() => routing.Plan(
  itineraries: [
    routing.Itinerary(
      legs: [
        _leg([_origin, _boarding], startMinute: 0, minutes: 5),
        _leg([_boarding, _transfer], route: '7', startMinute: 5, minutes: 20),
        _leg(
          [_transfer, _alighting],
          route: '14',
          startMinute: 25,
          minutes: 27,
        ),
        _leg([_alighting, _destination], startMinute: 52, minutes: 5),
      ],
      startTime: DateTime(2026, 9, 10, 12),
      endTime: DateTime(2026, 9, 10, 12, 57),
      walkTime: const Duration(minutes: 10),
      duration: const Duration(minutes: 57),
      walkDistance: 833,
    ),
  ],
);

class _Repository implements HomeScreenRepository {
  TrufiLocation? from;
  TrufiLocation? to;
  int fromSaves = 0;
  int toSaves = 0;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> saveFromPlace(TrufiLocation? data) async {
    fromSaves++;
    from = data;
  }

  @override
  Future<TrufiLocation?> getFromPlace() async => from;
  @override
  Future<void> saveToPlace(TrufiLocation? data) async {
    toSaves++;
    to = data;
  }

  @override
  Future<TrufiLocation?> getToPlace() async => to;
  @override
  Future<void> savePlan(routing.Plan? data) async {}
  @override
  Future<routing.Plan?> getPlan() async => null;
  @override
  Future<void> saveSelectedItinerary(routing.Itinerary? data) async {}
  @override
  Future<routing.Itinerary?> getSelectedItinerary() async => null;
  @override
  Future<void> clear() async {
    from = null;
    to = null;
  }
}

class _FakePlanService implements RequestPlanService {
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
    return _plan();
  }
}

/// Geocoder whose reverse answers are completed by the test.
class _Service implements SearchLocationService {
  final List<(double, double)> reversed = [];
  final List<Completer<SearchLocation?>> answers = [];
  @override
  Future<List<SearchLocation>> search(String query) async => const [];
  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) {
    reversed.add((latitude, longitude));
    final c = Completer<SearchLocation?>();
    answers.add(c);
    return c.future;
  }

  @override
  void dispose() {}
}

class _MapCalls {
  List<TrufiLayer> layers = const [];
  TrufiCameraPosition? camera;
  int cameraHandoffs = 0;
  ValueChanged<TrufiCameraPosition>? _onCameraChanged;

  TrufiLayer? layer(String id) {
    final hits = layers.where((l) => l.id == id).toList();
    return hits.isEmpty ? null : hits.single;
  }

  void report(TrufiCameraPosition position) => _onCameraChanged?.call(position);
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
    if (camera != null && camera != calls.camera) calls.cameraHandoffs++;
    calls.camera = camera;
    calls._onCameraChanged = onCameraChanged;
    return _FakeMap(
      controller: controller,
      initialCamera: initialCamera,
      camera: camera,
    );
  }
}

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

class _World {
  late _Repository repository;
  late RoutePlannerCubit cubit;
  late _FakePlanService planner;
  late _Service service;
  late SearchLocationsCubit geocoder;
  late _MapCalls map;
}

Future<_World> _pumpWorld(WidgetTester tester, {bool geocoder = true}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final w = _World();
  w.repository = _Repository();
  w.planner = _FakePlanService();
  w.cubit = RoutePlannerCubit(
    repository: w.repository,
    requestService: w.planner,
  );
  addTearDown(w.cubit.close);
  await w.cubit.initialize();
  w.service = _Service();
  w.geocoder = SearchLocationsCubit(
    searchLocationService: w.service,
    localRepository: SearchLocationsRepositoryImpl(storage: InMemoryStorage()),
  );
  addTearDown(w.geocoder.close);
  w.map = _MapCalls();
  final manager = MapEngineManager(
    engines: [_FakeEngine(w.map)],
    defaultCenter: _defaultCenter,
    defaultZoom: _defaultZoom,
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MapEngineManager>.value(value: manager),
        BlocProvider<RoutePlannerCubit>.value(value: w.cubit),
        if (geocoder)
          BlocProvider<SearchLocationsCubit>.value(value: w.geocoder),
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
  // The cubit's initial 300 ms debounce timer must elapse inside the test.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
  // The map reports its camera: from here on a plan draws and fits.
  w.map.report(
    const TrufiCameraPosition(target: _defaultCenter, zoom: _defaultZoom),
  );
  await tester.pumpAndSettle();
  return w;
}

/// What LocationSearchScreen pops when the "Go to" row is tapped BEFORE the
/// reverse answered (location_search_screen.dart:237-248 with address null).
SearchLocation _bareRow(LatLng p) => SearchLocation(
  id: 'coordinates:${p.latitude},${p.longitude}',
  displayName: CoordinateParser.format(p.latitude, p.longitude),
  latitude: p.latitude,
  longitude: p.longitude,
);

const _university = SearchLocation(
  id: 'photon:u',
  displayName: 'Universidad',
  address: 'Sanaa',
  latitude: 15.3536032,
  longitude: 44.1786948,
);

/// A Photon-like reverse answer: a named feature with a city-level address.
const _plaza = SearchLocation(
  id: 'osm_1',
  displayName: 'Plaza Colón',
  address: 'Cochabamba, Bolivia',
  latitude: 15.2952334,
  longitude: 44.2623529,
);

/// The real Home wiring: SearchLocationBar hands the popped location to
/// HomeScreen._onOriginSelected / _onDestinationSelected (search_location_bar.dart:359).
SearchLocationBar _bar(WidgetTester tester) =>
    tester.widget<SearchLocationBar>(find.byType(SearchLocationBar).first);

Future<void> _pickOrigin(WidgetTester tester, SearchLocation l) async {
  _bar(tester).onOriginSelected(l);
  await tester.pumpAndSettle();
}

Future<void> _pickDestination(WidgetTester tester, SearchLocation l) async {
  _bar(tester).onDestinationSelected(l);
  await tester.pumpAndSettle();
}

/// The text of the Home field that starts with [startsWith], without the
/// left-to-right mark `formattedDisplay` puts in front of a coordinate pair
/// (#1024): these tests check what the field says, not how bidi paints it.
String _fieldText(WidgetTester tester, String startsWith) {
  final texts = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => (t.data ?? '').replaceAll('\u200E', ''))
      .where((t) => t.startsWith(startsWith))
      .toList();
  return texts.isEmpty ? '<none>' : texts.first;
}

double _recentreOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byIcon(Icons.crop_free_rounded),
        matching: find.byType(AnimatedOpacity),
      ),
    )
    .opacity;

DraggableScrollableController _sheet(WidgetTester tester) => tester
    .widget<DraggableScrollableSheet>(find.byType(DraggableScrollableSheet))
    .controller!;

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

  final pair = CoordinateParser.format(_origin.latitude, _origin.longitude);

  testWidgets('A. bare row chosen before the reverse answered: Home asks the '
      'geocoder once, the address lands in the field and is persisted', (
    tester,
  ) async {
    final w = await _pumpWorld(tester);
    await _pickOrigin(tester, _bareRow(_origin));
    expect(_fieldText(tester, pair), pair, reason: 'bare pair first');
    expect(w.service.reversed, [(_origin.latitude, _origin.longitude)]);
    expect(w.cubit.state.fromPlace!.address, isNull);
    expect(w.repository.fromSaves, 1);

    w.service.answers.single.complete(_plaza);
    await tester.pumpAndSettle();

    expect(w.cubit.state.fromPlace!.address, contains('Cochabamba, Bolivia'));
    expect(w.repository.from!.address, contains('Cochabamba, Bolivia'));
    expect(w.repository.fromSaves, 2, reason: 'one more save, no more');
    expect(_fieldText(tester, pair), startsWith('$pair, '));
    expect(_fieldText(tester, pair), endsWith('Cochabamba, Bolivia'));
    expect(w.planner.calls, 0, reason: 'no destination yet: no plan request');
    expect(tester.takeException(), isNull);
  });

  testWidgets('B. the same row chosen AFTER the reverse answered (real search '
      'screen): the field shows pair + name + address', (tester) async {
    final w = await _pumpWorld(tester);
    await tester.tap(find.text('Select origin').first);
    await tester.pumpAndSettle();
    expect(find.byType(LocationSearchScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, pair);
    await tester.pump(const Duration(milliseconds: 350)); // debounce
    expect(w.service.reversed, hasLength(1), reason: 'the screen asked');
    w.service.answers.single.complete(_plaza);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Go to '));
    await tester.pumpAndSettle();
    expect(find.byType(LocationSearchScreen), findsNothing);
    expect(w.service.reversed, hasLength(1), reason: 'Home did not ask again');
    expect(w.cubit.state.fromPlace!.address, _plaza.formattedDisplay);
    expect(_fieldText(tester, pair), '$pair, Plaza Colón, Cochabamba, Bolivia');
  });

  testWidgets('A2. parity: chosen before or '
      'after the subtitle, the field must read the same', (tester) async {
    final w = await _pumpWorld(tester);
    await _pickOrigin(tester, _bareRow(_origin));
    w.service.answers.single.complete(_plaza);
    await tester.pumpAndSettle();
    expect(
      _fieldText(tester, pair),
      '$pair, ${_plaza.formattedDisplay}',
      reason:
          'the search screen stores formattedDisplay (name, address) '
          'when the row is chosen after the answer',
    );
  });

  testWidgets('C. the late address must not '
      're-fit the camera after the user panned away', (tester) async {
    final w = await _pumpWorld(tester);
    await _pickOrigin(tester, _bareRow(_origin)); // reverse pending
    await _pickDestination(tester, _university);
    expect(w.planner.calls, 1);
    expect(w.map.layer('route-lines-layer'), isNotNull, reason: 'plan drawn');
    expect(w.map.camera, isNotNull, reason: 'fitted');
    expect(w.map.camera!.zoom, lessThan(_defaultZoom));
    expect(_recentreOpacity(tester), 0.0);
    final handoffsAfterFit = w.map.cameraHandoffs;

    // The user pans ~50 km away: route out of focus, recentre button shown.
    w.map.report(
      const TrufiCameraPosition(target: LatLng(15.80, 44.60), zoom: 16),
    );
    await tester.pumpAndSettle();
    expect(_recentreOpacity(tester), 1.0, reason: 'route out of focus');

    // Now the reverse answers (anything up to 8 s later on a device).
    w.service.answers.single.complete(_plaza);
    await tester.pumpAndSettle();
    expect(w.cubit.state.fromPlace!.address, contains('Cochabamba, Bolivia'));
    expect(w.planner.calls, 1, reason: 'no second plan request');
    expect(
      w.map.cameraHandoffs,
      handoffsAfterFit,
      reason:
          'an address-only state change must not hand the map a new '
          'camera (listenWhen skips _updateFitCameraPoints for it)',
    );
    expect(_recentreOpacity(tester), 1.0, reason: 'the user is still away');
  });

  testWidgets('D. the late address must not '
      're-expand a sheet the user collapsed', (tester) async {
    final w = await _pumpWorld(tester);
    await _pickOrigin(tester, _bareRow(_origin)); // reverse pending
    await _pickDestination(tester, _university);
    expect(w.planner.calls, 1);
    final sheet = _sheet(tester);
    expect(sheet.isAttached, isTrue);
    expect(sheet.size, closeTo(0.35, 0.01), reason: 'results → mid');

    // The user collapses the sheet to look at the map.
    sheet.jumpTo(0.25);
    await tester.pumpAndSettle();
    expect(sheet.size, closeTo(0.25, 0.01));

    w.service.answers.single.complete(_plaza);
    await tester.pumpAndSettle();
    expect(w.cubit.state.fromPlace!.address, contains('Cochabamba, Bolivia'));
    expect(
      sheet.size,
      closeTo(0.25, 0.01),
      reason: 'an address-only state change must not re-expand the sheet',
    );
  });

  testWidgets('E. origin and destination both bare: one plan request, both '
      'addresses land, the plan is untouched', (tester) async {
    final w = await _pumpWorld(tester);
    await _pickOrigin(tester, _bareRow(_origin));
    await _pickDestination(tester, _bareRow(_destination));
    expect(w.service.reversed, hasLength(2));
    expect(w.planner.calls, 1);
    final plan = w.cubit.state.plan;
    final itinerary = w.cubit.state.selectedItinerary;
    expect(plan, isNotNull);

    w.service.answers[0].complete(_plaza);
    w.service.answers[1].complete(
      const SearchLocation(
        id: 'osm_2',
        displayName: 'Universidad',
        address: 'Sanaa',
        latitude: 15.3536032,
        longitude: 44.1786948,
      ),
    );
    await tester.pumpAndSettle();
    expect(w.cubit.state.fromPlace!.address, contains('Cochabamba, Bolivia'));
    expect(w.cubit.state.toPlace!.address, contains('Sanaa'));
    expect(identical(w.cubit.state.plan, plan), isTrue, reason: 'same plan');
    expect(identical(w.cubit.state.selectedItinerary, itinerary), isTrue);
    expect(w.cubit.state.isLoading, isFalse);
    expect(w.cubit.state.error, isNull);
    expect(w.planner.calls, 1, reason: 'no re-request');
    expect(tester.takeException(), isNull);
  });

  testWidgets('F. the user picked another origin meanwhile: the late answer '
      'is dropped, the new place is untouched', (tester) async {
    final w = await _pumpWorld(tester);
    await _pickOrigin(tester, _bareRow(_origin));
    await _pickOrigin(tester, _university);
    expect(w.service.reversed, hasLength(1));
    w.service.answers.single.complete(_plaza);
    await tester.pumpAndSettle();
    expect(w.cubit.state.fromPlace!.description, 'Universidad');
    expect(w.cubit.state.fromPlace!.address, 'Sanaa');
    expect(w.repository.fromSaves, 2, reason: 'nothing written for the pair');
  });

  testWidgets('G. swap during the window: the address lands in the field '
      'that holds the pair now', (tester) async {
    final w = await _pumpWorld(tester);
    await _pickOrigin(tester, _bareRow(_origin));
    await _pickDestination(tester, _university);
    _bar(tester).onSwap!();
    await tester.pumpAndSettle();
    expect(w.cubit.state.toPlace!.description, pair);
    w.service.answers.single.complete(_plaza);
    await tester.pumpAndSettle();
    expect(w.cubit.state.toPlace!.address, contains('Cochabamba, Bolivia'));
    expect(w.repository.to!.address, contains('Cochabamba, Bolivia'));
    expect(w.cubit.state.fromPlace!.description, 'Universidad');
    expect(w.cubit.state.fromPlace!.address, 'Sanaa', reason: 'not clobbered');
  });

  testWidgets('H. reverse answers null or throws: the pair stays bare, '
      'nothing is written, no exception', (tester) async {
    final w = await _pumpWorld(tester);
    await _pickOrigin(tester, _bareRow(_origin));
    w.service.answers.single.complete(null);
    await tester.pumpAndSettle();
    expect(w.cubit.state.fromPlace!.address, isNull);
    expect(w.repository.fromSaves, 1);

    await _pickDestination(tester, _bareRow(_destination));
    w.service.answers[1].completeError(StateError('down'));
    await tester.pumpAndSettle();
    expect(w.cubit.state.toPlace!.address, isNull);
    expect(w.repository.toSaves, 1);
    expect(tester.takeException(), isNull);
  });
}
