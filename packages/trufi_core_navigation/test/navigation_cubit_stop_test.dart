import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';

import 'support/navigation_fixtures.dart';

/// `NavigationScreen.dispose` asks the cubit to stop and closes it in the
/// same breath. Stopping waits for the location tracking to end, so its
/// "idle" state used to be emitted on a cubit that was already closed: an
/// unhandled `StateError` every time the rider left the screen (found by
/// the first widget test of the screen, #1059).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const stops = [
    NavigationStop(id: 'a', name: 'First', position: LatLng(15.35, 44.2)),
    NavigationStop(id: 'b', name: 'Last', position: LatLng(15.35, 44.21)),
  ];
  final route = NavigationRoute(
    id: 'r',
    code: 'R',
    name: 'Route',
    geometry: [for (final stop in stops) stop.position],
    stops: stops,
  );

  Future<NavigationCubit> navigating() async {
    final cubit = NavigationCubit(locationService: FakeLocationService());
    await cubit.startNavigation(route);
    expect(cubit.state.status, NavigationStatus.navigating);
    return cubit;
  }

  group('NavigationCubit.stopNavigation', () {
    test('goes back to idle', () async {
      final cubit = await navigating();
      addTearDown(cubit.close);

      await cubit.stopNavigation();

      expect(cubit.state, const NavigationState());
    });

    test('closing the cubit while it stops does not throw', () async {
      final cubit = await navigating();

      // What NavigationScreen.dispose does.
      final stopped = cubit.stopNavigation();
      final closed = cubit.close();

      await expectLater(stopped, completes);
      await closed;
      expect(cubit.isClosed, isTrue);
    });
  });
}
