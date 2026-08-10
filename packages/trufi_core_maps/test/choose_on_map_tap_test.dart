import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Records every moveCamera the screen asks for, plus attach/detach order.
final List<TrufiCameraPosition> moves = [];
final List<String> lifecycle = [];

/// Where the fake map pretends the user tapped.
const tappedPoint = LatLng(-17.50000, -66.50000);

class FakeEngine implements ITrufiMapEngine {
  FakeEngine(this.engineId);
  final String engineId;

  @override
  String get id => engineId;
  @override
  String get name => engineId;
  @override
  String get description => engineId;
  @override
  String localizedName(BuildContext context) => engineId;
  @override
  String localizedDescription(BuildContext context) => engineId;
  @override
  Widget? get previewWidget => null;
  @override
  Future<void> initialize() async {}

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
    return _FakeMapWidget(
      key: ValueKey(engineId),
      label: engineId,
      controller: controller,
      initialCamera: initialCamera,
      onMapClick: onMapClick,
    );
  }
}

/// Mirrors TrufiMap's controller lifecycle exactly (attach in initState,
/// detach in dispose) and forwards taps like MapLibre's onMapClick.
class _FakeMapWidget extends StatefulWidget {
  const _FakeMapWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.initialCamera,
    this.onMapClick,
  });
  final String label;
  final TrufiMapController? controller;
  final TrufiCameraPosition initialCamera;
  final void Function(LatLng)? onMapClick;

  @override
  State<_FakeMapWidget> createState() => _FakeMapWidgetState();
}

class _FakeMapWidgetState extends State<_FakeMapWidget>
    implements TrufiMapDelegate {
  late TrufiCameraPosition _camera;

  @override
  void initState() {
    super.initState();
    _camera = widget.initialCamera;
    lifecycle.add('attach:${widget.label}');
    widget.controller?.attach(this);
  }

  @override
  void dispose() {
    lifecycle.add('detach:${widget.label}');
    widget.controller?.detach(this);
    super.dispose();
  }

  @override
  TrufiCameraPosition get cameraPosition => _camera;

  @override
  void moveCamera(TrufiCameraPosition position) {
    _camera = position;
    moves.add(position);
  }

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
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => widget.onMapClick?.call(tappedPoint),
    child: const SizedBox.expand(),
  );
}

/// The zoom the fake screen starts at (MapEngineManager.defaultZoom).
const initialZoom = 12.0;

/// Held so a test can switch the engine after pumping.
late MapEngineManager currentManager;

/// Switches to the other engine, which rebuilds the map widget — the
/// path that used to leave the controller detached.
Future<void> switchEngine(WidgetTester tester) async {
  currentManager.setEngineByIndex(1);
  await tester.pumpAndSettle();
}

Future<MapEngineManager> pumpScreen(
  WidgetTester tester, {
  int engineCount = 2,
}) async {
  final manager = MapEngineManager(
    engines: [
      for (var i = 0; i < engineCount; i++) FakeEngine('engine_$i'),
    ],
    defaultCenter: const LatLng(-17.39, -66.15),
    defaultZoom: 12,
  );

  await tester.pumpWidget(
    ChangeNotifierProvider<MapEngineManager>.value(
      value: manager,
      child: MaterialApp(
        localizationsDelegates: const [MapsLocalizations.delegate],
        home: const ChooseOnMapScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  currentManager = manager;
  return manager;
}

String coordsText(WidgetTester tester) {
  final texts = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .where((s) => s.contains(','))
      .toList();
  return texts.isEmpty ? '<none>' : texts.first;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    moves.clear();
    lifecycle.clear();
    SharedPreferences.setMockInitialValues({});
  });

  group('choose on map: tap to place (#819)', () {
    testWidgets('a tap recentres the map and updates the coordinates', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tapAt(const Offset(400, 400));
      await tester.pump();

      expect(moves.length, 1, reason: 'the tap must move the camera');
      expect(moves.single.target, tappedPoint);
      expect(coordsText(tester), '-17.50000, -66.50000');
    });

    testWidgets('a tap keeps the current zoom', (tester) async {
      await pumpScreen(tester);

      await tester.tapAt(const Offset(400, 400));
      await tester.pump();

      expect(moves.single.zoom, initialZoom,
          reason: 'placing a point must not zoom the map');
    });

    testWidgets('the tap still works after switching map engine', (
      tester,
    ) async {
      // Regression guard: Flutter attaches the new map before disposing
      // the old one, so an unconditional detach used to leave the
      // controller bound to nothing — the coordinates changed while the
      // marker stayed put, and the user confirmed a different place than
      // the one shown.
      await pumpScreen(tester);
      await switchEngine(tester);

      await tester.tapAt(const Offset(400, 400));
      await tester.pump();

      expect(moves.length, 1,
          reason: 'the controller must survive an engine switch');
      expect(coordsText(tester), '-17.50000, -66.50000');
    });
  });
}
