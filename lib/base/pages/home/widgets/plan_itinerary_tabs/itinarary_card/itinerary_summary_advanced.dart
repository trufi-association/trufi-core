import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/icon_transport.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/mode_leg.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

/// What the summary row knows about a chip before sizing it: the seconds of
/// the itinerary it stands for, the narrowest width it draws at, and whether
/// it may be left out when its share is too small (short walks are).
typedef SummaryChipSpec = ({double weight, double minWidth, bool hideable});

/// Shares [width] among the chips in proportion to their weight without
/// drawing any of them narrower than its minimum (trufi-core#1049).
///
/// A hideable chip whose proportional share is below [hideBelow] is left out
/// (`null`) and its weight with it. Then every chip whose share is below its
/// minimum is pinned there and the remaining width is shared again among the
/// others, until no chip is below its minimum: the loop CSS flexbox runs to
/// resolve flexible lengths, which Flutter's [Row] does not (it sizes its
/// fixed children first and hands the flexible one whatever is left, even
/// nothing). The widths add up to [width] whenever the minimums fit; when
/// they do not, every chip is at its minimum and the row overflows: its last
/// chip, being [Expanded], gets what is left, possibly nothing.
List<double?> distributeSummaryWidths(
  double width,
  List<SummaryChipSpec> chips, {
  double hideBelow = 24,
}) {
  final widths = List<double?>.filled(chips.length, null);
  final total = chips.fold(0.0, (sum, chip) => sum + chip.weight);
  final shown = <int>[
    for (var i = 0; i < chips.length; i++)
      if (!chips[i].hideable ||
          total <= 0 ||
          width * chips[i].weight / total >= hideBelow)
        i,
  ];
  final pinned = <int>{};
  while (true) {
    var pool = width;
    var weight = 0.0;
    for (final i in shown) {
      if (pinned.contains(i)) {
        pool -= chips[i].minWidth;
      } else {
        weight += chips[i].weight;
      }
    }
    final scale = weight > 0 ? math.max(0.0, pool) / weight : 0.0;
    final below = [
      for (final i in shown)
        if (!pinned.contains(i) && scale * chips[i].weight < chips[i].minWidth)
          i,
    ];
    if (below.isEmpty) {
      for (final i in shown) {
        widths[i] =
            pinned.contains(i) ? chips[i].minWidth : scale * chips[i].weight;
      }
      return widths;
    }
    pinned.addAll(below);
  }
}

class ItinerarySummaryAdvanced extends StatelessWidget {
  final double maxWidth;
  final Itinerary itinerary;

  const ItinerarySummaryAdvanced({
    super.key,
    required this.itinerary,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context)!;

    final compressLegs = itinerary.compressLegs;

    final chips = <SummaryChipSpec>[];
    final builders = <Widget Function(double width)>[];
    for (var index = 0; index < compressLegs.length; index++) {
      final leg = compressLegs[index];
      final isEnd = index == compressLegs.length - 1;
      // A wait for the next leg is drawn as part of this one.
      final wait = isEnd
          ? 0
          : compressLegs[index + 1].startTime.difference(leg.endTime).inSeconds;
      final weight = (leg.duration.inSeconds + math.max(0, wait)).toDouble();
      final minWidth = IconTransport.minWidth(isEnd: isEnd);
      if (leg.isLegOnFoot || leg.transportMode == TransportMode.bicycle) {
        chips.add(
          (weight: weight, minWidth: minWidth, hideable: leg.isLegOnFoot),
        );
        builders.add(
          (width) => ModeLeg(leg: leg, width: width, isEnd: isEnd),
        );
      } else if (leg.transportMode == TransportMode.car ||
          leg.route != null ||
          leg.shortName != null) {
        chips.add((weight: weight, minWidth: minWidth, hideable: false));
        builders.add(
          (width) => RouteLeg(leg: leg, width: width, isEnd: isEnd),
        );
      }
    }
    final widths = distributeSummaryWidths(maxWidth, chips);
    final legs = <Widget>[
      for (var i = 0; i < builders.length; i++)
        if (widths[i] != null) builders[i](widths[i]!),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: legs.length > 1
              ? <Widget>[
                  ...legs.getRange(0, legs.length - 1),
                  Expanded(child: legs.last)
                ]
              : [...legs],
        ),
        Container(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            itinerary.firstLegStartTime(localization),
            style: TextStyle(
              fontSize: 14,
              color: hintTextColor(theme),
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
