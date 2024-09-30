import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/transit_leg.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class TransportDash extends StatelessWidget {
  final Leg leg;
  final bool showBeforeLine;
  final bool showAfterLine;
  final Function(TrufiLatLng) moveTo;
  final Color? forcedColor;

  const TransportDash({
    super.key,
    required this.leg,
    required this.moveTo,
    this.showBeforeLine = true,
    this.showAfterLine = false,
    this.forcedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (showBeforeLine)
          DashLinePlace(
            date: leg.startTimeString,
            location: leg.fromPlace.name,
            color: forcedColor ?? leg.backgroundColor,
            moveInMap: () =>
                moveTo(TrufiLatLng(leg.fromPlace.lat, leg.fromPlace.lon)),
          ),
        SeparatorPlace(
          color: forcedColor ?? leg.backgroundColor,
          leading: leg.transportMode.getImage(color: theme.iconTheme.color),
          child: TransitLeg(
            leg: leg,
            moveTo: moveTo,
            forcedColor: forcedColor,
          ),
        ),
        if (showAfterLine)
          DashLinePlace(
            date: leg.endTimeString.toString(),
            location: leg.toPlace.name.toString(),
            color: forcedColor ?? leg.backgroundColor,
            moveInMap: () =>
                moveTo(TrufiLatLng(leg.toPlace.lat, leg.toPlace.lon)),
          ),
      ],
    );
  }
}

class WalkDash extends StatelessWidget {
  final Leg leg;
  final Function(TrufiLatLng) moveTo;
  const WalkDash({
    super.key,
    required this.leg,
    required this.moveTo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Column(
      children: [
        SeparatorPlace(
          color: leg.primaryColor,
          height: 10,
          leading: TransportMode.walk.getImage(color: theme.iconTheme.color),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () =>
                    moveTo(TrufiLatLng(leg.fromPlace.lat, leg.fromPlace.lon)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 3, 3, 5),
                  child: Text(
                      '${localization.commonWalk} ${leg.durationLeg(localization)} (${leg.distanceString(localization)})'),
                ),
              ),
            ],
          ),
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
    super.key,
    required this.child,
    this.leading,
    this.color,
    this.separator,
    this.height,
  });

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
  final Function moveInMap;

  const DashLinePlace({
    super.key,
    required this.date,
    required this.location,
    required this.moveInMap,
    this.child,
    this.color,
  });

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
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
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
          Flexible(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 4),
                          child: Icon(
                            Icons.location_searching,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: -5,
                  right: -5,
                  top: -5,
                  bottom: -5,
                  child: InkWell(
                    onTap: () => moveInMap(),
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
