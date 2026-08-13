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
/// the connections after the shared main bus are free-form options).
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
    test(
      'after fetchPlan, and selection is the first representative',
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
      },
    );

    test(
      'rides with more than two vehicles are dropped (product rule)',
      () async {
        final threeBuses = _itinerary([
          _bus('18', from: _o, to: _t),
          _bus('120', from: _t, to: _d1),
          _bus('50', from: _d1, to: _d2),
        ]);
        final cubit = await _cubitWithPlan([..._rawItineraries(), threeBuses]);

        expect(
          cubit.state.plan!.itineraries,
          hasLength(3),
          reason: 'the 18→120→50 chain must not survive the cap',
        );
        expect(
          cubit.state.plan!.itineraries!.any(
            (it) => it.legs.where((l) => l.transitLeg).length > 2,
          ),
          isFalse,
        );
        await cubit.close();
      },
    );

    test('after restoring a saved plan (groups are not serialized)', () async {
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

  group('grouped list and detail options (#737 v3)', () {
    Widget host(
      RoutePlannerCubit cubit, {
      TimeOfDay? routingTimeOverride,
    }) => Provider<AppConfiguration?>.value(
      value: AppConfiguration(
        appName: 'Test',
        screens: const [],
        routingTimeOverride: routingTimeOverride,
      ),
      child: MaterialApp(
        localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
        supportedLocales: HomeScreenLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const ItineraryList()),
        ),
      ),
    );

    Finder option(int index) => find.byKey(ValueKey('itinerary-option-$index'));

    testWidgets('the list shows no expansion affordance — options live in '
        'the detail', (tester) async {
      final cubit = await _cubitWithPlan(_rawItineraries());
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('+'), findsNothing);
      // The multi-route slot paints each option as its own segment.
      expect(find.text('106'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('the detail offers the group options and switching selects '
        'them', (tester) async {
      final cubit = await _cubitWithPlan(_rawItineraries());
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();

      // Open the grouped card's detail (tap its main-bus segment).
      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();

      expect(option(0), findsOneWidget);
      expect(option(1), findsOneWidget);

      await tester.tap(option(1));
      await tester.pumpAndSettle();

      expect(
        cubit.state.selectedItinerary,
        same(cubit.state.plan!.itineraries![1]),
        reason: 'switching an option selects it (map + navigation follow)',
      );
      // The switcher stays available to flip back.
      expect(option(0), findsOneWidget);
      await cubit.close();
    });

    testWidgets('back from the detail, the group card wears the chosen '
        'option', (tester) async {
      final cubit = await _cubitWithPlan(_rawItineraries());
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();

      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();
      await tester.tap(option(1));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // itineraries[1] departs at 8:04 — the card now shows ITS times.
      expect(find.textContaining('8:04'), findsWidgets);
      await cubit.close();
    });

    testWidgets('under routingTimeOverride, same-route departures are '
        'indistinguishable — the detail hides the switcher', (tester) async {
      final cubit = await _cubitWithPlan(_sameRoutePair());
      await tester.pumpWidget(
        host(cubit, routingTimeOverride: const TimeOfDay(hour: 12, minute: 0)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();

      expect(option(0), findsNothing);
      await cubit.close();
    });

    testWidgets('under routingTimeOverride, route options still switch — '
        'labeled by ride, no clock times', (tester) async {
      final cubit = await _cubitWithPlan(_rawItineraries());
      await tester.pumpWidget(
        host(cubit, routingTimeOverride: const TimeOfDay(hour: 12, minute: 0)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();

      expect(option(0), findsOneWidget);
      expect(option(1), findsOneWidget);
      await cubit.close();
    });

    testWidgets('the common main bus renders once — never inside the pills', (
      tester,
    ) async {
      final cubit = await _cubitWithPlan(_rawItineraries());
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();

      for (final i in [0, 1]) {
        expect(
          find.descendant(of: option(i), matching: find.text('123')),
          findsNothing,
          reason: 'the shared main bus must not repeat in every pill',
        );
      }
      expect(
        find.descendant(of: option(0), matching: find.text('106')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: option(1), matching: find.text('120')),
        findsOneWidget,
      );
      await cubit.close();
    });

    testWidgets('a mirror group (shared final connection) keeps the common '
        'bus out of the pills too', (tester) async {
      final mirrorPair = [
        _itinerary([
          _bus('18', from: _o, to: _t),
          _bus('120', from: _t, to: _d1),
        ]),
        _itinerary([
          _bus('8', from: _o, to: _t),
          _bus('120', from: _t, to: _d1),
        ], startMinute: 3),
      ];
      final cubit = await _cubitWithPlan(mirrorPair);
      expect(
        cubit.state.plan!.groupedItineraries,
        hasLength(1),
        reason: '"tienen en común el 120" — the mirror rule groups them',
      );

      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('18').first);
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: option(0), matching: find.text('120')),
        findsNothing,
        reason: 'the shared 120 renders once as the common chip',
      );
      expect(
        find.descendant(of: option(0), matching: find.text('18')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: option(1), matching: find.text('8')),
        findsOneWidget,
      );
      await cubit.close();
    });

    testWidgets('a departures-only group under pinned time hides the '
        'switcher via the empty-label branch', (tester) async {
      final directPair = [
        _itinerary([_bus('17', from: _o, to: _d1)]),
        _itinerary([_bus('17', from: _o, to: _d1)], startMinute: 10),
      ];
      final cubit = await _cubitWithPlan(directPair);
      await tester.pumpWidget(
        host(cubit, routingTimeOverride: const TimeOfDay(hour: 12, minute: 0)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('17').first);
      await tester.pumpAndSettle();

      expect(option(0), findsNothing);
      await cubit.close();
    });

    testWidgets('pills show type+name only; the time joins when names '
        'cannot distinguish the options', (tester) async {
      // Distinct connection names: no time in the pills (Sam 2026-08-13:
      // the time belongs to the header, which updates on switch).
      final distinct = await _cubitWithPlan(_rawItineraries());
      await tester.pumpWidget(host(distinct));
      await tester.pumpAndSettle();
      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: option(0), matching: find.textContaining(':')),
        findsNothing,
        reason: 'unique names need no time',
      );
      await distinct.close();

      // Same-named variants: every pill carries its departure time.
      final mixed = await _cubitWithPlan([
        _itinerary([
          _bus('123', from: _o, to: _t),
          _bus('106', from: _t, to: _d1),
        ]),
        _itinerary([
          _bus('123', from: _o, to: _t),
          _bus('106', from: _t, to: _d1),
        ], startMinute: 10),
        _itinerary([
          _bus('123', from: _o, to: _t),
          _bus('120', from: _t, to: _d2),
        ], startMinute: 4),
      ]);
      await tester.pumpWidget(host(mixed));
      await tester.pumpAndSettle();
      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();
      for (final i in [0, 1, 2]) {
        expect(
          find.descendant(of: option(i), matching: find.textContaining(':')),
          findsOneWidget,
          reason: 'duplicated names need the time as tiebreaker (pill $i)',
        );
      }
      await mixed.close();
    });

    testWidgets('unselected pill text picks the higher-contrast color for '
        'its blended fill', (tester) async {
      // Round-8 finding: a 0.5-luminance threshold kept white text at
      // ~2.3:1 over dark saturated fills blended into the light strip.
      final cubit = await _cubitWithPlan(_rawItineraries());
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();

      // Option 1 (unselected). Its route color is the default-assigned
      // E91E63 family — blended at 45% into the light strip the correct
      // pick is near-black, not white.
      final text = tester.widget<Text>(
        find.descendant(of: option(1), matching: find.byType(Text)).first,
      );
      final textLum = text.style!.color!.computeLuminance();
      // The segment's Material (the key's nearest Material ancestor)
      // carries the EFFECTIVE fill — production blends dimmed colors into
      // the strip backdrop before painting, so it is already opaque.
      final segmentMaterial = tester.widget<Material>(
        find.ancestor(of: option(1), matching: find.byType(Material)).first,
      );
      final fill = segmentMaterial.color!;
      final fillLum = fill.computeLuminance();
      double ratio(double a, double b) =>
          (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
      // Candidate inks as RENDERED: white is opaque; black87 is
      // translucent, so its effective luminance comes from blending it
      // into the fill — same math production uses to pick.
      final blackInkLum = Color.alphaBlend(
        Colors.black87,
        fill,
      ).computeLuminance();
      final chosen = ratio(textLum > 0.5 ? textLum : blackInkLum, fillLum);
      final alternative = ratio(textLum > 0.5 ? blackInkLum : 1.0, fillLum);
      expect(
        chosen >= alternative,
        isTrue,
        reason:
            'text color must be the better-contrast choice '
            '(chosen $chosen vs alternative $alternative)',
      );
      await cubit.close();
    });

    testWidgets('list and open detail never overflow on a 320dp phone', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cubit = await _cubitWithPlan(_rawItineraries());
      await tester.pumpWidget(host(cubit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('123').first);
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'a RenderFlex overflow throws in widget tests',
      );
      await cubit.close();
    });
  });
}
