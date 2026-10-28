// The `footerBuilder` hook on the itineraries list and on the itinerary
// details card (trufi-arequipa#56).
//
// Pumps the real `CustomItinerary` / `ItineraryDetailsCard` with fake cubits
// (the real `RoutePlannerCubit` opens a Hive box in its constructor) and the
// core's own l10n delegates. No map engine is needed by either widget.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/custom_itinerary.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/itinerary_card.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/itinerary_details_card.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/line_dash_components.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/realtime/realtime_routes_cubit/realtime_routes_cubit.dart';

// ---------------------------------------------------------------- fakes

class _PlannerCubit extends Cubit<RoutePlannerState>
    implements RoutePlannerCubit {
  _PlannerCubit(super.initialState);

  @override
  Future<void> selectItinerary(Itinerary selectedItinerary) async {
    emit(state.copyWith(selectedItinerary: selectedItinerary));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('RoutePlannerCubit.${invocation.memberName}');
}

class _RealtimeCubit extends Cubit<RealtimeRoutesState>
    implements RealtimeRoutesCubit {
  _RealtimeCubit()
      : super(
            const RealtimeRoutesState(hasRealtime: false, transitRoute: null));

  int disabled = 0;

  @override
  Future<void> disableRealtime() async {
    disabled++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('RealtimeRoutesCubit.${invocation.memberName}');
}

// -------------------------------------------------------------- fixture

final _from = TrufiLocation(
    description: 'Plaza de Armas', latitude: -16.3989, longitude: -71.5370);
final _to = TrufiLocation(
    description: 'Terminal Terrestre', latitude: -16.4215, longitude: -71.5418);

Leg _walk(DateTime start, int minutes) => Leg(
      points: '',
      transportMode: TransportMode.walk,
      route: null,
      routeColor: null,
      shortName: null,
      routeLongName: null,
      distance: 1000,
      duration: Duration(minutes: minutes),
      fromPlace: const Place(name: 'Plaza', lat: -16.3989, lon: -71.5370),
      toPlace: const Place(name: 'Terminal', lat: -16.4215, lon: -71.5418),
      agencyName: null,
      startTime: start,
      endTime: start.add(Duration(minutes: minutes)),
      intermediatePlaces: null,
      transitLeg: false,
      realTime: false,
    );

Itinerary _itinerary(DateTime start, int minutes) {
  final leg = _walk(start, minutes);
  return Itinerary(
    legs: [leg],
    startTime: start,
    endTime: leg.endTime,
    walkTime: leg.duration,
    duration: leg.duration,
    walkDistance: 1000,
    transfers: 0,
  );
}

const footerKey = Key('fresh-review-footer');

Widget _host({
  required Widget child,
  required _PlannerCubit planner,
  required _RealtimeCubit realtime,
  double height = 600,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<RoutePlannerCubit>.value(value: planner),
      BlocProvider<RealtimeRoutesCubit>.value(value: realtime),
      BlocProvider<MapConfigurationCubit>(
        create: (_) => MapConfigurationCubit(
          MapConfiguration(center: const TrufiLatLng(-16.4, -71.5)),
        ),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        ...TrufiBaseLocalization.localizationsDelegates,
        ...SavedPlacesLocalization.localizationsDelegates,
      ],
      supportedLocales: const [Locale('es')],
      locale: const Locale('es'),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(height: height, width: 400, child: child),
        ),
      ),
    ),
  );
}

