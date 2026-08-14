import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Fake provider that records the arguments it receives from the manager.
class _RecordingProvider extends IRoutingProvider {
  int? capturedNumItineraries;

  @override
  String get id => 'recording';

  @override
  String get name => 'Recording';

  @override
  String get description => 'Captures fetchPlan arguments';

  @override
  bool get supportsTransitRoutes => false;

  @override
  bool get requiresInternet => true;

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 10,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async {
    capturedNumItineraries = numItineraries;
    return Plan(itineraries: []);
  }

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

  group('RoutingEngineManager fetchPlan', () {
    test('keeps the historical default of 5 itineraries', () async {
      // Deliberately unchanged by #737: raising the pool only pays off on
      // providers without server-side duplicate filtering, so apps opt in
      // per deploy instead of every OTP2 app paying a ~3x payload.
      final provider = _RecordingProvider();
      final manager = RoutingEngineManager(engines: [provider]);

      await manager.fetchPlan(
        from: RoutingLocation(
          position: const LatLng(-17.39, -66.15),
          description: 'A',
        ),
        to: RoutingLocation(
          position: const LatLng(-17.40, -66.16),
          description: 'B',
        ),
        dateTime: DateTime(2026, 1, 1, 12),
      );

      expect(provider.capturedNumItineraries, 5);
    });

    test('forwards an explicit numItineraries unchanged', () async {
      final provider = _RecordingProvider();
      final manager = RoutingEngineManager(engines: [provider]);

      await manager.fetchPlan(
        from: RoutingLocation(
          position: const LatLng(-17.39, -66.15),
          description: 'A',
        ),
        to: RoutingLocation(
          position: const LatLng(-17.40, -66.16),
          description: 'B',
        ),
        numItineraries: 3,
        dateTime: DateTime(2026, 1, 1, 12),
      );

      expect(provider.capturedNumItineraries, 3);
    });

    test('uses the app-level maxItineraries override as the default '
        '(issue #923: Cochabamba requests 20)', () async {
      final provider = _RecordingProvider();
      final manager = RoutingEngineManager(
        engines: [provider],
        maxItineraries: 20,
      );

      await manager.fetchPlan(
        from: RoutingLocation(
          position: const LatLng(-17.39, -66.15),
          description: 'A',
        ),
        to: RoutingLocation(
          position: const LatLng(-17.40, -66.16),
          description: 'B',
        ),
        dateTime: DateTime(2026, 1, 1, 12),
      );

      expect(provider.capturedNumItineraries, 20);
    });

    test('an explicit numItineraries wins over maxItineraries', () async {
      final provider = _RecordingProvider();
      final manager = RoutingEngineManager(
        engines: [provider],
        maxItineraries: 20,
      );

      await manager.fetchPlan(
        from: RoutingLocation(
          position: const LatLng(-17.39, -66.15),
          description: 'A',
        ),
        to: RoutingLocation(
          position: const LatLng(-17.40, -66.16),
          description: 'B',
        ),
        numItineraries: 3,
        dateTime: DateTime(2026, 1, 1, 12),
      );

      expect(provider.capturedNumItineraries, 3);
    });
  });
}
