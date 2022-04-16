import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinarary_card/icon_transport.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';

class ModeLeg extends StatelessWidget {
  final double maxWidth;
  final Leg leg;
  final double legLength;

  const ModeLeg({
    Key? key,
    required this.leg,
    required this.legLength,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final perc = legLength.abs() / 10;
    return SizedBox(
      width: (maxWidth * perc) >= 24 ? (maxWidth * perc) : 24,
      height: 30,
      child: IconTransport(
        bacgroundColor: leg.backgroundColor,
        color: Colors.black,
        text: '',
        icon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          width: 20,
          height: 20,
          child: leg.transportMode.getImage(),
        ),
      ),
    );
  }
}

class WaitLeg extends StatelessWidget {
  final double maxWidth;
  final double legLength;
  final int duration;

  const WaitLeg({
    Key? key,
    required this.legLength,
    required this.duration,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final perc = legLength.abs() / 10;
    return SizedBox(
      width: (maxWidth * perc) >= 24 ? (maxWidth * perc) : 24,
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
      ),
    );
  }
}

class RouteLeg extends StatelessWidget {
  final double maxWidth;
  final Leg leg;
  final double legLength;

  const RouteLeg({
    Key? key,
    required this.leg,
    required this.legLength,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final perc = legLength.abs() / 10;
    return SizedBox(
      width: (maxWidth * perc) >= 24 ? (maxWidth * perc) : 24,
      height: 30,
      child: ClipRRect(
        child: IconTransport(
          bacgroundColor: leg.primaryColor,
          color: Colors.white,
          icon: leg.transportMode.getImage(color: Colors.white),
          text: (maxWidth * perc - 24) >= ((leg.headSign.length) * 8.5)
              ? leg.headSign
              : '',
        ),
      ),
    );
  }
}
