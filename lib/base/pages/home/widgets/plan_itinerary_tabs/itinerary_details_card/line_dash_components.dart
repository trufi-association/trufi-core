import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/transit_leg.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class TransportDash extends StatelessWidget {
  final Leg leg;
  final bool showBeforeLine;
  final bool showAfterLine;

  const TransportDash({
    Key? key,
    required this.leg,
    this.showBeforeLine = true,
    this.showAfterLine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (showBeforeLine)
          DashLinePlace(
            date: leg.startTimeString,
            location: leg.fromPlace.name,
            color: leg.primaryColor,
          ),
        SeparatorPlace(
          color: leg.primaryColor,
          child: GestureDetector(
            onTap: () {
              // if (planPageController != null) {
              //   planPageController.inSelectePosition
              //       .add(LatLng(leg.fromPlace.lat, leg.fromPlace.lon));
              // }
            },
            child: TransitLeg(
              leg: leg,
            ),
          ),
          leading: leg.transportMode.getImage(color: theme.iconTheme.color),
        ),
        if (showAfterLine)
          DashLinePlace(
            date: leg.endTimeString.toString(),
            location: leg.toPlace.name.toString(),
            color: leg.primaryColor,
          ),
      ],
    );
  }
}

class WalkDash extends StatelessWidget {
  final Leg leg;
  const WalkDash({
    Key? key,
    required this.leg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Column(
      children: [
        SeparatorPlace(
          color: leg.primaryColor,
          height: 10,
          child: Text(
              '${localization.commonWalk} ${leg.durationLeg(localization)} (${leg.distanceString(localization)})'),
          leading: TransportMode.walk.getImage(color: theme.iconTheme.color),
        ),
      ],
    );
  }
}

class SeparatorPlace extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final Widget? separator;
  final Color? color;
  final double? height;

  const SeparatorPlace({
    Key? key,
    required this.child,
    this.leading,
    this.color,
    this.separator,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: (leading != null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      leading!,
                    ],
                  )
                : Container(),
          ),
          if (separator != null)
            Column(
              children: [
                Container(
                  width: 3,
                  height: height,
                  color: color ?? Colors.black,
                ),
                SizedBox(
                  width: 20,
                  child: separator,
                ),
                Container(
                  width: 3,
                  height: height,
                  color: color ?? Colors.black,
                ),
              ],
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.5),
              width: 3,
              height: height,
              color: color ?? Colors.black,
            ),
          const SizedBox(width: 5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class DashLinePlace extends StatelessWidget {
  final String date;
  final String location;
  final Widget? child;
  final Color? color;

  const DashLinePlace({
    Key? key,
    required this.date,
    required this.location,
    this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Center(
              child: Container(
                width: 40,
                height: 1.5,
                color: theme.dividerColor,
              ),
            ),
          ),
          if (child == null)
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    Icons.circle,
                    size: 18,
                    color: color,
                  ),
                ),
                Expanded(
                    child: Container(
                  color: color,
                  width: 3,
                )),
              ],
            )
          else
            child!,
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 1),
              child: Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
