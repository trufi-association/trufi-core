import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'navigation_fixtures.dart';

/// What the navigation screen hands the map engine on each build.
class MapCall {
  MapCall(this.initialCamera, this.camera);
  final TrufiCameraPosition initialCamera;
  final TrufiCameraPosition? camera;

  /// Where the map is told to look: the controlled camera when there is one,
  /// else where it starts.
  LatLng get target => (camera ?? initialCamera).target;
}

class RecordingEngine extends ITrufiMapEngine {
  final calls = <MapCall>[];

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
    calls.add(MapCall(initialCamera, camera));
    return const SizedBox.expand();
  }
}

class RecordingMapManager extends Fake implements MapEngineManager {
  final engine = RecordingEngine();
  @override
  ITrufiMapEngine get currentEngine => engine;
}

class NoWakelock extends WakelockPlusMacOSPlugin {
  @override
  Future<void> toggle({required bool enable}) async {}
  @override
  Future<bool> get enabled async => false;
}

/// A rider far from the Sana'a trip (La Paz): outside any Sana'a area.
const farAway = LatLng(-16.4897, -68.1193);

/// A box around the Sana'a trip (origin, line and destination inside it).
const sanaaArea = LatLngBounds(LatLng(15.30, 44.15), LatLng(15.40, 44.25));

/// Mounts the app, taps "Start" and opens the navigation of the Sana'a trip
/// through `NavigationScreen.showFromItinerary`, the call an app makes.
Future<({RecordingMapManager maps, FakeLocationService location})>
startSanaaNavigation(
  WidgetTester tester, {
  required LatLng rider,
  NavigationConfig config = const NavigationConfig(),
  Locale locale = const Locale('en'),
}) async {
  final maps = RecordingMapManager();
  final location = FakeLocationService(initial: rider);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: NavigationLocalizations.localizationsDelegates,
      supportedLocales: NavigationLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => NavigationScreen.showFromItinerary(
              context,
              itinerary: SanaaTrip.itinerary(),
              locationService: location,
              mapEngineManager: maps,
              config: config,
            ),
            child: const Text('Start'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Start'));
  await tester.pumpAndSettle();
  return (maps: maps, location: location);
}

/// The distance figure of the instruction card ("150 m", "10,512.3 km").
final distanceFigure = find.textContaining(RegExp(r'^\d[\d.,]* (km|m)$'));

/// The ETA of the instruction card ("~32 min").
final etaFigure = find.textContaining(RegExp(r'^~'));

Distance get meters => const Distance(roundResult: false);
