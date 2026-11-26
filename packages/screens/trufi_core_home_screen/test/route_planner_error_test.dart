import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'support/home_harness.dart';
import 'support/vehicle_eta_fakes.dart';

/// trufi-lima#9: offline, the panel printed the exception ("Otp28Exception:
/// Network error: ClientException ... https://lima.trufi.dev/..."). The cubit
/// keeps a KEY (never `toString()`), the UI resolves it to a sentence.
void main() {
  const noConnection =
      'No internet connection. Check your connection and try again.';
  const planFailed = "We couldn't search for routes. Please try again.";

  // What the OTP provider throws offline, with the raw text a rider saw.
  final rawNetwork = routing.RoutingNetworkException(
    'Network error: ClientException with SocketException: Failed host '
    'lookup: lima.trufi.dev, uri=https://lima.trufi.dev/otp/graphql',
  );
  final rawServer = routing.Otp28Exception(
    'GraphQL error: PlanFailure at https://lima.trufi.dev/otp/graphql',
  );

  Future<RoutePlannerCubit> cubitFailingWith(
    Object failure,
    ScriptedPlanService service,
  ) async {
    service.failure = failure;
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

  group('the cubit stores a key, never the exception text', () {
    test('a network failure is networkErrorKey', () async {
      final cubit = await cubitFailingWith(rawNetwork, ScriptedPlanService());
      expect(cubit.state.error, networkErrorKey);
    });

    test('any other failure is genericErrorKey', () async {
      final cubit = await cubitFailingWith(rawServer, ScriptedPlanService());
      expect(cubit.state.error, genericErrorKey);
    });

    test('an exception of any other type is genericErrorKey too', () async {
      final cubit = await cubitFailingWith(
        StateError('boom http://secret'),
        ScriptedPlanService(),
      );
      expect(cubit.state.error, genericErrorKey);
    });

    test('the keys are distinct from each other and from no-routes', () {
      expect({
        networkErrorKey,
        genericErrorKey,
        noRoutesErrorKey,
      }, hasLength(3));
    });
  });

  group('the results panel (ItineraryList)', () {
    Widget host(RoutePlannerCubit cubit) => MaterialApp(
      localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
      supportedLocales: HomeScreenLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider.value(value: cubit, child: const ItineraryList()),
      ),
    );

    void expectNoRawText(WidgetTester tester) {
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
          .join('\n');
      expect(texts, isNot(contains('Exception')));
      expect(texts, isNot(contains('lima.trufi.dev')));
      expect(texts, isNot(contains('http')));
    }

    testWidgets('offline: the no-connection sentence, nothing raw', (
      tester,
    ) async {
      final cubit = await cubitFailingWith(rawNetwork, ScriptedPlanService());
      await tester.pumpWidget(host(cubit));
      await tester.pump();

      expect(find.text(noConnection), findsOneWidget);
      expectNoRawText(tester);
    });

    testWidgets('server / GraphQL error: the generic sentence, nothing raw', (
      tester,
    ) async {
      final cubit = await cubitFailingWith(rawServer, ScriptedPlanService());
      await tester.pumpWidget(host(cubit));
      await tester.pump();

      expect(find.text(planFailed), findsOneWidget);
      expect(find.text(noConnection), findsNothing);
      expectNoRawText(tester);
    });

    testWidgets('Try again plans once the connection is back', (tester) async {
      final service = ScriptedPlanService();
      final cubit = await cubitFailingWith(rawNetwork, service);
      await tester.pumpWidget(host(cubit));
      await tester.pump();
      expect(service.calls, 1);

      service
        ..failure = null
        ..plan = routing.Plan(
          itineraries: [
            itinerary([walkLeg(), busLeg('123')]),
          ],
        );
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(service.calls, 2, reason: 'Try again re-plans');
      expect(cubit.state.error, isNull);
      expect(cubit.state.plan, isNotNull);
      expect(find.text(noConnection), findsNothing);
    });
  });

  group('the home screen banner and panel', () {
    installHomeTestDefaults();

    testWidgets('offline: the same sentence, nothing raw', (tester) async {
      final cubit = await cubitFailingWith(rawNetwork, ScriptedPlanService());
      await pumpHome(tester, cubit);

      expect(find.text(noConnection), findsWidgets);
      expect(find.textContaining('Exception'), findsNothing);
      expect(find.textContaining('lima.trufi.dev'), findsNothing);
    });

    testWidgets('server error: the generic sentence', (tester) async {
      final cubit = await cubitFailingWith(rawServer, ScriptedPlanService());
      await pumpHome(tester, cubit);

      expect(find.text(planFailed), findsWidgets);
      expect(find.textContaining('Exception'), findsNothing);
      expect(find.textContaining('PlanFailure'), findsNothing);
    });
  });
}
