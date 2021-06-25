import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/utils/geo_utils.dart';
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
    final localization = TrufiLocalization.of(context);
    final localeName = localization.localeName;

    final hasBikeLeg = legs.any(
      (leg) =>
          (leg.rentedBike ?? false) ||
          leg.transportMode == TransportMode.bicycle ||
          leg.mode == 'BICYCLE_WALK',
    );

    final faresInfo = <Widget>[];
    fares.asMap().forEach((index, fare) {
      final ticketUrl = fare?.agency?.fareUrl ?? fare?.url;
      if (index == 0) {
        faresInfo.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fares.length > 1
                    ? '${localization.itineraryTicketsTitle}:'
                    : '${localization.itineraryTicketTitle}:',
                style: theme.primaryTextTheme.bodyText1.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  Text(
                    fare.getTicketName(localeName),
                    style: theme.primaryTextTheme.bodyText1,
                  ),
                  Text(
                    ' ${formatTwoDecimals(localeName: localization.localeName).format(fare.cents / 100)} €',
                    style: theme.primaryTextTheme.bodyText1.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      if (ticketUrl != null) {
        faresInfo.add(CustomTextButton(
          text: localization.itineraryBuyTicket,
          onPressed: () async {
            if (await canLaunch(ticketUrl)) {
              await launch(ticketUrl);
            }
          },
          isDark: false,
          height: 27,
        ));
      }
    });

    return fares.isEmpty || unknownFares.isNotEmpty
        ? InfoMessage(
            message: localization.itineraryMissingPrice,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...faresInfo,
                  ],
                ),
              ),
              if (hasBikeLeg)
                InfoMessage(
                  message: localization.itineraryPriceOnlyPublicTransport,
                  margin: const EdgeInsets.only(right: 15, top: 5),
                ),
              Container(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  localization.copyrightsPriceProvider,
                  style: theme.primaryTextTheme.bodyText1
                      .copyWith(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          );
  }
}
