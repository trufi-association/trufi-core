import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/route_number.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class TransitLeg extends StatelessWidget {
  final Leg leg;

  const TransitLeg({
    Key? key,
    required this.leg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Column(
      children: [
        RouteNumber(
          transportMode: leg.transportMode,
          backgroundColor: leg.backgroundColor,
          text: leg.headSign,
          tripHeadSing: leg.headSign,
          duration: leg.durationLeg(localization),
          distance: leg.distanceString(localization),
        ),
        // TODO use code with OTP 2
        if (leg.intermediatePlaces != null &&
            leg.intermediatePlaces!.isNotEmpty)
          SizedBox(
            width: 250,
            child: ExpansionTile(
              title: Text(
                '${leg.intermediatePlaces!.length} ${localization.localeName == 'en' ? (leg.intermediatePlaces!.length > 1 ? 'stops' : 'stop') : (leg.intermediatePlaces!.length > 1 ? 'Zwischenstopps' : 'Zwischenstopp')}',
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 7),
              textColor: theme.colorScheme.primary,
              collapsedTextColor: theme.colorScheme.primary,
              iconColor: theme.colorScheme.primary,
              collapsedIconColor: theme.colorScheme.primary,
              children: [
                ...leg.intermediatePlaces!
                    .map((e) => Container(
                          width: 235,
                          height: 30,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                // if (planPageController != null &&
                                //     e.stopEntity?.lat != null &&
                                //     e.stopEntity?.lon != null) {
                                //   planPageController.inSelectePosition.add(
                                //       LatLng(
                                //           e.stopEntity.lat, e.stopEntity.lon));
                                // }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Text(
                                  //   DateFormat('HH:mm').format(
                                  //       e.arrivalTime ?? DateTime.now()),
                                  // ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      e.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.keyboard_arrow_right,
                                      color: theme.colorScheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
      ],
    );
  }
}
