import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';
import 'package:trufi_core_settings/trufi_core_settings.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

/// trufi-sanaa#23: the "Route search" and "Map" cards only offer a choice
/// between engines. An app with a single engine of either kind gets no card
/// (and no stray spacer) instead of one pre-selected tile.

class _FakeProvider extends IRoutingProvider {
  _FakeProvider(this.id);

  @override
  final String id;
  @override
  String get name => 'Engine $id';
  @override
  String get description => 'Fake engine $id';
  @override
  bool get supportsTransitRoutes => false;
  @override
  bool get requiresInternet => true;

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async => Plan(itineraries: []);

  @override
  Future<List<TransitRoute>> fetchTransitRoutes() async => [];

  @override
  Future<TransitRoute?> fetchTransitRouteById(String id) async => null;
}

class _FakeMapEngine extends ITrufiMapEngine {
  _FakeMapEngine(this.id);

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

Future<void> _pumpSettings(
  WidgetTester tester, {
  required int routingEngines,
  required int mapEngines,
}) async {
  final screen = SettingsTrufiScreen();
  await tester.pumpWidget(
    MultiProvider(
      // A fresh key per pump: a second pump in the same test would otherwise
      // reuse the provider elements, and `create` would not run again.
      key: UniqueKey(),
      providers: [
        ChangeNotifierProvider<LocaleManager>(
          create: (_) => LocaleManager(defaultLocale: const Locale('en')),
        ),
        ChangeNotifierProvider<ThemeManager>(create: (_) => ThemeManager()),
        ChangeNotifierProvider<MapEngineManager>(
          create: (_) => MapEngineManager(
            engines: [
              for (var i = 0; i < mapEngines; i++) _FakeMapEngine('$i'),
            ],
            defaultCenter: const LatLng(15.3470, 44.2050),
          ),
        ),
        ChangeNotifierProvider<RoutingEngineManager>(
          create: (_) => RoutingEngineManager(
            engines: [
              for (var i = 0; i < routingEngines; i++) _FakeProvider('$i'),
            ],
          ),
        ),
        // Keeps the privacy card on screen: it is what follows the
        // optional cards, so the gap to it is where a stray spacer shows.
        ChangeNotifierProvider<PrivacyConsentManager>(
          create: (_) => PrivacyConsentManager(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          ...SettingsLocalizations.localizationsDelegates,
          MapsLocalizations.delegate,
        ],
        supportedLocales: SettingsLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: Builder(builder: screen.builder)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The settings cards share a private widget type; find them by name.
Finder get _cards =>
    find.byWidgetPredicate((w) => w.runtimeType.toString() == '_SettingsCard');

Finder _card(String title) =>
    find.ancestor(of: find.text(title), matching: _cards);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('engine cards (trufi-sanaa#23)', () {
    testWidgets('one routing engine and one map engine: no "Route search" '
        'and no "Map" card', (tester) async {
      await _pumpSettings(tester, routingEngines: 1, mapEngines: 1);

      expect(_card('Language'), findsOneWidget);
      expect(_card('Theme'), findsOneWidget);
      expect(_card('Route search'), findsNothing);
      expect(_card('Map'), findsNothing);
      expect(find.text('Engine 0'), findsNothing);
      expect(find.text('Map 0'), findsNothing);
      expect(_card('Privacy'), findsOneWidget);
      expect(_cards, findsNWidgets(3));
    });

    testWidgets('the hidden cards leave no gap: Theme → Privacy is the '
        'regular 16 px', (tester) async {
      await _pumpSettings(tester, routingEngines: 1, mapEngines: 1);

      final themeBottom = tester.getBottomLeft(_card('Theme')).dy;
      final privacyTop = tester.getTopLeft(_card('Privacy')).dy;
      expect(privacyTop - themeBottom, 16);
    });

    testWidgets('several engines of each kind: both cards, every engine '
        'listed', (tester) async {
      await _pumpSettings(tester, routingEngines: 2, mapEngines: 2);

      expect(_card('Route search'), findsOneWidget);
      expect(find.text('Engine 0'), findsOneWidget);
      expect(find.text('Engine 1'), findsOneWidget);
      expect(_card('Map'), findsOneWidget);
      expect(find.text('Map 0'), findsOneWidget);
      expect(find.text('Map 1'), findsOneWidget);
      expect(_cards, findsNWidgets(5));
    });

    testWidgets('the two cards decide independently', (tester) async {
      await _pumpSettings(tester, routingEngines: 2, mapEngines: 1);
      expect(_card('Route search'), findsOneWidget);
      expect(_card('Map'), findsNothing);

      await _pumpSettings(tester, routingEngines: 1, mapEngines: 2);
      expect(_card('Route search'), findsNothing);
      expect(_card('Map'), findsOneWidget);
    });
  });
}
