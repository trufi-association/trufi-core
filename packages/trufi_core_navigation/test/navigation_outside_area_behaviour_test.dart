import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart' show LatLngBounds;
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'support/navigation_fixtures.dart';
import 'support/navigation_screen_harness.dart';

/// trufi-lima#12 follow-ups, with the rider outside the service area:
/// - the instruction's distance is hidden when `showStops` is off;
/// - the trip starts at its first stop, not at the stop nearest the GPS, and
///   looks for the nearest one once, on the first fix inside the area;
/// - the off-route banner and its vibration give way to the outside notice.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final realWakelock = wakelockPlusPlatformInstance;
  setUp(() => wakelockPlusPlatformInstance = NoWakelock());
  tearDown(() => wakelockPlusPlatformInstance = realWakelock);

  group('showStops off, rider outside: no distance in the instruction', () {
    const config = NavigationConfig(serviceArea: sanaaArea, showStops: false);

    testWidgets('far away: no "km" anywhere', (tester) async {
      await startSanaaNavigation(tester, rider: farAway, config: config);

      expect(find.textContaining('km'), findsNothing);
      expect(distanceFigure, findsNothing);
    });

    testWidgets('known positive: inside, the instruction carries a distance', (
      tester,
    ) async {
      await startSanaaNavigation(
        tester,
        rider: SanaaTrip.origin,
        config: config,
      );

      expect(distanceFigure, findsWidgets);
    });
  });

  group('the start stop of a trip begun outside the service area', () {
    // The trip's first kilometre: the destination is outside it.
    const area = LatLngBounds(LatLng(15.34, 44.19), LatLng(15.351, 44.205));
    const config = NavigationConfig(serviceArea: area);
    final route = ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary());
    final node10 = route.stops.indexWhere(
      (stop) => stop.name == SanaaTrip.nodeName(10),
    );

    Future<({NavigationCubit cubit, FakeLocationService gps})> start(
      LatLng rider,
    ) async {
      final gps = FakeLocationService(initial: rider);
      final cubit = NavigationCubit(locationService: gps, config: config);
      addTearDown(cubit.close);
      await cubit.startNavigation(route);
      expect(cubit.state.status, NavigationStatus.navigating);
      return (cubit: cubit, gps: gps);
    }

    test('fixture: way node 10 is a stop of the route', () {
      expect(node10, greaterThan(0));
    });

    test('known positive: from inside it is the stop nearest the GPS', () async {
      final run = await start(SanaaTrip.node(10));

      expect(run.cubit.state.currentStopIndex, node10);
    });

    test('from outside, nearest to the last stop: the first stop', () async {
      final run = await start(SanaaTrip.destination);

      expect(run.cubit.state.currentStopIndex, 0);
      expect(run.cubit.state.remainingStops, route.stops.length - 1);
    });

    test('the first fix inside the area picks the nearest stop, once', () async {
      final run = await start(SanaaTrip.destination);

      run.gps.moveTo(SanaaTrip.node(10));
      final afterFirstFix = run.cubit.state.currentStopIndex;
      expect(afterFirstFix, greaterThanOrEqualTo(node10));

      run.gps.moveTo(SanaaTrip.origin);
      expect(
        run.cubit.state.currentStopIndex,
        afterFirstFix,
        reason: 'the start is recomputed once, not on every fix',
      );
    });

    test('fixes outside keep the first stop', () async {
      final run = await start(SanaaTrip.destination);

      run.gps.moveTo(farAway);

      expect(run.cubit.state.currentStopIndex, 0);
    });
  });

  group('off route, rider outside the service area', () {
    final heavy = <MethodCall>[];

    setUp(() {
      heavy.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate' &&
                call.arguments == 'HapticFeedbackType.heavyImpact') {
              heavy.add(call);
            }
            return null;
          });
    });
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    final route = ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary());
    // Inside the area, 550 m south of the route.
    const offRouteInside = LatLng(15.345, 44.2);

    Future<({NavigationCubit cubit, FakeLocationService gps})> start({
      required NavigationConfig config,
    }) async {
      final gps = FakeLocationService(initial: SanaaTrip.origin);
      final cubit = NavigationCubit(locationService: gps, config: config);
      addTearDown(cubit.close);
      await cubit.startNavigation(route);
      return (cubit: cubit, gps: gps);
    }

    test('known positive: without an area, a far fix is off route and '
        'vibrates', () async {
      final run = await start(config: const NavigationConfig());

      run.gps.moveTo(farAway);

      expect(run.cubit.state.isOffRoute, isTrue);
      expect(heavy, hasLength(1));
    });

    test('known positive: inside the area, off route still warns and '
        'vibrates', () async {
      final run = await start(
        config: const NavigationConfig(serviceArea: sanaaArea),
      );

      run.gps.moveTo(offRouteInside);

      expect(run.cubit.state.isOffRoute, isTrue);
      expect(heavy, hasLength(1));
    });

    test('a fix outside the area: not off route, no vibration', () async {
      final run = await start(
        config: const NavigationConfig(serviceArea: sanaaArea),
      );

      run.gps.moveTo(farAway);

      expect(run.cubit.state.isOffRoute, isFalse);
      expect(heavy, isEmpty);
    });

    test('off route inside, then outside: the warning is dropped', () async {
      final run = await start(
        config: const NavigationConfig(serviceArea: sanaaArea),
      );
      run.gps.moveTo(offRouteInside);
      expect(run.cubit.state.isOffRoute, isTrue);
      heavy.clear();

      run.gps.moveTo(farAway);

      expect(run.cubit.state.isOffRoute, isFalse);
      expect(heavy, isEmpty);
    });
  });
}
