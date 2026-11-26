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

/// trufi-lima#13 on the itinerary card, decided per route:
/// - no vehicle of the route in the snapshot: no badge, no live dot;
/// - vehicles of the route, none heading to the stop: "No buses nearby right
///   now";
/// - a bus coming: "Arrives in ~N min" (unchanged);
/// and the live dot, when shown, explains itself with a "Live" tooltip.
class _Source implements VehicleEtaProvider {
  _Source({this.etas = const [], this.routesWithVehicles = const {}});
  final List<VehicleEta> etas;
  final Set<String> routesWithVehicles;

  @override
  Future<VehicleEtaSnapshot> fetchEtas(VehicleEtaRequest request) async =>
      VehicleEtaSnapshot(
        etas: etas,
        fetchedAt: etaT0,
        routesWithVehicles: routesWithVehicles,
      );
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

  Future<VehicleEtaCubit> loaded(
    VehicleEtaProvider source,
    List<routing.Itinerary> plan,
  ) async {
    final cubit = VehicleEtaCubit(provider: source, now: () => etaT0);
    addTearDown(cubit.close);
    await cubit.loadForPlan(routing.Plan(itineraries: plan), etaOrigin);
    return cubit;
  }

  Widget host(
    VehicleEtaCubit cubit,
    List<routing.Itinerary> cards, {
    RealtimeVehiclesProvider? realtime,
  }) => MultiProvider(
    providers: [
      BlocProvider<VehicleEtaCubit>.value(value: cubit),
      Provider<RealtimeVehiclesProvider?>.value(value: realtime),
    ],
    child: MaterialApp(
      localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
      supportedLocales: HomeScreenLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          children: [
            for (final it in cards)
              ItineraryCard(itinerary: it, isSelected: false, onTap: () {}),
          ],
        ),
      ),
    ),
  );

  testWidgets('no vehicle of the route in the snapshot: no badge at all', (
    tester,
  ) async {
    final cubit = await loaded(_Source(), [bus123]);
    await tester.pumpWidget(host(cubit, [bus123]));

    expect(find.text('Live ETA unavailable'), findsNothing);
    expect(find.text('No buses nearby right now'), findsNothing);
    expect(find.textContaining('Arrives'), findsNothing);
    expect(find.byIcon(Icons.sensors_off_rounded), findsNothing);
    expect(find.byIcon(Icons.sensors_rounded), findsNothing);
  });

  testWidgets('vehicles of the route but none heading to the stop: "No buses '
      'nearby right now"', (tester) async {
    final cubit = await loaded(_Source(routesWithVehicles: {'1:123'}), [
      bus123,
    ]);
    await tester.pumpWidget(host(cubit, [bus123]));

    expect(find.text('No buses nearby right now'), findsOneWidget);
    expect(find.text('Live ETA unavailable'), findsNothing);
  });

  testWidgets('a bus approaching: "Arrives in ~4 min" as today', (
    tester,
  ) async {
    final cubit = await loaded(
      _Source(etas: [eta('1:123', 240)], routesWithVehicles: {'1:123'}),
      [bus123],
    );
    await tester.pumpWidget(host(cubit, [bus123]));

    expect(find.text('Arrives in ~4 min'), findsOneWidget);
    expect(find.text('No buses nearby right now'), findsNothing);
  });

  testWidgets('decided per route: 123 has vehicles, 999 has none', (
    tester,
  ) async {
    final cubit = await loaded(_Source(routesWithVehicles: {'1:123'}), [
      bus123,
      bus999,
    ]);
    await tester.pumpWidget(host(cubit, [bus123, bus999]));

    expect(
      find.text('No buses nearby right now'),
      findsOneWidget,
      reason: 'only the card of 123; the card of 999 shows no badge',
    );
    expect(find.text('Live ETA unavailable'), findsNothing);
  });

  group('the live dot on the route chip', () {
    final fleet = [
      VehiclePosition(
        vehicleId: 'b1',
        position: const TrufiLatLng(-17.39, -66.15),
        routeId: '1:123',
      ),
    ];

    testWidgets('a route with vehicles wears the dot with a "Live" tooltip', (
      tester,
    ) async {
      final cubit = await loaded(_Source(routesWithVehicles: {'1:123'}), [
        bus123,
      ]);
      await tester.pumpWidget(
        host(cubit, [bus123], realtime: _FakeRealtime(fleet)),
      );

      expect(find.byType(LiveBusBadge), findsOneWidget);
      final tip = find.ancestor(
        of: find.byType(LiveBusBadge),
        matching: find.byType(Tooltip),
      );
      expect(tip, findsOneWidget);
      expect(tester.widget<Tooltip>(tip).message, 'Live');
    });

    testWidgets('a route with no vehicles has no dot and no tooltip', (
      tester,
    ) async {
      final cubit = await loaded(_Source(), [bus999]);
      await tester.pumpWidget(
        host(cubit, [bus999], realtime: _FakeRealtime(fleet)),
      );

      expect(find.byType(LiveBusBadge), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w is Tooltip && w.message == 'Live'),
        findsNothing,
      );
    });
  });
}
