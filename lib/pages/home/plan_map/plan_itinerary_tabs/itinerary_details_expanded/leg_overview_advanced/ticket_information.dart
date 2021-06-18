import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/utils/fare_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/pages/home/plan_map/widget/custom_text_button.dart';
import 'package:trufi_core/pages/home/plan_map/widget/info_message.dart';
import 'package:trufi_core/services/models_otp/fare_component.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final localeName = TrufiLocalization.of(context).localeName;

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

    // ignore: unused_local_variable
    String unknownFareRouteName = unknownFareLeg != null
        ? '${unknownFareLeg.fromPlace?.name} - ${unknownFareLeg.toPlace?.name}'
        : null;
    if (unknownFareLeg?.transportMode == TransportMode.ferry) {
      unknownFareRouteName = unknownFares[0].routes[0].longName;
    }

    final faresInfo = <Widget>[];
    fares.asMap().forEach((index, fare) {
      final ticketUrl = fare?.agency?.fareUrl ?? fare?.url;
      if (index == 0) {
        faresInfo.add(
          Text(
            // TODO translate
            'Benötigte Fahrkarte:',
            style: theme.primaryTextTheme.bodyText1.copyWith(
              color: Colors.grey[600],
            ),
          ),
        );
      }

      faresInfo.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                fare.getTicketName(localeName),
                style: theme.primaryTextTheme.bodyText1,
              ),
              Text(
                ' ${(fare.cents / 100).toStringAsFixed(1)} €',
                style: theme.primaryTextTheme.bodyText1.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (ticketUrl != null)
            CustomTextButton(
              // TODO translate Required ticket
              text: 'Tickets kaufen',
              onPressed: () async {
                if (await canLaunch(ticketUrl)) {
                  await launch(ticketUrl);
                }
              },
              isDark: false,
              height: 27,
            )
        ],
      ));
    });

    return fares.isEmpty || unknownFares.isNotEmpty
        ? const InfoMessage(
            // TODO translate No price information
            message: 'Keine Preisangabe möglich',
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...faresInfo,
                  ],
                ),
              ),
              if (hasBikeLeg)
                const InfoMessage(
                  // TODO translate'Price only valid for public transport part of the journey.'
                  message: 'Preisauskunft nur für ÖPNV gültig.',
                  margin: EdgeInsets.only(right: 15, top: 5),
                ),
            ],
          );
  }
}
