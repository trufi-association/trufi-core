import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinerary_details_expanded/leg_overview_advanced/widget/info_message.dart';
import 'package:url_launcher/url_launcher.dart';

import 'route_number.dart';

class TransitLeg extends StatelessWidget {
  final PlanItineraryLeg leg;

  const TransitLeg({
    Key key,
    @required this.leg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Column(
      children: [
        RouteNumber(
          transportMode: leg.transportMode,
          // TODO adapted the color server
          // color: leg?.route?.color != null
          //     ? Color(int.tryParse("0xFF${leg.route.color}"))
          //     : null,
          icon: (leg?.route?.shortName ?? '').startsWith('RT')
              ? onDemandTaxiSvg
              : null,
          text: leg?.route?.shortName != null
              ? leg.route.shortName
              : leg.transportMode.name,
          duration: leg.durationLeg(localization),
          distance: leg.distanceString(localization),
        ),
        if (leg.pickupBookingInfo != null)
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: InfoMessage(
                  message: leg.pickupBookingInfo.message,
                  widget: leg.pickupBookingInfo.contactInfo?.infoUrl != null
                      ? RichText(
                          text: TextSpan(
                            style: theme.primaryTextTheme.bodyText2.copyWith(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600),
                            // TODO Translate
                            text: "More informartion",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch(
                                    leg.pickupBookingInfo.contactInfo?.infoUrl);
                              },
                          ),
                        )
                      : null,
                ),
              ),
              if (leg.pickupBookingInfo.contactInfo?.phoneNumber != null)
                GestureDetector(
                  onTap: () {
                    launch(
                      "tel:${leg.pickupBookingInfo.contactInfo?.phoneNumber}",
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // TODO translate
                          'Call  ${leg.pickupBookingInfo.contactInfo?.phoneNumber}',
                          style: theme.primaryTextTheme.headline6,
                        ),
                      ],
                    ),
                  ),
                ),
              if (leg.pickupBookingInfo.contactInfo?.bookingUrl != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: theme.primaryTextTheme.bodyText2.copyWith(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600),
                      // TODO Translate
                      text: "book a ride",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch(leg.pickupBookingInfo.contactInfo?.bookingUrl);
                        },
                    ),
                  ),
                ),
            ],
          )
      ],
    );
  }
}
