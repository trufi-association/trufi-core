import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Pins the #737 producer wiring: the cubit must fill
/// [routing.Plan.groupedItineraries] after a fetch AND after restoring a
/// saved plan (groups are not serialized), and the grouped list must not
/// offer indistinguishable "other departures" rows when the app pins the
/// routing time (routingTimeOverride deploys hide clock times).
routing.Place _stop(String id, double lat, double lon) =>
    routing.Place(name: id, lat: lat, lon: lon, stopId: id);

routing.Leg _bus(
  String route, {
  required routing.Place from,
  required routing.Place to,
}) => routing.Leg(
  mode: 'BUS',
  startTime: DateTime(2026, 8, 12, 8),
  endTime: DateTime(2026, 8, 12, 8, 30),
  duration: const Duration(minutes: 30),
  distance: 5000,
  transitLeg: true,
  route: routing.Route(gtfsId: route, shortName: route),
  shortName: route,
  fromPlace: from,
  toPlace: to,
);

routing.Itinerary _itinerary(List<routing.Leg> legs, {int startMinute = 0}) =>
    routing.Itinerary(
      legs: legs,
      startTime: DateTime(2026, 8, 12, 8, startMinute),
      endTime: DateTime(2026, 8, 12, 9, startMinute),
      walkTime: const Duration(minutes: 5),
      duration: const Duration(hours: 1),
      walkDistance: 400,
    );

/// origin / transfer / destination-area stops (real Cochabamba coords;
/// d2 sits ~165 m from d1 — inside the different-route tolerance).
final _o = _stop('o', -17.4650, -66.1400);
final _t = _stop('t', -17.3950, -66.1570);
final _d1 = _stop('d1', -17.3550, -66.1900);
final _d2 = _stop('d2', -17.3563, -66.1908);

/// 3 itineraries: [0] and [1] share the first leg and end near each other
/// with different routes (one group, route alternatives); [2] is direct.
List<routing.Itinerary> _rawItineraries() => [
  _itinerary([_bus('123', from: _o, to: _t), _bus('106', from: _t, to: _d1)]),
  _itinerary([
    _bus('123', from: _o, to: _t),
    _bus('120', from: _t, to: _d2),
  ], startMinute: 4),
  _itinerary([_bus('17', from: _o, to: _d1)], startMinute: 2),
];

/// Same-route pair: identical legs, later departure — groups WITHOUT
/// route alternatives ("other departures" only).
List<routing.Itinerary> _sameRoutePair() => [
  _itinerary([_bus('123', from: _o, to: _t), _bus('106', from: _t, to: _d1)]),
  _itinerary([
    _bus('123', from: _o, to: _t),
    _bus('106', from: _t, to: _d1),
  ], startMinute: 10),
];

class _FakeRepository implements HomeScreenRepository {
  routing.Plan? storedPlan;
  routing.Itinerary? storedSelected;
  TrufiLocation? from;
  TrufiLocation? to;

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> saveFromPlace(TrufiLocation? data) async => from = data;
  @override
  Future<TrufiLocation?> getFromPlace() async => from;
  @override
  Future<void> saveToPlace(TrufiLocation? data) async => to = data;
  @override
  Future<TrufiLocation?> getToPlace() async => to;
  @override
  Future<void> savePlan(routing.Plan? data) async => storedPlan = data;

  /// Simulates the JSON round-trip of the real repository: persisted
  /// plans come back WITHOUT groupedItineraries.
  @override
  Future<routing.Plan?> getPlan() async => storedPlan == null
      ? null
      : routing.Plan(
          from: storedPlan!.from,
          to: storedPlan!.to,
          itineraries: storedPlan!.itineraries,
        );

  @override
  Future<void> saveSelectedItinerary(routing.Itinerary? data) async =>
      storedSelected = data;
  @override
  Future<routing.Itinerary?> getSelectedItinerary() async => storedSelected;
  @override
  Future<void> clear() async {}
}

class _FakePlanService implements RequestPlanService {
  _FakePlanService(this.plan);
  final routing.Plan plan;

  @override
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async => plan;
}

Future<RoutePlannerCubit> _cubitWithPlan(
  List<routing.Itinerary> itineraries, {
  _FakeRepository? repository,
}) async {
  final cubit = RoutePlannerCubit(
    repository: repository ?? _FakeRepository(),
    requestService: _FakePlanService(routing.Plan(itineraries: itineraries)),
  );
  await cubit.setFromPlace(
    const TrufiLocation(description: 'A', latitude: -17.465, longitude: -66.14),
  );
  await cubit.setToPlace(
    const TrufiLocation(description: 'B', latitude: -17.355, longitude: -66.19),
  );
  await cubit.fetchPlan();
  return cubit;
}

