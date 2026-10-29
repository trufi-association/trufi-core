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
    show TrufiLocation, StorageService;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart'
    show SearchLocationsLocalizations;

// trufi-core#1042: the layers sheet lists the POI section only once the
// manager has categories; before that (manifest loading, or absent) there is
// no section and no stray separator.

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

class _MemoryStorage implements StorageService {
  final _data = <String, Object>{};
  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<String?> read(String key) async => _data[key] as String?;
  @override
  Future<void> delete(String key) async => _data.remove(key);
  @override
  Future<void> clear() async => _data.clear();
  @override
  Future<void> writeInt(String key, int value) async => _data[key] = value;
  @override
  Future<int?> readInt(String key) async => _data[key] as int?;
  @override
  Future<void> writeBool(String key, bool value) async => _data[key] = value;
  @override
  Future<bool?> readBool(String key) async => _data[key] as bool?;
  @override
  Future<void> writeDouble(String key, double value) async =>
      _data[key] = value;
  @override
  Future<double?> readDouble(String key) async => _data[key] as double?;
  @override
  Future<void> writeStringList(String key, List<String> value) async =>
      _data[key] = value;
  @override
  Future<List<String>?> readStringList(String key) async =>
      _data[key] as List<String>?;
  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);
  @override
  Future<Set<String>> getKeys() async => _data.keys.toSet();
}

const _metadata =
    '{"categories": [{"name": "health", "displayName": "Health", "count": 1, '
    '"subcategories": [{"name": "hospital", "displayName": "Hospital", '
    '"count": 1, "defaultActive": true, "color": "#D32F2F"}]}]}';

Future<ByteData?> _assets(ByteData? message) async {
  final key = utf8.decode(message!.buffer.asUint8List());
  final body = switch (key) {
    'assets/pois/metadata.json' => _metadata,
    'assets/pois/health.geojson' =>
      '{"type": "FeatureCollection", "features": []}',
    _ => null,
  };
  if (body == null) return null;
  return ByteData.sublistView(Uint8List.fromList(utf8.encode(body)));
}

Future<void> _pumpHome(WidgetTester tester, POILayersManager manager) async {
  final cubit = RoutePlannerCubit(
    repository: _EmptyRepository(),
    requestService: _NoPlanService(),
  );
  addTearDown(cubit.close);
  await cubit.initialize();
  final engines = MapEngineManager(
    engines: [_FakeEngine('e0'), _FakeEngine('e1')],
    defaultCenter: const LatLng(-17.39, -66.16),
    defaultZoom: 13,
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MapEngineManager>.value(value: engines),
        ChangeNotifierProvider<POILayersManager>.value(value: manager),
        BlocProvider<RoutePlannerCubit>.value(value: cubit),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          ...HomeScreenLocalizations.localizationsDelegates,
          MapsLocalizations.delegate,
          SearchLocationsLocalizations.delegate,
          routing.RoutingLocalizations.delegate,
          POILayersLocalizations.delegate,
        ],
        supportedLocales: HomeScreenLocalizations.supportedLocales,
        home: HomeScreen(
          onMenuPressed: () {},
          config: HomeScreenConfig(poiLayersManager: manager),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (call) async => false,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', _assets);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    rootBundle.clear();
  });

  testWidgets('a manager without categories (manifest missing): the sheet '
      'lists the styles and no POI section', (tester) async {
    final manager = POILayersManager(
      assetsBasePath: 'assets/missing',
      storage: _MemoryStorage(),
    );
    addTearDown(manager.dispose);
    await _pumpHome(tester, manager); // the home initializes the manager
    expect(manager.isInitialized, isTrue);
    expect(manager.categories, isEmpty);

    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle();
    expect(find.text('Map e0'), findsOneWidget, reason: 'the styles are there');
    expect(find.byType(POILayersSettingsSection), findsNothing);
  });

  testWidgets('once the manifest is loaded the POI section is listed', (
    tester,
  ) async {
    final manager = POILayersManager(
      assetsBasePath: 'assets/pois',
      storage: _MemoryStorage(),
    );
    addTearDown(manager.dispose);
    await _pumpHome(tester, manager);
    expect(manager.categories, hasLength(1));

    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle();
    expect(find.byType(POILayersSettingsSection), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
  });
}
