import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import 'support/vehicle_eta_fakes.dart';

/// #1004: the manual refresh is hidden without the feature, disabled with a
/// countdown while the throttle runs, and re-sends the ETA request (never
/// a plan request) once allowed.
void main() {
  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
    supportedLocales: HomeScreenLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  IconButton button(WidgetTester tester) =>
      tester.widget<IconButton>(find.byType(IconButton));

  String tooltip(WidgetTester tester) =>
      tester.widget<Tooltip>(find.byType(Tooltip)).message!;

  testWidgets('renders nothing without a VehicleEtaCubit', (tester) async {
    await tester.pumpWidget(host(const EtaRefreshButton()));
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('stays hidden until a plan with transit routes is loaded', (
    tester,
  ) async {
    final cubit = VehicleEtaCubit(provider: FakeVehicleEtaProvider());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<VehicleEtaCubit>.value(
        value: cubit,
        child: host(const EtaRefreshButton()),
      ),
    );
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('counts the cooldown down, then re-enables and refreshes', (
    tester,
  ) async {
    var now = etaT0;
    final provider = FakeVehicleEtaProvider()
      ..answer = (_) => [eta('1:A', 240)];
    final cubit = VehicleEtaCubit(provider: provider, now: () => now);
    addTearDown(cubit.close);
    await cubit.loadForPlan(threeRidesPlan(), etaOrigin);

    await tester.pumpWidget(
      BlocProvider<VehicleEtaCubit>.value(
        value: cubit,
        child: host(EtaRefreshButton(now: () => now)),
      ),
    );

    expect(button(tester).onPressed, isNull, reason: 'cooldown just armed');
    expect(tooltip(tester), 'Refresh available in 12 s');

    now = etaT0.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(
      tooltip(tester),
      'Refresh available in 7 s',
      reason: 'the ticker updates the countdown without cubit emissions',
    );

    now = etaT0.add(const Duration(seconds: 12));
    await tester.pump(const Duration(seconds: 1));
    expect(
      button(tester).onPressed,
      isNotNull,
      reason:
          'fails if the '
          'throttle never releases',
    );
    expect(tooltip(tester), 'Refresh');

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(
      provider.calls,
      2,
      reason: 'a tap re-sends the ETA request — no plan request involved',
    );
    expect(provider.requests[1], provider.requests[0]);
  });

  testWidgets('shows a spinner and stays disabled while loading', (
    tester,
  ) async {
    final provider = FakeVehicleEtaProvider()..gate = Completer();
    final cubit = VehicleEtaCubit(provider: provider, now: () => etaT0);
    addTearDown(cubit.close);
    final load = cubit.loadForPlan(threeRidesPlan(), etaOrigin);

    await tester.pumpWidget(
      BlocProvider<VehicleEtaCubit>.value(
        value: cubit,
        child: host(EtaRefreshButton(now: () => etaT0)),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(button(tester).onPressed, isNull);

    provider.gate!.complete(VehicleEtaSnapshot.empty(etaT0));
    await load;
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });

  testWidgets('compact variant is a 28 px circle', (tester) async {
    final provider = FakeVehicleEtaProvider()
      ..answer = (_) => [eta('1:A', 240)];
    final cubit = VehicleEtaCubit(provider: provider, now: () => etaT0);
    addTearDown(cubit.close);
    await cubit.loadForPlan(threeRidesPlan(), etaOrigin);

    await tester.pumpWidget(
      BlocProvider<VehicleEtaCubit>.value(
        value: cubit,
        child: host(EtaRefreshButton(compact: true, now: () => etaT0)),
      ),
    );

    expect(tester.getSize(find.byType(EtaRefreshButton)), const Size(28, 28));
  });
}
