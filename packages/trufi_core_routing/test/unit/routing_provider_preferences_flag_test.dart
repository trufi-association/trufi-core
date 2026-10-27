import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// trufi-sanaa#23: the home screen's route-settings button follows
/// [IRoutingProvider.hasConfigurablePreferences]. Pins what every bundled
/// provider declares, so a provider that gains (or loses) a preferences
/// form has to say so here too.

/// A provider that overrides nothing optional: no preferences UI at all.
class _BareProvider extends IRoutingProvider {
  @override
  String get id => 'bare';
  @override
  String get name => 'Bare';
  @override
  String get description => 'Overrides only what the interface requires';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('a provider that overrides nothing keeps its button', () {
    // Opt-out default: adding the flag changed nothing for providers written
    // before it. Forgetting to override costs an empty sheet, never a form.
    final provider = _BareProvider();
    expect(provider.hasConfigurablePreferences, isTrue);
  });

  test('the Trufi planner declares no configurable preferences', () {
    // Its panel is informational (what the engine is, that it works
    // offline): the single-engine deploy of trufi-sanaa must get no button.
    final local = TrufiPlannerProvider(
      config: const TrufiPlannerConfig.local(gtfsAsset: 'assets/gtfs.zip'),
    );
    final remote = TrufiPlannerProvider(
      config: const TrufiPlannerConfig.remote(
        serverUrl: 'https://planner.example.org',
      ),
    );
    expect(local.hasConfigurablePreferences, isFalse);
    expect(remote.hasConfigurablePreferences, isFalse);
  });

  testWidgets('the Trufi planner still ships its informational panel', (
    tester,
  ) async {
    // Multi-engine apps open the sheet to switch engines and see this panel
    // for the planner: hiding the button must not have removed it.
    final provider = TrufiPlannerProvider(
      config: const TrufiPlannerConfig.local(gtfsAsset: 'assets/gtfs.zip'),
    );
    Widget? panel;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          panel = provider.buildPreferencesUI(context);
          return const SizedBox.shrink();
        },
      ),
    );
    expect(panel, isNotNull);
  });

  test('the OTP providers expose a preferences form', () {
    // They ship a form and inherit the default; nothing to override.
    expect(
      Otp28RoutingProvider(
        endpoint: 'https://otp.example.org',
      ).hasConfigurablePreferences,
      isTrue,
    );
    expect(
      Otp24RoutingProvider(
        endpoint: 'https://otp.example.org',
      ).hasConfigurablePreferences,
      isTrue,
    );
    expect(
      Otp15RoutingProvider(
        endpoint: 'https://otp.example.org',
      ).hasConfigurablePreferences,
      isTrue,
    );
  });
}