void main() {
  final t0 = DateTime(2026, 10, 27, 10, 5);
  final it1 = _itinerary(t0, 27); // 10:05 -> 10:32
  final it2 =
      _itinerary(t0.add(const Duration(minutes: 20)), 40); // 10:25 -> 11:05
  final it3 =
      _itinerary(t0.add(const Duration(minutes: 45)), 15); // 10:50 -> 11:05

  RoutePlannerState planState(List<Itinerary> its, Itinerary selected) =>
      RoutePlannerState(
        fromPlace: _from,
        toPlace: _to,
        plan: Plan(itineraries: its),
        selectedItinerary: selected,
      );

  group('ItineraryDetailsCard.footerBuilder', () {
    testWidgets('drawn once, after the destination row, inside the scroll area',
        (tester) async {
      final planner = _PlannerCubit(planState([it1], it1));
      final realtime = _RealtimeCubit();
      var builds = 0;
      await tester.pumpWidget(_host(
        planner: planner,
        realtime: realtime,
        height:
            100, // shorter than the content (~180 px): the footer starts below the fold
        child: ItineraryDetailsCard(
          itinerary: it1,
          onBackPressed: () {},
          moveTo: (_) => false,
          footerBuilder: (_) {
            builds++;
            return const Text('FOOTER', key: footerKey);
          },
        ),
      ));

      // once, not once per leg
      expect(find.byKey(footerKey, skipOffstage: false), findsOneWidget);
      expect(builds, 1);

      final places = find.byType(DashLinePlace, skipOffstage: false);
      expect(places, findsNWidgets(2));
      // the footer sits below the destination row
      final lastPlace = tester.getRect(places.last);
      final footerBefore =
          tester.getRect(find.byKey(footerKey, skipOffstage: false));
      expect(footerBefore.top, greaterThanOrEqualTo(lastPlace.bottom));

      // not pinned: it starts outside the 160 px viewport ...
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      expect(footerBefore.top, greaterThan(viewport.bottom));

      // ... and scrolls into view with the content
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      final footerAfter =
          tester.getRect(find.byKey(footerKey, skipOffstage: false));
      expect(footerAfter.bottom, lessThanOrEqualTo(viewport.bottom + 0.01));
      expect(footerAfter.top, lessThan(footerBefore.top));
      // nothing else broke: the inner ListView is still NeverScrollable
      final legs =
          tester.widget<ListView>(find.byType(ListView, skipOffstage: false));
      expect(legs.physics, isA<NeverScrollableScrollPhysics>());
      expect(legs.shrinkWrap, isTrue);
    });

    testWidgets('null footer draws nothing', (tester) async {
      final planner = _PlannerCubit(planState([it1], it1));
      final realtime = _RealtimeCubit();
      await tester.pumpWidget(_host(
        planner: planner,
        realtime: realtime,
        child: ItineraryDetailsCard(
          itinerary: it1,
          onBackPressed: () {},
          moveTo: (_) => false,
        ),
      ));
      final column = tester.widget<Column>(find
          .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Column))
          .first);
      // Row(back + bar), Divider, ListView — and nothing after the legs
      expect(column.children.length, 3);
      expect(column.children.last, isA<ListView>());
    });
  });

  group('CustomItinerary.footerBuilder', () {
    testWidgets('list: last row only when a builder is given', (tester) async {
      final planner = _PlannerCubit(planState([it1, it2, it3], it1));
      final realtime = _RealtimeCubit();
      await tester.pumpWidget(_host(
        planner: planner,
        realtime: realtime,
        child: CustomItinerary(
          moveTo: (_) => false,
          footerBuilder: (_) => const Text('FOOTER', key: footerKey),
        ),
      ));
      await tester.pump();

      expect(find.byType(ItineraryCard), findsNWidgets(3));
      expect(find.byKey(footerKey), findsOneWidget);
      final lastCard = tester.getRect(find.byType(ItineraryCard).last);
      expect(tester.getRect(find.byKey(footerKey)).top,
          greaterThanOrEqualTo(lastCard.bottom));
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(
          (list.childrenDelegate as SliverChildBuilderDelegate).childCount, 4);
    });

    testWidgets('list: item count unchanged without a builder', (tester) async {
      final planner = _PlannerCubit(planState([it1, it2, it3], it1));
      final realtime = _RealtimeCubit();
      await tester.pumpWidget(_host(
        planner: planner,
        realtime: realtime,
        child: CustomItinerary(moveTo: (_) => false),
      ));
      await tester.pump();
      expect(find.byType(ItineraryCard), findsNWidgets(3));
      expect(find.byKey(footerKey), findsNothing);
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(
          (list.childrenDelegate as SliverChildBuilderDelegate).childCount, 3);
    });

    testWidgets(
        'details opened from the list carry the footer and follow the selection',
        (tester) async {
      final planner = _PlannerCubit(planState([it1, it2, it3], it1));
      final realtime = _RealtimeCubit();
      var builds = 0;
      await tester.pumpWidget(_host(
        planner: planner,
        realtime: realtime,
        child: CustomItinerary(
          moveTo: (_) => false,
          footerBuilder: (_) {
            builds++;
            return const Text('FOOTER', key: footerKey);
          },
        ),
      ));
      await tester.pump();
      expect(find.byType(ItineraryDetailsCard), findsNothing);
      expect(find.text('10:32'), findsNothing); // the list shows no times

      // open the first card (the chevron is the details tap target)
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded).first);
      await tester.pumpAndSettle();
      expect(find.byType(ItineraryDetailsCard), findsOneWidget);
      expect(
          tester
              .widget<ItineraryDetailsCard>(find.byType(ItineraryDetailsCard))
              .itinerary,
          it1);
      expect(tester.widget<DashLinePlace>(find.byType(DashLinePlace).last).date,
          '10:32');
      expect(find.text('10:32'),
          findsNothing); // passed to DashLinePlace, never drawn
      // one visible footer (the list is kept offstage with its own row)
      expect(find.byKey(footerKey), findsOneWidget);
      expect(find.byKey(footerKey, skipOffstage: false), findsNWidgets(2));
      expect(
        find.descendant(
            of: find.byType(ItineraryDetailsCard),
            matching: find.byKey(footerKey)),
        findsOneWidget,
      );

      // the selection changes (e.g. a tap on another polyline on the map):
      // the details rebuild with the new itinerary and the footer is rebuilt
      final buildsBefore = builds;
      await planner.selectItinerary(it2);
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<ItineraryDetailsCard>(find.byType(ItineraryDetailsCard))
              .itinerary,
          it2);
      expect(tester.widget<DashLinePlace>(find.byType(DashLinePlace).last).date,
          '11:05');
      expect(builds, greaterThan(buildsBefore));
      expect(
        find.descendant(
            of: find.byType(ItineraryDetailsCard),
            matching: find.byKey(footerKey)),
        findsOneWidget,
      );

      // back to the list: details disposed, realtime released, list footer back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ItineraryDetailsCard), findsNothing);
      expect(realtime.disabled, 1);
      expect(find.byKey(footerKey), findsOneWidget);
    });
  });
}
