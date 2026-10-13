import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'support/vehicle_eta_fakes.dart';

/// #1004: the card shows the ETA badge of its FIRST bus only when a
/// [VehicleEtaCubit] is provided; without one (feature off) it renders
/// exactly as before.
void main() {
  final twoBuses = itinerary([walkLeg(), busLeg('123'), busLeg('106')]);
  final walkOnly = itinerary([walkLeg()]);

  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  ItineraryCard card(routing.Itinerary itinerary) =>
      ItineraryCard(itinerary: itinerary, isSelected: false, onTap: () {});

  Future<VehicleEtaCubit> loadedCubit(
    FakeVehicleEtaProvider provider,
    routing.Itinerary itinerary,
  ) async {
    final cubit = VehicleEtaCubit(provider: provider, now: () => etaT0);
    addTearDown(cubit.close);
    await cubit.loadForPlan(routing.Plan(itineraries: [itinerary]), etaOrigin);
    return cubit;
  }

  testWidgets('without a cubit there is no badge and the card is intact', (
    tester,
  ) async {
    await tester.pumpWidget(host(card(twoBuses)));

    expect(find.byType(EtaBadge), findsNothing);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('106'), findsOneWidget);
  });

  testWidgets('with a loaded cubit the first bus gets its estimate', (
    tester,
  ) async {
    final provider = FakeVehicleEtaProvider()
      ..answer = (_) => [eta('1:123', 240), eta('1:106', 60)];
    final cubit = await loadedCubit(provider, twoBuses);

    await tester.pumpWidget(
      BlocProvider<VehicleEtaCubit>.value(
        value: cubit,
        child: host(card(twoBuses)),
      ),
    );

    expect(find.byType(EtaBadge), findsOneWidget);
    expect(
      find.text('Arrives in ~4 min'),
      findsOneWidget,
      reason: 'the 123 is the boarding bus; the 106 (1 min) is a connection',
    );
    expect(
      provider.requests.single.routeIds,
      {'1:123'},
      reason: 'only the first boarding vehicle is requested',
    );
  });

  testWidgets('a route the source has nothing for shows the fallback', (
    tester,
  ) async {
    final provider = FakeVehicleEtaProvider()
      ..answer = (_) => [eta('1:999', 60)];
    final cubit = await loadedCubit(provider, twoBuses);

    await tester.pumpWidget(
      BlocProvider<VehicleEtaCubit>.value(
        value: cubit,
        child: host(card(twoBuses)),
      ),
    );

    expect(find.text('Live ETA unavailable'), findsOneWidget);
  });

  testWidgets('a walk-only itinerary never shows a badge', (tester) async {
    final provider = FakeVehicleEtaProvider()
      ..answer = (_) => [eta('1:123', 240)];
    final cubit = await loadedCubit(provider, twoBuses);

    await tester.pumpWidget(
      BlocProvider<VehicleEtaCubit>.value(
        value: cubit,
        child: host(card(walkOnly)),
      ),
    );

    expect(find.byType(EtaBadge), findsNothing);
  });
}
