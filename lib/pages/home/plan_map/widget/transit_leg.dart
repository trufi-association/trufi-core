import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/pages/home/plan_map/widget/info_message.dart';
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RouteNumber(
          transportMode: leg.transportMode,
          backgroundColor: leg?.route?.color != null
              ? Color(int.tryParse("0xFF${leg.route.color}"))
              : leg.transportMode == TransportMode.bicycle &&
                      leg.fromPlace.bikeRentalStation != null
                  ? Colors.white
                  : Colors.black,
          icon: (leg?.route?.shortName ?? '').startsWith('RT')
              ? onDemandTaxiSvg(color: 'FFFFFF')
              : leg.transportMode == TransportMode.bicycle &&
                      leg.fromPlace.bikeRentalStation != null
                  ? getBikeRentalNetwork(
                          leg.fromPlace.bikeRentalStation.networks[0])
                      .image
                  : null,
          text: leg?.route?.shortName != null
              ? leg.route.shortName
              : leg.transportMode.getTranslate(localization),
          duration: leg.durationLeg(localization),
          distance: leg.distanceString(localization),
        ),
        if (leg.pickupBookingInfo != null)
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                child: InfoMessage(
                  message: leg.pickupBookingInfo.message,
                  widget: leg.pickupBookingInfo.contactInfo?.infoUrl != null
                      ? RichText(
                          text: TextSpan(
                            style: theme.primaryTextTheme.bodyText2.copyWith(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600),
                            text: localization.commonMoreInformartion,
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
                    margin: const EdgeInsets.only(top: 12),
                    width: 210,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      '${localization.commonCall}  ${leg.pickupBookingInfo.contactInfo?.phoneNumber}',
                      style: theme.primaryTextTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (leg.pickupBookingInfo.contactInfo?.bookingUrl != null)
                GestureDetector(
                  onTap: () {
                    launch(leg.pickupBookingInfo.contactInfo?.bookingUrl);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 210,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      localization.commonOnDemandTaxi,
                      style: theme.primaryTextTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          )
      ],
    );
  }
}
