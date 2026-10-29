import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// #1018: each routing engine owns its live-ETA source. OTP 2.8 derives one
/// from its GTFS-RT positions when live vehicles are on; the interface
/// default is "none", so engines without telemetry hide the badges.
class _BareProvider extends IRoutingProvider {
  @override
  String get id => 'bare';
  @override
  String get name => 'Bare';
  @override
  String get description => 'No telemetry';
  @override
  bool get supportsTransitRoutes => true;
  @override
  bool get requiresInternet => false;
  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 10,
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
  test('an engine without telemetry has no ETA source by default', () {
    expect(_BareProvider().vehicleEtaProvider, isNull);
  });

  test('OTP 2.8 with live vehicles off has no ETA source', () {
    final otp = Otp28RoutingProvider(endpoint: 'https://otp.test/otp');
    expect(otp.realtimeVehiclesProvider, isNull);
    expect(otp.vehicleEtaProvider, isNull);
  });

  test('OTP 2.8 with live vehicles on derives one ETA source over its own '
      'positions provider, built once', () {
    final otp = Otp28RoutingProvider(
      endpoint: 'https://otp.test/otp',
      liveVehiclesEnabled: true,
    );
    final source = otp.vehicleEtaProvider;
    expect(source, isA<RealtimeVehiclesEtaProvider>());
    expect(
      (source! as RealtimeVehiclesEtaProvider).vehicles,
      same(otp.realtimeVehiclesProvider),
    );
    expect(otp.vehicleEtaProvider, same(source));
  });
}
