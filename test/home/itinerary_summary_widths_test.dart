import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/icon_transport.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/itinerary_summary_advanced.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/mode_leg.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

// trufi-core#1049: the summary row reserved 24 px per short transport leg
// and sized every chip on its own, while a chip with an arrow is 41 px wide
// (#1047) and short walks were measured against a denominator that excluded
// them. The fixed chips could add up to more than the row, so the last chip
// (the Expanded one) was squeezed below its icon, or the row overflowed, or
// the last chip was 0 px wide with no error at all.

Leg _leg(
  TransportMode mode,
  int minutes,
  DateTime start, {
  bool transit = false,
}) =>
    Leg(
      points: '',
      transportMode: mode,
      route: null,
      routeColor: transit ? '0061D0' : null,
      shortName: transit ? 'C9' : null,
      routeLongName: transit ? 'El Golf → Feria Altiplano' : null,
      distance: 500,
      duration: Duration(minutes: minutes),
      fromPlace: const Place(name: 'A', lat: -16.3989, lon: -71.5370),
      toPlace: const Place(name: 'B', lat: -16.4215, lon: -71.5418),
      agencyName: transit ? 'Emarsistran' : null,
      startTime: start,
      endTime: start.add(Duration(minutes: minutes)),
      intermediatePlaces: null,
      transitLeg: transit,
      realTime: false,
    );

/// `'w5 b25 w3'` = a 5-minute walk, a 25-minute bus, a 3-minute walk.
Itinerary _itinerary(String spec) {
  var time = DateTime(2026, 10, 27, 12);
  final legs = <Leg>[];
  for (final token in spec.split(' ')) {
    final minutes = int.parse(token.substring(1));
    final leg = _leg(
      token.startsWith('w') ? TransportMode.walk : TransportMode.bus,
      minutes,
      time,
      transit: token.startsWith('b'),
    );
    legs.add(leg);
    time = leg.endTime;
  }
  return Itinerary(
    legs: legs,
    startTime: legs.first.startTime,
    endTime: legs.last.endTime,
    walkTime: Duration.zero,
    duration: legs.fold(Duration.zero, (sum, leg) => sum + leg.duration),
    walkDistance: 0,
    transfers: 0,
  );
}

typedef _Chip = ({Rect rect, bool isEnd});

/// Pumps the summary [width] px wide; returns the row's rect and the
/// rendered rect of every chip, in order.
Future<(Rect, List<_Chip>)> _pump(
  WidgetTester tester,
  String spec,
  double width,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: TrufiBaseLocalization.localizationsDelegates,
      supportedLocales: TrufiBaseLocalization.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: ItinerarySummaryAdvanced(
              itinerary: _itinerary(spec),
              maxWidth: width,
            ),
          ),
        ),
      ),
    ),
  );
  final row = tester.getRect(
    find
        .descendant(
          of: find.byType(ItinerarySummaryAdvanced),
          matching: find.byType(Row),
        )
        .first,
  );
  final chipFinder =
      find.byWidgetPredicate((w) => w is RouteLeg || w is ModeLeg);
  final chips = <_Chip>[];
  for (var i = 0; i < chipFinder.evaluate().length; i++) {
    final widget = tester.widget(chipFinder.at(i));
    chips.add((
      rect: tester.getRect(chipFinder.at(i)),
      isEnd: widget is RouteLeg ? widget.isEnd : (widget as ModeLeg).isEnd,
    ));
  }
  return (row, chips);
}

List<double> _widths(List<_Chip> chips) =>
    chips.map((c) => (c.rect.width * 10).round() / 10).toList();

