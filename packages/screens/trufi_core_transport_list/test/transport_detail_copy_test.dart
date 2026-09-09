import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// trufi-sanaa#9 on the route detail: long-press on a stop copies its name
/// (tap still selects it on the map) and the origin/destination header
/// labels copy too. Drives the real [TransportDetailScreen] over a fake map
/// engine.
List<String> mockClipboard() {
  final copied = <String>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') {
      copied.add((call.arguments as Map)['text'] as String);
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return copied;
}

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

const stops = [
  TransportStop(
    id: 's1',
    name: 'Parada Central',
    latitude: -17.39,
    longitude: -66.15,
  ),
  // Bab al-Yemen, Sana'a.
  TransportStop(
    id: 's2',
    name: 'محطة باب اليمن',
    latitude: -17.395,
    longitude: -66.155,
  ),
  TransportStop(
    id: 's3',
    name: 'Parada Final',
    latitude: -17.40,
    longitude: -66.16,
  ),
];

const details = TransportRouteDetails(
  id: 'r1',
  code: 'A1',
  name: 'Linea A',
  shortName: 'A',
  longName: 'Terminal Norte → Plaza Principal',
  stops: stops,
  geometry: [
    (latitude: -17.39, longitude: -66.15),
    (latitude: -17.40, longitude: -66.16),
  ],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpDetail(
    WidgetTester tester, {
    TextDirection? textDirection,
  }) async {
    final manager = MapEngineManager(
      engines: [_FakeEngine()],
      defaultCenter: const LatLng(-17.39, -66.15),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<MapEngineManager>.value(
        value: manager,
        child: MaterialApp(
          localizationsDelegates:
              TransportListLocalizations.localizationsDelegates,
          supportedLocales: TransportListLocalizations.supportedLocales,
          builder: textDirection == null
              ? null
              : (context, child) =>
                    Directionality(textDirection: textDirection, child: child!),
          home: TransportDetailScreen(
            routeCode: 'A1',
            getRouteDetails: (_) async => details,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // The default 800×600 test surface is the wide layout (≥600 px): the stops
  // live in the side panel, no sheet to scroll.
  testWidgets('long-press on a stop copies its name; tap still selects it', (
    tester,
  ) async {
    final copied = mockClipboard();
    await pumpDetail(tester);

    await tester.longPress(find.text('Parada Central'));
    await tester.pump();
    expect(copied, ['Parada Central']);
    expect(find.text('Copied'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_rounded), findsNothing);

    await tester.tap(find.text('Parada Final'));
    await tester.pumpAndSettle();
    expect(
      find.byIcon(Icons.location_on_rounded),
      findsOneWidget,
      reason: 'tap selects the stop (indicator shown)',
    );
    expect(copied, ['Parada Central'], reason: 'a tap copies nothing');
  });

  testWidgets('the origin/destination header labels copy too', (tester) async {
    final copied = mockClipboard();
    await pumpDetail(tester);

    await tester.longPress(find.text('Terminal Norte'));
    await tester.pump();
    await tester.longPress(find.text('Plaza Principal'));
    await tester.pump();

    expect(copied, ['Terminal Norte', 'Plaza Principal']);
  });

  testWidgets('RTL: an Arabic stop name is copied whole', (tester) async {
    final copied = mockClipboard();
    await pumpDetail(tester, textDirection: TextDirection.rtl);

    final stop = find.text('محطة باب اليمن');
    expect(Directionality.of(tester.element(stop)), TextDirection.rtl);
    await tester.longPress(stop);
    await tester.pump();

    expect(copied, ['محطة باب اليمن']);
  });

  testWidgets('phone layout: the bottom sheet header labels copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final copied = mockClipboard();
    await pumpDetail(tester);

    // With stops available the sheet header labels are the first/last stop
    // names (also present in the list below, hence `.first`).
    await tester.longPress(find.text('Parada Central').first);
    await tester.pump();

    expect(copied, ['Parada Central']);
  });
}
