import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/itinerary_card.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

// The card header "(distance) · N transfers" (trufi-arequipa#29) on a narrow
// screen with a large font: it wraps instead of overflowing the card.

class _PlannerCubit extends Cubit<RoutePlannerState>
    implements RoutePlannerCubit {
  _PlannerCubit() : super(const RoutePlannerState());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('RoutePlannerCubit.${invocation.memberName}');
}

Map<String, dynamic> _place(String name) =>
    {'name': name, 'lat': -16.3989, 'lon': -71.5370};

/// OTP 1.5 REST shape, the one the Arequipa server sends.
Map<String, dynamic> _leg({
  required String mode,
  String? shortName,
  required int secs,
  required double meters,
  required bool transit,
}) =>
    {
      'legGeometry': {'points': '_p~iF~ps|U_ulLnnqC_mqNvxq`@'},
      'mode': mode,
      'route': shortName,
      'routeColor': transit ? '1E88E5' : null,
      'routeShortName': shortName,
      'routeLongName': shortName == null ? null : 'Ruta $shortName',
      'distance': meters,
      'duration': secs,
      'from': _place('A'),
      'to': _place('B'),
      'startTime': 1700000000000,
      'endTime': 1700000000000 + secs * 1000,
      'transitLeg': transit,
      'realTime': false,
    };

Itinerary _itinerary(int transitLegs, {int? transfers}) {
  final legs = <Map<String, dynamic>>[
    _leg(mode: 'WALK', secs: 300, meters: 400.0, transit: false),
    for (var i = 0; i < transitLegs; i++)
      _leg(
          mode: 'BUS',
          shortName: 'L$i',
          secs: 900,
          meters: 8000.0,
          transit: true),
  ];
  return Itinerary.fromJson({
    'legs': legs,
    'startTime': 1700000000000,
    'endTime': 1700000000000 + 2000 * 1000,
    'duration': 2000,
    'walkTime': 300,
    'walkDistance': 400.0,
    if (transfers != null) 'transfers': transfers,
  });
}

Future<void> _pump(
  WidgetTester tester,
  Itinerary itinerary, {
  double width = 320,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final cubit = _PlannerCubit();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: TrufiBaseLocalization.localizationsDelegates,
      supportedLocales: TrufiBaseLocalization.supportedLocales,
      home: BlocProvider<RoutePlannerCubit>.value(
        value: cubit,
        child: Scaffold(
          body: ListView(
            children: [ItineraryCard(itinerary: itinerary, onTap: () {})],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

String _header(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((w) => w.text.toPlainText())
    .firstWhere((t) => t.startsWith('('));

void main() {
  testWidgets(
      'one transfer on a 320 dp screen at text scale 2: the header '
      'wraps, nothing overflows', (tester) async {
    await _pump(tester, _itinerary(1, transfers: 1), textScale: 2.0);
    expect(tester.takeException(), isNull);
    expect(_header(tester), endsWith('· 1 transbordo'));
  });

  testWidgets('no transfer reads "Directo"', (tester) async {
    await _pump(tester, _itinerary(1, transfers: 0));
    expect(tester.takeException(), isNull);
    expect(_header(tester), endsWith('· Directo'));
  });

  testWidgets(
      'a provider that sends no count is a direct trip, not "5 transbordos"',
      (tester) async {
    await _pump(tester, _itinerary(1));
    expect(tester.takeException(), isNull);
    expect(_header(tester), endsWith('· Directo'));
  });

  testWidgets('a walk-only itinerary shows the distance alone', (tester) async {
    await _pump(tester, _itinerary(0, transfers: 0));
    expect(tester.takeException(), isNull);
    expect(_header(tester), isNot(contains('·')));
  });
}
