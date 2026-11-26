import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart'
    show LiveBusBadge;

import 'support/vehicle_eta_fakes.dart';

/// trufi-lima#13 follow-ups: a refresh keeps what the last answer said about
/// which routes have vehicles, and the live dot follows that knowledge.
class _GatedSource implements VehicleEtaProvider {
  _GatedSource(this.routesWithVehicles);
  final Set<String> routesWithVehicles;
  Completer<VehicleEtaSnapshot>? gate;

  @override
  Future<VehicleEtaSnapshot> fetchEtas(VehicleEtaRequest request) async {
    final pending = gate;
    if (pending != null) return pending.future;
    return VehicleEtaSnapshot(
      etas: const [],
      fetchedAt: etaT0,
      routesWithVehicles: routesWithVehicles,
    );
  }
}

class _FakeRealtime implements RealtimeVehiclesProvider {
  _FakeRealtime(this.latest);
  @override
  final List<VehiclePosition> latest;
  @override
  Stream<List<VehiclePosition>> get positionsStream => const Stream.empty();
  @override
  Future<void> start() async {}
  @override
  void stop() {}
}

void main() {
  final bus123 = itinerary([walkLeg(), busLeg('123')]);
  final bus999 = itinerary([walkLeg(), busLeg('999')]);
  final plan = routing.Plan(itineraries: [bus123, bus999]);

  group('a refresh keeps routesWithVehicles', () {
    test(
      'a route known to have no vehicles stays noLiveData while loading',
      () async {
        final source = _GatedSource({'1:123'});
        final cubit = VehicleEtaCubit(
          provider: source,
          cooldown: Duration.zero,
          now: () => etaT0,
        );
        addTearDown(cubit.close);
        await cubit.loadForPlan(plan, etaOrigin);
        expect(cubit.state.statusFor('1:999'), VehicleEtaStatus.noLiveData);

        source.gate = Completer<VehicleEtaSnapshot>();
        final refreshing = cubit.refresh();

        expect(cubit.state.status, VehicleEtaStatus.loading);
        expect(cubit.state.statusFor('1:999'), VehicleEtaStatus.noLiveData);
        expect(
          cubit.state.statusFor('1:123'),
          VehicleEtaStatus.loading,
          reason: 'a route with vehicles still shows the loading state',
        );
        source.gate!.complete(
          VehicleEtaSnapshot(etas: const [], fetchedAt: etaT0),
        );
        await refreshing;
      },
    );

    test('a new plan does not inherit what the last plan knew', () async {
      final source = _GatedSource({'1:123'});
      final cubit = VehicleEtaCubit(
        provider: source,
        cooldown: Duration.zero,
        now: () => etaT0,
      );
      addTearDown(cubit.close);
      await cubit.loadForPlan(plan, etaOrigin);
      expect(cubit.state.statusFor('1:999'), VehicleEtaStatus.noLiveData);

      source.gate = Completer<VehicleEtaSnapshot>();
      final loading = cubit.loadForPlan(
        routing.Plan(itineraries: [bus999]),
        etaOrigin,
      );

      expect(cubit.state.status, VehicleEtaStatus.loading);
      expect(cubit.state.routesWithVehicles, isNull);
      expect(cubit.state.statusFor('1:999'), VehicleEtaStatus.loading);
      source.gate!.complete(
        VehicleEtaSnapshot(etas: const [], fetchedAt: etaT0),
      );
      await loading;
    });

    test('the first load, with nothing known, is loading for every route', () {
      final source = _GatedSource({'1:123'})
        ..gate = Completer<VehicleEtaSnapshot>();
      final cubit = VehicleEtaCubit(provider: source, now: () => etaT0);
      addTearDown(cubit.close);

      unawaited(cubit.loadForPlan(plan, etaOrigin));

      expect(cubit.state.statusFor('1:999'), VehicleEtaStatus.loading);
    });
  });

  group('the live dot follows the live stream', () {
    // The stream rule reads the clock, so the timestamps are relative to it.
    VehiclePosition bus(String route, {Duration age = Duration.zero}) =>
        VehiclePosition(
          vehicleId: 'bus-$route-${age.inMinutes}',
          position: const TrufiLatLng(-17.39, -66.15),
          routeId: route,
          timestamp: DateTime.now().subtract(age),
        );

    // The only bus of route 123 reported 10 min ago: older than the 5 min
    // default of maxVehicleAge.
    final staleFleet = [bus('1:123', age: const Duration(minutes: 10))];

    Widget host(
      VehicleEtaCubit cubit,
      RealtimeVehiclesProvider realtime, {
      routing.Itinerary? shown,
    }) => MultiProvider(
      providers: [
        BlocProvider<VehicleEtaCubit>.value(value: cubit),
        Provider<RealtimeVehiclesProvider?>.value(value: realtime),
      ],
      child: MaterialApp(
        localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
        supportedLocales: HomeScreenLocalizations.supportedLocales,
        home: Scaffold(
          body: ItineraryCard(
            itinerary: shown ?? bus123,
            isSelected: false,
            onTap: () {},
          ),
        ),
      ),
    );

    testWidgets('a route whose only vehicle is older than 5 min has neither '
        'badge nor dot', (tester) async {
      final realtime = _FakeRealtime(staleFleet);
      final cubit = VehicleEtaCubit(
        provider: routing.RealtimeVehiclesEtaProvider(
          vehicles: realtime,
          now: DateTime.now,
        ),
        now: () => etaT0,
      );
      addTearDown(cubit.close);
      await cubit.loadForPlan(routing.Plan(itineraries: [bus123]), etaOrigin);

      await tester.pumpWidget(host(cubit, realtime));

      expect(find.byType(LiveBusBadge), findsNothing);
      expect(find.text('No buses nearby right now'), findsNothing);
      expect(find.textContaining('Arrives'), findsNothing);
    });

    testWidgets('with no ETA answer yet, the provider data lights the dot', (
      tester,
    ) async {
      final cubit = VehicleEtaCubit(
        provider: _GatedSource({}),
        now: () => etaT0,
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(host(cubit, _FakeRealtime([bus('1:123')])));

      expect(find.byType(LiveBusBadge), findsOneWidget);
    });

    testWidgets('a transfer leg the ETA request skips still shows its dot', (
      tester,
    ) async {
      final twoLegs = itinerary([walkLeg(), busLeg('A'), busLeg('B')]);
      final realtime = _FakeRealtime([bus('1:B')]);
      final cubit = VehicleEtaCubit(
        provider: routing.RealtimeVehiclesEtaProvider(
          vehicles: realtime,
          now: DateTime.now,
        ),
        now: () => etaT0,
      );
      addTearDown(cubit.close);
      await cubit.loadForPlan(routing.Plan(itineraries: [twoLegs]), etaOrigin);
      expect(
        cubit.state.routesWithVehicles,
        isEmpty,
        reason: 'the request asked about A only, which has no bus',
      );

      await tester.pumpWidget(host(cubit, realtime, shown: twoLegs));

      expect(find.byType(LiveBusBadge), findsOneWidget);
    });
  });
}
