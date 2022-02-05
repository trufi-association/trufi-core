import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/journey_plan/utils/duration_utils.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/transit_leg.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';

class TransportDash extends StatelessWidget {
  final double height;
  final double dashWidth;
  final Leg leg;
  final Itinerary itinerary;
  final bool isNextTransport;
  final bool isBeforeTransport;
  final bool isFirstTransport;

  const TransportDash({
    Key? key,
    this.height = 1,
    this.dashWidth = 5.0,
    required this.leg,
    required this.itinerary,
    this.isNextTransport = false,
    this.isBeforeTransport = true,
    this.isFirstTransport = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return Column(
      children: [
        if (isBeforeTransport)
          DashLinePlace(
            date: leg.startTimeString,
            location: leg.fromPlace.name,
            color: leg.primaryColor,
            child: isFirstTransport
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: FittedBox(
                      child: mapConfiguratiom.markersConfiguration.fromMarker,
                    ),
                  )
                : null,
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
        if (isNextTransport)
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
  final Leg? legBefore;
  const WalkDash({
    Key? key,
    required this.leg,
    this.legBefore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Column(
      children: [
        if (legBefore != null && legBefore?.transportMode == TransportMode.walk)
          DashLinePlace(
            date: leg.startTimeString.toString(),
            location: leg.fromPlace.name,
            color: Colors.grey,
          ),
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

class WaitDash extends StatelessWidget {
  final Leg legBefore;
  final Leg legAfter;
  const WaitDash({
    Key? key,
    required this.legBefore,
    required this.legAfter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Column(
      children: [
        if (legBefore.endTime.millisecondsSinceEpoch -
                    legAfter.startTime.millisecondsSinceEpoch ==
                0 ||
            legBefore.transportMode == TransportMode.walk)
          DashLinePlace(
            date: legBefore.endTimeString.toString(),
            location: legBefore.toPlace.name,
            color: Colors.grey,
          ),
        if (legAfter.transitLeg)
          SeparatorPlace(
            color: Colors.grey,
            separator: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              height: 20,
              width: 20,
              child: waitIcon(color: theme.iconTheme.color),
            ),
            height: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  "${localization.commonWait} (${durationFormatString(localization, legAfter.startTime.difference(legBefore.endTime))})"),
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
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            margin: const EdgeInsets.only(top: 1),
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
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
