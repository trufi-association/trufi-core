import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/icon_transport.dart';
import 'package:trufi_core/base/utils/text/outlined_text.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';

class ModeLeg extends StatelessWidget {
  /// Width the summary row allotted to this leg; never drawn narrower than
  /// [IconTransport.minWidth].
  final double width;
  final Leg leg;
  final bool isEnd;

  const ModeLeg({
    super.key,
    required this.leg,
    required this.width,
    required this.isEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: math.max(width, IconTransport.minWidth(isEnd: isEnd)),
      height: 30,
      child: IconTransport(
        bacgroundColor: leg.backgroundColor,
        color: Colors.black,
        text: '',
        icon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          width: 20,
          height: 20,
          child: leg.transportMode.getImage(color: theme.colorScheme.secondary),
        ),
        isEnd: isEnd,
      ),
    );
  }
}

class WaitLeg extends StatelessWidget {
  final double maxWidth;
  final double legLength;
  final int duration;
  final bool isEnd;

  const WaitLeg({
    super.key,
    required this.legLength,
    required this.duration,
    required this.maxWidth,
    required this.isEnd,
  });

  @override
  Widget build(BuildContext context) {
    final perc = legLength.abs() / 10;
    return SizedBox(
      width: perc > 1
          ? maxWidth
          : (maxWidth * perc) >= 24
          ? (maxWidth * perc)
          : 24,
      height: 30,
      child: IconTransport(
        bacgroundColor: TransportMode.walk.backgroundColor,
        color: Colors.black,
        text: (maxWidth * perc - 24) >= (duration.toString().length * 8.5)
            ? duration.toString()
            : '',
        icon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          width: 20,
          height: 20,
          child: waitIcon(),
        ),
        isEnd: isEnd,
      ),
    );
  }
}

class RouteLeg extends StatelessWidget {
  /// Width the summary row allotted to this leg; never drawn narrower than
  /// [IconTransport.minWidth].
  final double width;
  final Leg leg;
  final Color? forcedColor;
  final bool isEnd;

  const RouteLeg({
    super.key,
    required this.leg,
    required this.width,
    this.forcedColor,
    required this.isEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: math.max(width, IconTransport.minWidth(isEnd: isEnd)),
      height: 30,
      child: ClipRRect(
        child: IconTransport(
          bacgroundColor: forcedColor ?? leg.backgroundColor,
          color: leg.primaryColor,
          icon: leg.transportMode.getImage(
            color: getContrastColor(forcedColor ?? leg.backgroundColor),
          ),
          text: leg.headSign,
          isEnd: isEnd,
        ),
      ),
    );
  }
}
