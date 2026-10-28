import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/mode_leg.dart';

// trufi-core#1041: a short transit leg that is not the last one used to get
// a 24 px chip holding a 22 px icon and a 15 px arrow: 17 px of overflow
// per leg from the second one on.
Leg _bus(int minutes) {
  final start = DateTime(2026, 10, 27, 12);
  return Leg(
    points: '',
    transportMode: TransportMode.bus,
    route: null,
    routeColor: '0061D0',
    shortName: 'C9',
    routeLongName: 'El Golf → Feria Altiplano',
    distance: 500,
    duration: Duration(minutes: minutes),
    fromPlace: const Place(name: 'A', lat: -16.3989, lon: -71.5370),
    toPlace: const Place(name: 'B', lat: -16.4215, lon: -71.5418),
    agencyName: 'Emarsistran',
    startTime: start,
    endTime: start.add(Duration(minutes: minutes)),
    intermediatePlaces: null,
    transitLeg: true,
    realTime: false,
  );
}

Widget _row(List<Widget> legs) => MaterialApp(
  home: Scaffold(
    body: Row(mainAxisSize: MainAxisSize.min, children: legs),
  ),
);

void main() {
  testWidgets(
    'a short leg with an arrow is at least 41 px and does not overflow',
    (tester) async {
      await tester.pumpWidget(
        _row([
          RouteLeg(leg: _bus(2), legLength: 0.3, maxWidth: 300, isEnd: false),
          RouteLeg(leg: _bus(2), legLength: 0.3, maxWidth: 300, isEnd: false),
          RouteLeg(leg: _bus(2), legLength: 0.3, maxWidth: 300, isEnd: true),
        ]),
      );
      expect(tester.takeException(), isNull);
      final widths = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(RouteLeg),
              matching: find.byType(SizedBox),
            ),
          )
          .where((b) => b.height == 30)
          .map((b) => b.width)
          .toList();
      expect(widths, [41, 41, 24]);
    },
  );

  testWidgets('a leg with room keeps its proportional width', (tester) async {
    await tester.pumpWidget(
      _row([
        RouteLeg(leg: _bus(20), legLength: 5, maxWidth: 300, isEnd: false),
      ]),
    );
    expect(tester.takeException(), isNull);
    final box = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(RouteLeg),
            matching: find.byType(SizedBox),
          ),
        )
        .firstWhere((b) => b.height == 30);
    expect(box.width, 150);
  });
}
