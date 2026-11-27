import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart' show LatLngBounds;
import 'package:trufi_core_navigation/trufi_core_navigation.dart';

import 'support/navigation_fixtures.dart';

/// The start stop of a trip begun outside the service area is recomputed on
/// the first fix inside it only when that fix is within the off-route
/// threshold of the nearest stop (trufi-lima#12).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const area = LatLngBounds(LatLng(15.34, 44.19), LatLng(15.351, 44.205));
  const config = NavigationConfig(serviceArea: area, offRouteThreshold: 50);
  final route = ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary());
  final node10 = route.stops.indexWhere(
    (stop) => stop.name == SanaaTrip.nodeName(10),
  );

  Future<({NavigationCubit cubit, FakeLocationService gps})>
  startOutside() async {
    final gps = FakeLocationService(initial: SanaaTrip.destination);
    final cubit = NavigationCubit(locationService: gps, config: config);
    addTearDown(cubit.close);
    await cubit.startNavigation(route);
    return (cubit: cubit, gps: gps);
  }

  // About 111 m south of way node 10, inside the area.
  const farFromTrip = LatLng(15.349, 44.2025);

  test(
    'first fix inside, nearest stop within the threshold: that stop',
    () async {
      final run = await startOutside();

      run.gps.moveTo(SanaaTrip.node(10));

      expect(run.cubit.state.currentStopIndex, greaterThanOrEqualTo(node10));
    },
  );

  test('first fix inside, nearest stop beyond the threshold: the first stop '
      'is kept and forward progress takes over', () async {
    final run = await startOutside();

    run.gps.moveTo(farFromTrip);
    expect(run.cubit.state.currentStopIndex, 0);

    run.gps.moveTo(SanaaTrip.node(10));
    expect(run.cubit.state.currentStopIndex, greaterThanOrEqualTo(node10));
  });
}