void main() {
  group('distributeSummaryWidths', () {
    SummaryChipSpec chip(double weight, {double min = 41, bool walk = false}) =>
        (weight: weight, minWidth: min, hideable: walk);

    test('shares the width in proportion when every chip fits', () {
      expect(
        distributeSummaryWidths(300, [chip(100), chip(200, min: 24)]),
        [100, 200],
      );
    });

    test('pins a chip below its minimum and shares the rest again', () {
      // #1041's itinerary once its 1-minute walks are hidden: three short
      // buses at 41 px, the long one gets what is left.
      expect(
        distributeSummaryWidths(290, [
          chip(180),
          chip(180),
          chip(180),
          chip(2700, min: 24),
        ]),
        [41, 41, 41, 167],
      );
    });

    test('a chip that fit before another was pinned is pinned next', () {
      // Pass 1 at 20 px/weight: 20 (pinned), 44, 136. Pass 2 over the
      // remaining 159 px: 2.2 × 17.7 = 38.9 < 41 (pinned). Pass 3: 118.
      final widths = distributeSummaryWidths(200, [
        chip(1),
        chip(2.2),
        chip(6.8, min: 24),
      ]);
      expect(widths.map((w) => (w! * 10).round() / 10), [41, 41, 118]);
    });

    test('leaves out a walk whose share is below 24 px, weight included', () {
      expect(
        distributeSummaryWidths(
            290, [chip(60, walk: true), chip(1800, min: 24)]),
        [null, 290],
      );
    });

    test('a walk with a share of at least 24 px stays, at its minimum', () {
      // 300 / 3300 × 290 = 26.4 px: shown, then pinned at 41 for its arrow.
      expect(
        distributeSummaryWidths(
            290, [chip(300, walk: true), chip(3000, min: 24)]),
        [41, 249],
      );
    });

    test('with minimums that do not fit every chip is at its minimum', () {
      expect(
        distributeSummaryWidths(100, [chip(1), chip(1), chip(1, min: 24)]),
        [41, 41, 24],
      );
    });

    test('a zero total weight hides nothing and pins everything', () {
      expect(
        distributeSummaryWidths(200, [chip(0, walk: true), chip(0, min: 24)]),
        [41, 24],
      );
      expect(distributeSummaryWidths(200, []), isEmpty);
    });
  });

  group('ItinerarySummaryAdvanced', () {
    // The itineraries the #1047 review probed, plus a short last bus with
    // and without a walk before it.
    const itineraries = [
      'w5 b25 w3 b20 w5',
      'w6 b8 w4 b44 w5',
      'w4 b6 w3 b6 w3 b40 w5',
      'w5 b8 w5 b8 w5 b8 w5',
      'w2 b5 w2 b50 w2',
      'b3 w1 b3 w1 b3 w1 b45',
      'w10 b10 w10 b10 w10',
      'w5 b30 w2 b2',
      'w5 b30 b2',
    ];
    for (final spec in itineraries) {
      testWidgets('$spec: the chips fill the row and none is squeezed',
          (tester) async {
        for (final width in [290.0, 320.0, 360.0]) {
          final (row, chips) = await _pump(tester, spec, width);
          expect(tester.takeException(), isNull, reason: '$spec @ $width');
          expect(row.width, width);
          var left = row.left;
          for (final chip in chips) {
            expect(chip.rect.left, moreOrLessEquals(left),
                reason: '$spec @ $width');
            expect(
              chip.rect.width,
              greaterThanOrEqualTo(
                  IconTransport.minWidth(isEnd: chip.isEnd) - 1e-9),
              reason: '$spec @ $width: $chip',
            );
            left = chip.rect.right;
          }
          expect(left, moreOrLessEquals(row.right), reason: '$spec @ $width');
        }
      });
    }

    testWidgets('#1049: two short buses do not eat into the last chip',
        (tester) async {
      // Before: 41 + 41 + 220 px of fixed chips in a 290 px row (the two
      // 8-minute legs were reserved 24 px each), the last chip got 0.
      final (_, chips) = await _pump(tester, 'w6 b8 w4 b44 w5', 290);
      expect(tester.takeException(), isNull);
      expect(_widths(chips), [41, 41, 208]);
    });

    testWidgets('a walk pinned at 41 px takes its extra from the long legs',
        (tester) async {
      // Before: 41 + 131.8 + 105.5, the last walk was squeezed to 11.7 px.
      final (_, chips) = await _pump(tester, 'w5 b25 w3 b20 w5', 290);
      expect(tester.takeException(), isNull);
      expect(_widths(chips), [41, 124.5, 99.6, 24.9]);
    });

    testWidgets('a short last bus keeps its 24 px instead of vanishing',
        (tester) async {
      // Before: the bus before it was handed the 24 px reserved for the
      // last leg, which rendered 0 px wide and silently (RenderFlex does not
      // paint, nor report, an empty box).
      final (_, chips) = await _pump(tester, 'w5 b30 b2', 320);
      expect(tester.takeException(), isNull);
      expect(_widths(chips), [42.3, 253.7, 24]);
    });

    testWidgets('#1041 stays: three short buses measure 41, 41, 41',
        (tester) async {
      final (_, chips) = await _pump(tester, 'b3 w1 b3 w1 b3 w1 b45', 290);
      expect(tester.takeException(), isNull);
      expect(_widths(chips), [41, 41, 41, 167]);
    });
  });
}
