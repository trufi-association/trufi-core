import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/pages/home/plan_map/widget/custom_text_button.dart';
import 'package:trufi_core/pages/home/plan_map/widget/info_message.dart';
import 'package:trufi_core/pages/home/plan_map/widget/transit_leg.dart';

class TransportDash extends StatelessWidget {
  final double height;
  final double dashWidth;
  final PlanItineraryLeg leg;
  final PlanItinerary itinerary;
  final bool isNextTransport;
  final bool isBeforeTransport;
  final bool isFirstTransport;

  const TransportDash({
    @required this.leg,
    @required this.itinerary,
    this.isNextTransport = false,
    this.isBeforeTransport = true,
    this.isFirstTransport = false,
    this.height = 1,
    this.dashWidth = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final TrufiLocalization localization = TrufiLocalization.of(context);
    final configuration = context.read<ConfigurationCubit>().state;
    final homePageCubit = context.read<HomePageCubit>();
    final payloadDataPlanState = context.read<PayloadDataPlanCubit>().state;
    final isTypeBikeRentalNetwork =
        leg.transportMode == TransportMode.bicycle &&
            leg.fromPlace?.bikeRentalStation != null;
    return Column(
      children: [
        if (isBeforeTransport)
          DashLinePlace(
            date: leg.startTimeString.toString(),
            location: leg.transportMode == TransportMode.bicycle &&
                    leg.fromPlace.bikeRentalStation != null
                ? localization.bikeRentalFetchRentalBike
                : leg.fromPlace.name.toString(),
            color: leg?.route?.color != null
                ? Color(int.tryParse("0xFF${leg.route.color}"))
                : isTypeBikeRentalNetwork
                    ? getBikeRentalNetwork(
                            leg.fromPlace.bikeRentalStation.networks[0])
                        .color
                    : leg.transportMode.color,
            child: isFirstTransport
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: FittedBox(child: configuration.markers.fromMarker),
                  )
                : null,
          ),
        SeparatorPlace(
          color: leg?.route?.color != null
              ? Color(int.tryParse("0xFF${leg.route.color}"))
              : isTypeBikeRentalNetwork
                  ? getBikeRentalNetwork(
                          leg.fromPlace.bikeRentalStation.networks[0])
                      .color
                  : leg.transportMode.color,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransitLeg(
                leg: leg,
              ),
              if (configuration.planItineraryLegBuilder != null)
                configuration.planItineraryLegBuilder(context, leg) ??
                    Container(),
              if (leg?.toPlace?.vehicleParkingWithEntrance?.vehicleParking
                          ?.tags !=
                      null &&
                  leg.toPlace.vehicleParkingWithEntrance.vehicleParking.tags
                      .contains('state:few'))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    InfoMessage(
                        message: localization.carParkCloseCapacityMessage),
                    CustomTextButton(
                      text: localization.carParkExcludeFull,
                      onPressed: () async {
                        await homePageCubit.fetchPlanModeRidePark(
                            localization, payloadDataPlanState);
                      },
                    ),
                  ],
                ),
              if (isTypeBikeRentalNetwork &&
                  (itinerary?.arrivedAtDestinationWithRentedBicycle ?? false))
                InfoMessage(
                    message: localization.bikeRentalNetworkFreeFloating),
            ],
          ),
        ),
        if (isNextTransport)
          DashLinePlace(
            date: leg.endTimeString.toString(),
            location: leg.toPlace.name.toString(),
            color: leg?.route?.color != null
                ? Color(int.tryParse("0xFF${leg.route.color}"))
                : leg.transportMode.color,
          ),
      ],
    );
  }
}

class WalkDash extends StatelessWidget {
  final PlanItineraryLeg leg;
  final PlanItineraryLeg legBefore;
  const WalkDash({
    Key key,
    @required this.leg,
    this.legBefore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    return Column(
      children: [
        if (legBefore != null && legBefore.transportMode == TransportMode.walk)
          DashLinePlace(
            date: leg.startTimeString.toString(),
            location: leg.fromPlace.name,
            color: Colors.grey,
          ),
        SeparatorPlace(
          color: leg?.route?.color != null
              ? Color(int.tryParse("0xFF${leg.route.color}"))
              : leg.transportMode.color,
          separator: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 19,
            width: 19,
            child: walkSvg,
          ),
          height: 15,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
                '${localization.commonWalk} ${leg.durationLeg(localization)} (${leg.distanceString(localization)})'),
          ),
        ),
      ],
    );
  }
}

class WaitDash extends StatelessWidget {
  final PlanItineraryLeg legBefore;
  final PlanItineraryLeg legAfter;
  const WaitDash({Key key, this.legBefore, this.legAfter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
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
        SeparatorPlace(
          color: Colors.grey,
          separator: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 20,
            width: 20,
            child: waitSvg,
          ),
          height: 15,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
                "${localization.commonWait} (${localization.instructionDurationMinutes(legAfter.startTime.difference(legBefore.endTime).inMinutes)})"),
          ),
        ),
      ],
    );
  }
}

class SeparatorPlace extends StatelessWidget {
  final Widget child;
  final Widget separator;
  final Color color;
  final double height;

  const SeparatorPlace({
    Key key,
    @required this.child,
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
          const SizedBox(width: 52),
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
          if (child != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: child,
            ),
        ],
      ),
    );
  }
}

class DashLinePlace extends StatelessWidget {
  final String date;
  final String location;
  final Color color;
  final Widget child;

  const DashLinePlace({
    Key key,
    @required this.date,
    @required this.location,
    this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            date,
            style: theme.primaryTextTheme.bodyText1,
          ),
        ),
        if (child == null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              Icons.circle,
              size: 18,
              color: color,
            ),
          )
        else
          child,
        Expanded(
          child: Text(
            location,
            style: theme.primaryTextTheme.bodyText1,
          ),
        ),
      ],
    );
  }
}
