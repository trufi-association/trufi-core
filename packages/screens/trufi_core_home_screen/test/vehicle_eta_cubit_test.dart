import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'support/vehicle_eta_fakes.dart';

/// #1004: one request per plan for the FIRST boarding vehicle of every
/// itinerary, a 12 s throttle on manual refresh that never re-plans, and
/// stale answers dropped after clear/new plan.
void main() {
  late FakeVehicleEtaProvider provider;
  late DateTime now;
  late VehicleEtaCubit cubit;

  setUp(() {
    provider = FakeVehicleEtaProvider();
    now = etaT0;
    cubit = VehicleEtaCubit(provider: provider, now: () => now);
  });

  tearDown(() => cubit.close());

  group('loadForPlan', () {
    test('asks once for the first boarding vehicle of every ride', () async {
      provider.answer = (_) => [eta('1:A', 240), eta('1:C', 600)];

      await cubit.loadForPlan(threeRidesPlan(), etaOrigin);

      expect(provider.calls, 1);
      final request = provider.requests.single;
      expect(request.origin, etaOrigin);
      expect(
        request.routeIds,
        {'1:A', '1:C'},
        reason:
            'B is a connection, not the bus the rider waits for; the '
            'walk-only ride adds nothing',
      );
      expect(request.stopIds, {'sA', 'sC'});
      expect(
        request.boardingPoints,
        {
          '1:A': const TrufiLatLng(-17.39, -66.15),
          '1:C': const TrufiLatLng(-17.39, -66.15),
        },
        reason: 'the source measures to the boarding stop, not to the rider',
      );

      final state = cubit.state;
      expect(state.status, VehicleEtaStatus.ready);
      expect(state.hasRequest, isTrue);
      expect(state.etaFor('1:A')?.eta, const Duration(seconds: 240));
      expect(
        state.etaFor('A')?.eta,
        const Duration(seconds: 240),
        reason: 'keys are feed-prefix agnostic',
      );
      expect(state.etaFor('1:B'), isNull);
      expect(state.fetchedAt, provider.fetchedAt);
      expect(
        state.nextAllowedAt,
        etaT0.add(const Duration(seconds: 12)),
        reason: 'the cooldown is armed when the request starts',
      );
      expect(state.error, isNull);
    });

    test('an empty answer is "unavailable", not an error', () async {
      await cubit.loadForPlan(threeRidesPlan(), etaOrigin);
      expect(cubit.state.status, VehicleEtaStatus.unavailable);
      expect(cubit.state.etasByRoute, isEmpty);
      expect(cubit.state.hasRequest, isTrue);
    });

    test('a failing provider leaves "error" with no estimates', () async {
      provider.failure = const VehicleEtaException('down', statusCode: 503);
      await cubit.loadForPlan(threeRidesPlan(), etaOrigin);
      expect(cubit.state.status, VehicleEtaStatus.error);
      expect(cubit.state.etasByRoute, isEmpty);
      expect(cubit.state.error, contains('503'));
      expect(cubit.state.hasRequest, isTrue);
    });

    test('a walk-only plan resets without calling the provider', () async {
      await cubit.loadForPlan(
        routing.Plan(
          itineraries: [
            itinerary([walkLeg()]),
          ],
        ),
        etaOrigin,
      );
      expect(provider.calls, 0);
      expect(cubit.state, const VehicleEtaState());
    });

    test('a newer plan supersedes the previous in-flight answer', () async {
      provider.gate = Completer();
      final first = cubit.loadForPlan(threeRidesPlan(), etaOrigin);

      provider.gate = null;
      provider.answer = (_) => [eta('1:X', 60)];
      await cubit.loadForPlan(
        routing.Plan(
          itineraries: [
            itinerary([busLeg('X')]),
          ],
        ),
        etaOrigin,
      );
      expect(cubit.state.etaFor('X'), isNotNull);

      // The old reply lands late with the old plan's routes.
      final oldGate = provider.requests.first;
      expect(oldGate.routeIds, {'1:A', '1:C'});
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.etaFor('X'), isNotNull);
      expect(cubit.state.etaFor('A'), isNull);
      // Let the first call finish so the test leaves no dangling future.
      unawaited(first);
    });
  });

  group('refresh', () {
    test('is throttled within the cooldown and re-sends the stored '
        'request afterwards', () async {
      provider.answer = (_) => [eta('1:A', 240)];
      await cubit.loadForPlan(threeRidesPlan(), etaOrigin);
      final before = cubit.state;

      now = etaT0.add(const Duration(seconds: 5));
      await cubit.refresh();
      expect(provider.calls, 1, reason: 'inside the cooldown nothing is sent');
      expect(cubit.state, same(before), reason: 'and nothing is emitted');

      now = etaT0.add(const Duration(seconds: 12));
      await cubit.refresh();
      expect(provider.calls, 2);
      expect(
        provider.requests[1],
        provider.requests[0],
        reason: 'the same request again — a refresh never re-plans',
      );
      expect(cubit.state.status, VehicleEtaStatus.ready);
      expect(cubit.state.nextAllowedAt, etaT0.add(const Duration(seconds: 24)));
    });

    test('is ignored while a request is in flight', () async {
      provider.gate = Completer();
      final load = cubit.loadForPlan(threeRidesPlan(), etaOrigin);
      expect(cubit.state.status, VehicleEtaStatus.loading);

      now = etaT0.add(const Duration(minutes: 1));
      await cubit.refresh();
      expect(provider.calls, 1, reason: 'no duplicate request');

      provider.gate!.complete(
        VehicleEtaSnapshot(etas: [eta('1:A', 60)], fetchedAt: etaT0),
      );
      await load;
      expect(cubit.state.status, VehicleEtaStatus.ready);
    });

    test('keeps the previous estimates while loading', () async {
      provider.answer = (_) => [eta('1:A', 240)];
      await cubit.loadForPlan(threeRidesPlan(), etaOrigin);

      provider.gate = Completer();
      now = etaT0.add(const Duration(seconds: 12));
      final refresh = cubit.refresh();
      expect(cubit.state.status, VehicleEtaStatus.loading);
      expect(
        cubit.state.etaFor('A'),
        isNotNull,
        reason: 'the badge dims the old value instead of flashing a spinner',
      );
      expect(cubit.state.fetchedAt, etaT0);

      provider.gate!.complete(VehicleEtaSnapshot.empty(now));
      await refresh;
      expect(cubit.state.status, VehicleEtaStatus.unavailable);
      expect(cubit.state.etasByRoute, isEmpty);
      expect(cubit.state.fetchedAt, now);
    });

    test('does nothing before any plan was loaded', () async {
      await cubit.refresh();
      expect(provider.calls, 0);
      expect(cubit.state, const VehicleEtaState());
    });
  });

  group('clear', () {
    test('resets the state and drops an in-flight answer', () async {
      provider.gate = Completer();
      final load = cubit.loadForPlan(threeRidesPlan(), etaOrigin);

      cubit.clear();
      expect(cubit.state, const VehicleEtaState());

      provider.gate!.complete(
        VehicleEtaSnapshot(etas: [eta('1:A', 60)], fetchedAt: etaT0),
      );
      await load;
      expect(
        cubit.state.status,
        VehicleEtaStatus.idle,
        reason: 'a stale answer must not resurrect cleared badges',
      );
      expect(cubit.state.hasRequest, isFalse);
    });
  });

  group('useProvider (#1018: the source follows the routing engine)', () {
    test(
      'without a source a plan leaves the cubit idle (badges hidden)',
      () async {
        final bare = VehicleEtaCubit(now: () => now);
        addTearDown(bare.close);

        await bare.loadForPlan(threeRidesPlan(), etaOrigin);

        expect(bare.provider, isNull);
        expect(bare.state, const VehicleEtaState());
        expect(bare.state.hasRequest, isFalse);
      },
    );

    test('a source handed later re-asks for the last plan', () async {
      final bare = VehicleEtaCubit(now: () => now);
      addTearDown(bare.close);
      await bare.loadForPlan(threeRidesPlan(), etaOrigin);
      provider.answer = (_) => [eta('1:A', 240)];

      bare.useProvider(provider);
      await Future<void>.delayed(Duration.zero);

      expect(provider.calls, 1);
      expect(bare.state.status, VehicleEtaStatus.ready);
      expect(bare.state.etaFor('1:A')?.eta, const Duration(seconds: 240));
    });

    test(
      'null hides the estimates; the same source again is a no-op',
      () async {
        provider.answer = (_) => [eta('1:A', 240)];
        await cubit.loadForPlan(threeRidesPlan(), etaOrigin);
        expect(cubit.state.status, VehicleEtaStatus.ready);

        cubit.useProvider(null);

        expect(cubit.state, const VehicleEtaState(), reason: 'idle = hidden');
        expect(cubit.provider, isNull);

        cubit.useProvider(null);
        expect(provider.calls, 1, reason: 'nothing to re-ask without a source');

        cubit.useProvider(provider);
        await Future<void>.delayed(Duration.zero);
        expect(provider.calls, 2, reason: 'the engine came back: ask again');
        expect(cubit.state.status, VehicleEtaStatus.ready);

        cubit.useProvider(provider);
        expect(provider.calls, 2, reason: 'identical source: no request');
      },
    );

    test('a new source supersedes the old one, even mid-flight', () async {
      final slow = FakeVehicleEtaProvider()..gate = Completer();
      final fast = FakeVehicleEtaProvider()..answer = (_) => [eta('1:A', 120)];
      final c = VehicleEtaCubit(provider: slow, now: () => now);
      addTearDown(c.close);
      final pending = c.loadForPlan(threeRidesPlan(), etaOrigin);
      expect(c.state.status, VehicleEtaStatus.loading);

      c.useProvider(fast);
      await Future<void>.delayed(Duration.zero);
      expect(fast.calls, 1);
      expect(c.state.etaFor('1:A')?.eta, const Duration(seconds: 120));

      slow.gate!.complete(
        VehicleEtaSnapshot(etas: [eta('1:A', 900)], fetchedAt: etaT0),
      );
      await pending;
      expect(
        c.state.etaFor('1:A')?.eta,
        const Duration(seconds: 120),
        reason: 'the previous engine answer must not overwrite the new one',
      );
    });

    test('a new source starts from a blank state', () async {
      final a = FakeVehicleEtaProvider()..answer = (_) => [eta('1:A', 240)];
      final b = FakeVehicleEtaProvider()..gate = Completer();
      final c = VehicleEtaCubit(provider: a, now: () => now);
      addTearDown(c.close);
      await c.loadForPlan(threeRidesPlan(), etaOrigin);
      expect(c.state.status, VehicleEtaStatus.ready);

      c.useProvider(b);
      await Future<void>.delayed(Duration.zero);

      expect(b.calls, 1);
      expect(c.state.status, VehicleEtaStatus.loading);
      expect(c.state.hasRequest, isTrue);
      expect(
        c.state.etaFor('1:A'),
        isNull,
        reason:
            'the estimate of the engine just left must not survive the '
            'switch as "stale" while the new source answers',
      );
      expect(c.state.fetchedAt, isNull);
      expect(
        EtaBadge.kindFor(c.state.status, c.state.etaFor('1:A')),
        EtaBadgeKind.loading,
        reason: 'the badge spins instead of dimming the old value',
      );

      b.gate!.complete(VehicleEtaSnapshot.empty(now));
      await Future<void>.delayed(Duration.zero);
      expect(c.state.status, VehicleEtaStatus.unavailable);
    });

    test('clear forgets the plan: a later source has nothing to ask', () async {
      await cubit.loadForPlan(threeRidesPlan(), etaOrigin);
      cubit.clear();
      final other = FakeVehicleEtaProvider();

      cubit.useProvider(other);
      await Future<void>.delayed(Duration.zero);

      expect(other.calls, 0);
      expect(cubit.state, const VehicleEtaState());
    });
  });

  group('buildVehicleEtaRequest', () {
    test('falls back to route.id and skips legs without any id', () {
      final plan = routing.Plan(
        itineraries: [
          itinerary([busLeg('X', gtfsId: null, id: 'x-id')]),
          itinerary([busLeg('Y', gtfsId: null, id: '')]),
          itinerary([busLeg('Z', gtfsId: null, stopId: null)]),
        ],
      );
      final request = buildVehicleEtaRequest(plan, etaOrigin);
      expect(request?.routeIds, {'x-id'});
      expect(request?.stopIds, {'sX'});
    });

    test('omits the stop hint when no boarding stop carries an id', () {
      final plan = routing.Plan(
        itineraries: [
          itinerary([busLeg('A', stopId: null)]),
        ],
      );
      final request = buildVehicleEtaRequest(plan, etaOrigin);
      expect(request?.stopIds, isNull);
      expect(
        request?.boardingPoints,
        isNull,
        reason: 'no fromPlace → nothing to measure to but the origin',
      );
      expect(request?.pointFor('1:A'), etaOrigin);
    });

    test('carries the boarding stop of each route; the first ride wins', () {
      final plan = routing.Plan(
        itineraries: [
          itinerary([walkLeg(), busLeg('A', stopLat: -17.40, stopLon: -66.16)]),
          // Same route, boarded at another stop: the preferred ride wins.
          itinerary([
            walkLeg(),
            busLeg('A', stopId: 'sA2', stopLat: -17.41, stopLon: -66.17),
          ]),
          itinerary([busLeg('B', stopId: null)]),
        ],
      );
      final request = buildVehicleEtaRequest(plan, etaOrigin)!;
      expect(request.routeIds, {'1:A', '1:B'});
      expect(request.stopIds, {'sA', 'sA2'});
      expect(request.boardingPoints, {
        '1:A': const TrufiLatLng(-17.40, -66.16),
      });
      expect(
        request.pointFor('A'),
        const TrufiLatLng(-17.40, -66.16),
        reason: 'bare lookup must find the prefixed key',
      );
      expect(
        request.pointFor('1:B'),
        etaOrigin,
        reason: 'a route without a boarding stop falls back to the origin',
      );
    });

    test('carries the boarding direction of each route; the first ride '
        'wins (#1016)', () {
      final plan = routing.Plan(
        itineraries: [
          // No boarding stop: contributes neither a point nor a direction,
          // so the two always come from the same ride.
          itinerary([busLeg('A', stopId: null, directionId: 0)]),
          itinerary([
            walkLeg(),
            busLeg('A', directionId: 1, stopLat: -17.40, stopLon: -66.16),
          ]),
          // Same route the other way, boarded elsewhere: the preferred ride
          // already set both.
          itinerary([
            busLeg(
              'A',
              stopId: 'sA2',
              directionId: 0,
              stopLat: -17.41,
              stopLon: -66.17,
            ),
          ]),
          itinerary([busLeg('B')]),
        ],
      );
      final request = buildVehicleEtaRequest(plan, etaOrigin)!;
      expect(
        request.directions,
        {'1:A': 1},
        reason: 'B reports no direction_id; A takes the first ride with a stop',
      );
      expect(
        request.boardingPoints?['1:A'],
        const TrufiLatLng(-17.40, -66.16),
        reason: 'the direction and the stop come from the same ride',
      );
      expect(
        request.directionFor('A'),
        1,
        reason: 'bare lookup must find the prefixed key',
      );
      expect(request.directionFor('1:B'), isNull);
    });

    test('omits the directions when no leg reports a direction_id', () {
      final request = buildVehicleEtaRequest(threeRidesPlan(), etaOrigin)!;
      expect(request.directions, isNull);
      expect(request.directionFor('1:A'), isNull);
    });

    test('returns null for an empty plan', () {
      expect(buildVehicleEtaRequest(const routing.Plan(), etaOrigin), isNull);
    });
  });

  group('VehicleEtaState', () {
    test('cooldownRemaining and canRefreshAt', () {
      final state = VehicleEtaState(
        status: VehicleEtaStatus.ready,
        nextAllowedAt: etaT0.add(const Duration(seconds: 12)),
        hasRequest: true,
      );
      expect(state.cooldownRemaining(etaT0), const Duration(seconds: 12));
      expect(
        state.cooldownRemaining(etaT0.add(const Duration(seconds: 20))),
        Duration.zero,
      );
      expect(state.canRefreshAt(etaT0), isFalse);
      expect(
        state.canRefreshAt(etaT0.add(const Duration(seconds: 12))),
        isTrue,
      );
      expect(
        state
            .copyWith(status: VehicleEtaStatus.loading)
            .canRefreshAt(etaT0.add(const Duration(seconds: 12))),
        isFalse,
      );
      expect(const VehicleEtaState().canRefreshAt(etaT0), isFalse);
    });
  });
}