void main() {
  group('cubit fills groupedItineraries (#737)', () {
    test('after fetchPlan, and selection is the first representative',
        () async {
      final cubit = await _cubitWithPlan(_rawItineraries());

      final groups = cubit.state.plan?.groupedItineraries;
      expect(groups, isNotNull, reason: 'the producer wiring must run');
      expect(groups, hasLength(2));
      expect(groups!.first.alternatives, hasLength(2));
      expect(groups.first.hasRouteAlternatives, isTrue);
      expect(
        cubit.state.selectedItinerary,
        same(cubit.state.plan!.itineraries!.first),
      );
      expect(
        groups.first.representative,
        same(cubit.state.plan!.itineraries!.first),
        reason: 'ranking is preserved: first card == first itinerary',
      );
    });

    test('after restoring a saved plan (groups are not serialized)',
        () async {
      final repository = _FakeRepository();
      final first = await _cubitWithPlan(
        _rawItineraries(),
        repository: repository,
      );
      await first.close();

      // Fresh cubit, same repository — as after an app restart.
      final restored = RoutePlannerCubit(
        repository: repository,
        requestService: _FakePlanService(routing.Plan(itineraries: const [])),
      );
      await restored.initialize();

      expect(restored.state.plan, isNotNull);
      expect(
        restored.state.plan!.groupedItineraries,
        isNotNull,
        reason: 'restore must regroup — JSON drops the groups',
      );
      expect(restored.state.plan!.groupedItineraries, hasLength(2));
      await restored.close();
    });
  });

  group('grouped list under routingTimeOverride', () {
    Widget host(RoutePlannerCubit cubit, {TimeOfDay? routingTimeOverride}) =>
        Provider<AppConfiguration?>.value(
          value: AppConfiguration(
            appName: 'Test',
            screens: const [],
            routingTimeOverride: routingTimeOverride,
          ),
          child: MaterialApp(
            localizationsDelegates:
                HomeScreenLocalizations.localizationsDelegates,
            supportedLocales: HomeScreenLocalizations.supportedLocales,
            home: Scaffold(
              body: BlocProvider.value(
                value: cubit,
                child: const ItineraryList(),
              ),
            ),
          ),
        );

    testWidgets(
      'same-route group offers NO expansion when times are hidden — the '
      'rows would be indistinguishable (blank but for a clock icon)',
      (tester) async {
        final cubit = await _cubitWithPlan(_sameRoutePair());
        await tester.pumpWidget(
          host(cubit, routingTimeOverride: const TimeOfDay(hour: 12, minute: 0)),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('+1'), findsNothing);
        await cubit.close();
      },
    );

    testWidgets('same-route group keeps its departures badge with visible '
        'times', (tester) async {
      final cubit = await _cubitWithPlan(_sameRoutePair());
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('+1'), findsOneWidget);
      await cubit.close();
    });

    testWidgets(
      'route-options group still expands with times hidden, and each row '
      'states its ride',
      (tester) async {
        final cubit = await _cubitWithPlan(_rawItineraries());
        await tester.pumpWidget(
          host(cubit, routingTimeOverride: const TimeOfDay(hour: 12, minute: 0)),
        );
        await tester.pumpAndSettle();

        final badge = find.textContaining('+1');
        expect(badge, findsOneWidget);
        await tester.tap(badge);
        await tester.pumpAndSettle();

        expect(find.text('123 → 120'), findsOneWidget,
            reason: 'with clock times hidden the route summary is the only '
                'thing identifying the row');
        await cubit.close();
      },
    );

    testWidgets('expanded time rows never overflow on a 320dp phone', (
      tester,
    ) async {
      // Regression guard: a Spacer sharing free space with Flexible time
      // texts truncated the departure time on ordinary widths (found by
      // the second review pass). Also covers the card header, which
      // overflowed on 12-hour locales at any ordinary width until this
      // branch wrapped its times in a FittedBox.
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cubit = await _cubitWithPlan(_sameRoutePair());
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('+1'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'a RenderFlex overflow throws in widget tests');
      await cubit.close();
    });

    testWidgets(
      'collapsing a group held open by its selected alternative moves the '
      'selection back to the representative and really closes it',
      (tester) async {
        final cubit = await _cubitWithPlan(_rawItineraries());
        // Select the non-representative alternative (state-level, as the
        // detail flow would): its group must force-open.
        final alternative = cubit.state.plan!.itineraries![1];
        await cubit.selectItinerary(alternative);

        await tester.pumpWidget(host(cubit));
        await tester.pumpAndSettle();
        expect(find.text('Other options'), findsOneWidget,
            reason: 'a selected alternative forces its group open');

        await tester.tap(find.textContaining('+1'));
        await tester.pumpAndSettle();

        expect(find.text('Other options'), findsNothing,
            reason: 'the collapse tap must not be a dead chevron');
        expect(
          cubit.state.selectedItinerary,
          cubit.state.plan!.groupedItineraries!.first.representative,
        );
        await cubit.close();
      },
    );
  });
}
