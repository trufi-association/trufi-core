import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/route_number.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class TransitLeg extends StatelessWidget {
  final Leg leg;
  final Function(TrufiLatLng) moveTo;
  final Color? forcedColor;

  const TransitLeg({
    Key? key,
    required this.leg,
    required this.moveTo,
    this.forcedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            moveTo(TrufiLatLng(leg.fromPlace.lat, leg.fromPlace.lon));
          },
          child: RouteNumber(
            transportMode: leg.transportMode,
            backgroundColor: forcedColor ?? leg.backgroundColor,
            text: leg.headSign,
            tripHeadSing: leg.headSign,
            duration: leg.durationLeg(localization),
            distance: leg.distanceString(localization),
          ),
        ),
        // const SizedBox(height: 10),
        // Text(
        //   "What's it like on board?",
        //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        // ),
        // Container(
        //   margin: EdgeInsets.symmetric(vertical: 15),
        //   height: 40,
        //   // padding: EdgeInsets.symmetric(vertical: 20),
        //   child: ListView(
        //     scrollDirection: Axis.horizontal,
        //     // padding: EdgeInsets.symmetric(vertical: 20),
        //     children: [
        //       CustomButton(
        //         leg: leg,
        //         options: [
        //           SelectedData(
        //             "Not crowded",
        //             "Lots of seats",
        //             Icons.people,
        //             false,
        //           ),
        //           SelectedData(
        //             "Not too crowded",
        //             "Some seats available",
        //             Icons.people,
        //             false,
        //           ),
        //           SelectedData(
        //             "Crowded",
        //             "Limited seating and standing",
        //             Icons.people,
        //             false,
        //           ),
        //           SelectedData(
        //             "Very crowded",
        //             "Limited standing",
        //             Icons.people,
        //             false,
        //           ),
        //           SelectedData(
        //             "At capacity",
        //             "Not taking passengers",
        //             Icons.person_off,
        //             false,
        //           ),
        //         ],
        //       ),
        //       const SizedBox(width: 8),
        //       CustomButton2(leg: leg, options: [
        //         MultiSelectedData(
        //           "Security Guard",
        //           DataState.notUsed,
        //         ),
        //         MultiSelectedData(
        //           "Security Camera",
        //           DataState.enabled,
        //         ),
        //         MultiSelectedData(
        //           "Helpline",
        //           DataState.disabled,
        //         ),
        //       ]),
        //       const SizedBox(width: 8),
        //       // CustomButton(leg: leg),
        //     ],
        //   ),
        // ),
        if (leg.intermediatePlaces != null &&
            leg.intermediatePlaces!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ExpansionTile(
              title: Text(
                '${leg.intermediatePlaces!.length} ${localization.localeName == 'en' ? (leg.intermediatePlaces!.length > 1 ? 'stops' : 'stop') : (leg.intermediatePlaces!.length > 1 ? 'Zwischenstopps' : 'Zwischenstopp')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 0),
              textColor: theme.primaryColor,
              collapsedTextColor: theme.primaryColor,
              iconColor: theme.primaryColor,
              collapsedIconColor: theme.primaryColor,
              childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                ...leg.intermediatePlaces!
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Material(
                          child: InkWell(
                            onTap: () {
                              moveTo(TrufiLatLng(e.lat, e.lon));
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   DateFormat('HH:mm')
                                      //       .format(DateTime.now()),
                                      // ),
                                      // const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(e.name),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
      ],
    );
  }
}
