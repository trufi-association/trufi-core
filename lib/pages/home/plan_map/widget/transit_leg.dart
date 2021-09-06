import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/pages/home/plan_map/widget/info_message.dart';
import 'package:url_launcher/url_launcher.dart';

import '../plan.dart';
import 'route_number.dart';

class TransitLeg extends StatelessWidget {
  final PlanItineraryLeg leg;
  final PlanPageController planPageController;

  const TransitLeg({
    Key key,
    @required this.leg,
    @required this.planPageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final isTypeBikeRentalNetwork =
        leg.transportMode == TransportMode.bicycle &&
            leg.fromPlace?.bikeRentalStation != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RouteNumber(
          transportMode: leg.transportMode,
          backgroundColor: leg?.route?.color != null
              ? Color(int.tryParse("0xFF${leg.route.color}"))
              : isTypeBikeRentalNetwork
                  ? getBikeRentalNetwork(
                          leg.fromPlace.bikeRentalStation.networks[0])
                      .color
                  : leg.transportMode.backgroundColor,
          icon: (leg?.route?.type ?? 0) == 715
              ? onDemandTaxiSvg(color: 'FFFFFF')
              : isTypeBikeRentalNetwork
                  ? getBikeRentalNetwork(
                          leg.fromPlace.bikeRentalStation.networks[0])
                      .image
                  : null,
          text: leg?.route?.shortName != null
              ? leg.route.shortName
              : leg.transportMode.getTranslate(localization),
          tripHeadSing: leg.transportMode == TransportMode.carPool
              ? leg.toPlace.name
              : leg.headSign,
          duration: leg.durationLeg(localization),
          distance: leg.distanceString(localization),
          textContainer: isTypeBikeRentalNetwork
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTypeBikeRentalNetwork)
                      Text(
                        leg.fromPlace.name.toString(),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    if (isTypeBikeRentalNetwork)
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          localization.bikeRentalBikeStation,
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ),
                  ],
                )
              : null,
        ),
        if (leg?.intermediatePlaces != null &&
            leg.intermediatePlaces.isNotEmpty)
          SizedBox(
            width: 250,
            child: ExpansionTile(
              title: Text(
                '${leg.intermediatePlaces.length} ${localization.localeName == 'en' ? (leg.intermediatePlaces.length > 1 ? 'stops' : 'stop') : (leg.intermediatePlaces.length > 1 ? 'Zwischenstopps' : 'Zwischenstopp')}',
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 7),
              textColor: theme.primaryColor,
              collapsedTextColor: theme.primaryColor,
              iconColor: theme.primaryColor,
              collapsedIconColor: theme.primaryColor,
              children: [
                ...leg.intermediatePlaces
                    .map((e) => Container(
                          width: 235,
                          height: 30,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                if (planPageController != null &&
                                    e.stopEntity?.lat != null &&
                                    e.stopEntity?.lon != null) {
                                  planPageController.inSelectePosition.add(
                                      LatLng(
                                          e.stopEntity.lat, e.stopEntity.lon));
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(
                                        e.arrivalTime ?? DateTime.now()),
                                    style: theme.primaryTextTheme.bodyText1,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      e.stopEntity?.name ?? '',
                                      style: theme.primaryTextTheme.bodyText1,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.keyboard_arrow_right,
                                      color: theme.primaryColor),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        if (TransportMode.carPool == leg.transportMode &&
            leg.route?.url != null)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () async {
                if (await canLaunch(leg.route?.url)) {
                  await launch(leg.route?.url);
                }
              },
              child: Text(
                localization.commonDetails,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        if (leg.dropOffBookingInfo != null)
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                child: InfoMessage(
                  message:
                      '${leg.dropOffBookingInfo.message ?? ''} ${leg.dropOffBookingInfo.dropOffMessage ?? ''}',
                  widget: leg.dropOffBookingInfo.contactInfo?.infoUrl != null
                      ? RichText(
                          text: TextSpan(
                            style: theme.primaryTextTheme.bodyText2.copyWith(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600),
                            text: localization.commonMoreInformartion,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch(leg
                                    .dropOffBookingInfo.contactInfo?.infoUrl);
                              },
                          ),
                        )
                      : null,
                ),
              ),
              if (leg.dropOffBookingInfo.contactInfo?.phoneNumber != null)
                GestureDetector(
                  onTap: () {
                    launch(
                      "tel:${leg.dropOffBookingInfo.contactInfo?.phoneNumber}",
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
                      '${localization.commonCall}  ${leg.dropOffBookingInfo.contactInfo?.phoneNumber}',
                      style: theme.primaryTextTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (leg.dropOffBookingInfo.contactInfo?.bookingUrl != null)
                GestureDetector(
                  onTap: () {
                    launch(leg.dropOffBookingInfo.contactInfo?.bookingUrl);
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
