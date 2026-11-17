import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'support/navigation_fixtures.dart';

/// `NavigationScreen.dispose` asks the cubit to stop and closes it in the
/// same breath, whatever the cubit is waiting for at that moment. What it
/// emitted once the wait was over landed on a closed cubit: an unhandled
/// `StateError` when the rider left the screen (found by the first widget
/// test of the screen, #1059). It happened with the "idle" state of
/// `stopNavigation`, which waits for the location tracking to end, and
/// with every state of `startNavigation`, which waits for the permission
/// and then for the first position.
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

  /// What NavigationScreen.dispose does.
  Future<void> leaveTheScreen(NavigationCubit cubit) async {
    final stopped = cubit.stopNavigation();
    final closed = cubit.close();
    await stopped;
    await closed;
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

  group('NavigationCubit.startNavigation, when the screen is left while it '
      'says "Starting navigation…"', () {
    /// A cubit that is still starting: the permission is granted or not as
    /// [permission] says, and then it waits for the tracking.
    Future<
      ({NavigationCubit cubit, _SlowLocationService gps, Future<void> starting})
    >
    stillStarting({LocationPermissionStatus? permission}) async {
      final gps = _SlowLocationService();
      if (permission != null) gps.permission.complete(permission);
      final cubit = NavigationCubit(locationService: gps);
      final pending = cubit.startNavigation(route);
      await pumpEventQueue();
      expect(cubit.state.status, NavigationStatus.initializing);
      return (cubit: cubit, gps: gps, starting: pending);
    }

    test('the first position arrives afterwards: nothing is emitted on the '
        'closed cubit and it does not listen to the location', () async {
      final nav = await stillStarting(
        permission: LocationPermissionStatus.granted,
      );
      expect(nav.gps.trackingRequests, 1);

      await leaveTheScreen(nav.cubit);
      nav.gps.tracking.complete(true);

      await expectLater(nav.starting, completes);
      expect(nav.cubit.state.status, NavigationStatus.initializing);
      expect(nav.gps.isListenedTo, isFalse);
    });

    test('the tracking fails to start afterwards: the error is not '
        'emitted on the closed cubit', () async {
      final nav = await stillStarting(
        permission: LocationPermissionStatus.granted,
      );

      await leaveTheScreen(nav.cubit);
      nav.gps.tracking.complete(false);

      await expectLater(nav.starting, completes);
      expect(nav.cubit.state.status, NavigationStatus.initializing);
    });

    test('the permission is granted afterwards: the tracking is not '
        'started for a screen that is gone', () async {
      final nav = await stillStarting();

      await leaveTheScreen(nav.cubit);
      nav.gps.permission.complete(LocationPermissionStatus.granted);
      await pumpEventQueue();

      expect(nav.gps.trackingRequests, 0);
      await expectLater(nav.starting, completes);
      expect(nav.gps.isListenedTo, isFalse);
    });

    test('the permission is denied afterwards: the error is not emitted '
        'on the closed cubit', () async {
      final nav = await stillStarting();

      await leaveTheScreen(nav.cubit);
      nav.gps.permission.complete(LocationPermissionStatus.denied);

      await expectLater(nav.starting, completes);
      expect(nav.cubit.state.status, NavigationStatus.initializing);
      expect(nav.gps.trackingRequests, 0);
    });

    test('a screen that stays gets the navigation started as before', () async {
      final nav = await stillStarting();
      addTearDown(nav.cubit.close);

      nav.gps.permission.complete(LocationPermissionStatus.granted);
      await pumpEventQueue();
      expect(nav.gps.trackingRequests, 1);
      expect(nav.cubit.state.status, NavigationStatus.initializing);

      nav.gps.tracking.complete(true);
      await nav.starting;

      expect(nav.cubit.state.status, NavigationStatus.navigating);
      expect(nav.gps.isListenedTo, isTrue);
    });
  });
}

/// A location service that answers when the test says so: on a device the
/// permission dialog waits for the rider and the tracking for the first
/// position (up to 10 s).
class _SlowLocationService extends FakeLocationService {
  final permission = Completer<LocationPermissionStatus>();
  final tracking = Completer<bool>();

  /// How many times the tracking was asked to start.
  int trackingRequests = 0;

  /// Whether anything listens to the location updates.
  bool get isListenedTo => hasListeners;

  @override
  Future<LocationPermissionStatus> requestPermission() => permission.future;

  @override
  Future<bool> startTracking({int distanceFilter = 10, Object? accuracy}) {
    trackingRequests++;
    return tracking.future;
  }
}
