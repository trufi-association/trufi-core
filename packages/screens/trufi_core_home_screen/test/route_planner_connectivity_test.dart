import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';

import 'support/home_harness.dart';

/// A remote planner (the Trufi one) throws the raw connection error of the
/// transport instead of a RoutingNetworkException: it must read as "no
/// connection", not as a failed search. Which types count is tested with
/// `isConnectivityFailure` in trufi_core_routing.
void main() {
  Future<RoutePlannerCubit> cubitFailingWith(Object failure) async {
    final service = ScriptedPlanService()..failure = failure;
    final cubit = RoutePlannerCubit(
      repository: MemoryHomeRepository(),
      requestService: service,
    );
    addTearDown(cubit.close);
    await cubit.setFromPlace(homeFrom);
    await cubit.setToPlace(homeTo);
    await cubit.fetchPlan();
    return cubit;
  }

  test('a raw connection error is networkErrorKey', () async {
    final cubit = await cubitFailingWith(
      const SocketException('Failed host lookup'),
    );

    expect(cubit.state.error, networkErrorKey);
  });

  testWidgets('the results panel resolves the too-close key', (tester) async {
    final cubit = RoutePlannerCubit(
      repository: MemoryHomeRepository(),
      requestService: ScriptedPlanService(),
    );
    addTearDown(cubit.close);
    await cubit.setFromPlace(homeFrom);
    await cubit.setToPlace(homeFrom);
    await cubit.fetchPlan();
    expect(cubit.state.error, tooCloseErrorKey);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
        supportedLocales: HomeScreenLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const ItineraryList()),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'You are very close to your destination. Walking is the fastest '
        'option.',
      ),
      findsOneWidget,
    );
    expect(find.text(tooCloseErrorKey), findsNothing);
  });
}
