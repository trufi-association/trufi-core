import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Inside the results sheet the list and the inline detail share ONE
/// scrollable (`ItineraryList(shrinkWrap: true)` under the sheet's
/// `SingleChildScrollView`), so the swap between them has to manage that
/// scroll offset itself (#1055, trufi-sanaa#14): the detail starts at its
/// header, and the list comes back with the selected card in view.
void main() {
  final day = DateTime(2026, 9, 16, 10);
  const from = TrufiLocation(
    description: 'Origin',
    latitude: 15.2806,
    longitude: 44.2443,
  );
  const to = TrufiLocation(
    description: 'Destination',
    latitude: 15.3784,
    longitude: 44.2075,
  );

  routing.Place place(String name) =>
      routing.Place(name: name, lat: 15.3, lon: 44.2);

  routing.Leg walk(int minutes) => routing.Leg(
    mode: 'WALK',
    startTime: day,
    endTime: day.add(Duration(minutes: minutes)),
    duration: Duration(minutes: minutes),
    distance: minutes * 80.0,
    transitLeg: false,
    fromPlace: place('Corner A'),
    toPlace: place('Corner B'),
  );

  routing.Leg bus(String route) => routing.Leg(
    mode: 'BUS',
    startTime: day,
    endTime: day.add(const Duration(minutes: 10)),
    duration: const Duration(minutes: 10),
    distance: 4000,
    transitLeg: true,
    route: routing.Route(gtfsId: '1:$route', shortName: route),
    shortName: route,
    fromPlace: place('Stop of $route'),
    toPlace: place('Last stop of $route'),
  );

  // Six distinct two-bus rides (distinct routes → distinct groups), each with
  // a unique duration so a card can be found by its chip text.
  final itineraries = [
    for (var i = 0; i < 6; i++)
      routing.Itinerary(
        legs: [walk(3), bus('${i}A'), walk(1), bus('${i}B'), walk(2)],
        startTime: day,
        endTime: day.add(Duration(minutes: 21 + i)),
        walkTime: const Duration(minutes: 6),
        duration: Duration(minutes: 21 + i),
        walkDistance: 480,
      ),
  ];

  Future<RoutePlannerCubit> planCubit() async {
    final cubit = RoutePlannerCubit(
      repository: _MemoryRepository(),
      requestService: _FakePlanService(routing.Plan(itineraries: itineraries)),
    );
    await cubit.setFromPlace(from);
    await cubit.setToPlace(to);
    await cubit.fetchPlan();
    expect(cubit.state.plan?.groupedItineraries?.length, 6);
    return cubit;
  }

  /// The list in parent-scrollable mode, like the results sheet, inside a
  /// viewport of [height] pixels anchored at the top of the screen.
  Widget host(
    RoutePlannerCubit cubit, {
    required double height,
    required ScrollController controller,
    TextDirection direction = TextDirection.ltr,
  }) {
    return MaterialApp(
      localizationsDelegates: HomeScreenLocalizations.localizationsDelegates,
      supportedLocales: HomeScreenLocalizations.supportedLocales,
      // No Arabic in core's delegates: RTL comes from the directionality
      // alone (what a city with its own language adds on top).
      builder: (context, child) =>
          Directionality(textDirection: direction, child: child!),
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: height,
              child: SingleChildScrollView(
                key: const ValueKey('host'),
                controller: controller,
                child: const ItineraryList(shrinkWrap: true),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final selectedCard = find.byWidgetPredicate(
    (w) => w is ItineraryCard && w.isSelected,
  );
  // The cards carry their own (horizontal) SingleChildScrollView: key the host.
  final viewport = find.byKey(const ValueKey('host'));

  Future<(RoutePlannerCubit, ScrollController)> pump(
    WidgetTester tester, {
    required double height,
    TextDirection direction = TextDirection.ltr,
  }) async {
    final cubit = await planCubit();
    addTearDown(cubit.close);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(cubit, height: height, controller: controller, direction: direction),
    );
    await tester.pumpAndSettle();
    return (cubit, controller);
  }

  testWidgets('the detail opened from a scrolled list starts at its header', (
    tester,
  ) async {
    final (_, controller) = await pump(tester, height: 400);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(300));

    await tester.tap(find.text('26 min'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(controller.offset, 0);
    expect(
      tester.getTopLeft(find.byIcon(Icons.arrow_back_rounded)).dy,
      greaterThanOrEqualTo(tester.getTopLeft(viewport).dy),
    );
  });

  testWidgets('back from the detail brings the tapped card into the viewport', (
    tester,
  ) async {
    final (cubit, controller) = await pump(tester, height: 400);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();

    await tester.tap(find.text('26 min'));
    await tester.pumpAndSettle();
    expect(cubit.state.selectedItinerary, itineraries.last);
    // The rider read the detail from its top.
    controller.jumpTo(0);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(selectedCard, findsOneWidget);
    expect(find.text('26 min'), findsOneWidget);
    final card = tester.getRect(selectedCard);
    final host = tester.getRect(viewport);
    expect(card.top, greaterThanOrEqualTo(host.top));
    expect(card.bottom, lessThanOrEqualTo(host.bottom));
  });

  for (final direction in TextDirection.values) {
    testWidgets(
      "a card tapped while cut off (the sheet's mid snap) comes back whole "
      '($direction)',
      (tester) async {
        final (cubit, controller) = await pump(
          tester,
          height: 260,
          direction: direction,
        );
        final second = find.byWidgetPredicate(
          (w) => w is ItineraryCard && w.itinerary == itineraries[1],
        );
        final host = tester.getRect(viewport);
        expect(tester.getRect(second).bottom, greaterThan(host.bottom));
        expect(tester.getRect(second).top, lessThan(host.bottom));

        // Tap the visible top strip of the second card.
        await tester.tapAt(tester.getTopLeft(second) + const Offset(40, 12));
        await tester.pumpAndSettle();
        expect(cubit.state.selectedItinerary, itineraries[1]);
        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
        expect(controller.offset, 0);

        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();

        final card = tester.getRect(selectedCard);
        expect(card.top, greaterThanOrEqualTo(host.top));
        expect(card.bottom, lessThanOrEqualTo(host.bottom));
      },
    );
  }

  testWidgets('a card already in view does not move the list', (tester) async {
    final (_, controller) = await pump(tester, height: 400);

    await tester.tap(find.text('21 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
    expect(selectedCard, findsOneWidget);
  });
}

class _MemoryRepository implements HomeScreenRepository {
  TrufiLocation? from;
  TrufiLocation? to;
  routing.Plan? plan;
  routing.Itinerary? selected;

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
  Future<void> savePlan(routing.Plan? data) async => plan = data;
  @override
  Future<routing.Plan?> getPlan() async => plan;
  @override
  Future<void> saveSelectedItinerary(routing.Itinerary? data) async =>
      selected = data;
  @override
  Future<routing.Itinerary?> getSelectedItinerary() async => selected;
  @override
  Future<void> clear() async {
    from = null;
    to = null;
    plan = null;
    selected = null;
  }
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
