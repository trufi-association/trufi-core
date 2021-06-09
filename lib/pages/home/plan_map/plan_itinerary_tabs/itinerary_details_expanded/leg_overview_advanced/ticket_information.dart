import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/utils/fare_utils.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/services/models_otp/fare_component.dart';

import 'widget/info_message.dart';

class TicketInformation extends StatelessWidget {
  final List<FareComponent> fares;
  final List<FareComponent> unknownFares;
  final List<PlanItineraryLeg> legs;
  const TicketInformation({
    Key key,
    @required this.fares,
    @required this.unknownFares,
    @required this.legs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBikeLeg = legs.any(
      (leg) =>
          (leg.rentedBike ?? false) ||
          leg.transportMode == TransportMode.bicycle ||
          leg.mode == 'BICYCLE_WALK',
    );

    final onlyVvs =
        fares.isNotEmpty && fares.every((fare) => fare?.agency?.name == 'VVS');

    final unknownFareLeg = legs.where((leg) => leg.route != null).firstWhere(
          (leg) => getUnknownFareRoute(unknownFares, leg.route),
          orElse: () => null,
        );

    String unknownFareRouteName = unknownFareLeg != null
        ? '${unknownFareLeg.fromPlace?.name} - ${unknownFareLeg.toPlace?.name}'
        : null;
    if (unknownFareLeg?.transportMode == TransportMode.ferry) {
      unknownFareRouteName = unknownFares[0].routes[0].longName;
    }

    return Column(
      children: [
        if (unknownFares.isNotEmpty)
          const InfoMessage(
            message: 'No price information',
          )
        else
          Column(
            children: [
              const Text('Required ticket:'),
              ...fares.map(
                (fare) => Row(
                  children: [
                    Text(fare.ticketName),
                    Text(' ${(fare.cents / 100).toStringAsFixed(1)} €'),
                  ],
                ),
              ),
              if (hasBikeLeg)
                const InfoMessage(
                  message:
                      'Price only valid for public transport part of the journey',
                ),
              if (onlyVvs)
                TextButton(onPressed: () {}, child: const Text('buy-ticket'))
            ],
          ),
      ],
    );
  }
}
