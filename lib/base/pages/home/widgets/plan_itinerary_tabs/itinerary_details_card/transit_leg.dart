import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core/base/const/consts.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/widgets/plan_itinerary_tabs/itinerary_details_card/route_number.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

class TransitLeg extends StatelessWidget {
  final Leg leg;
  final Function(TrufiLatLng) moveTo;
  final Color? forcedColor;

  const TransitLeg({
    super.key,
    required this.leg,
    required this.moveTo,
    this.forcedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  moveTo(TrufiLatLng(leg.fromPlace.lat, leg.fromPlace.lon));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 5, 5, 5),
                  child: RouteNumber(
                    transportMode: leg.transportMode,
                    realTime: leg.realTime,
                    backgroundColor: forcedColor ?? leg.backgroundColor,
                    textColor: leg.primaryColor,
                    text: leg.headSign,
                    agencyName: leg.agencyName,
                    lastStopName: leg.routeLongName?.split("→")[1],
                    tripHeadSing: leg.headSign,
                    // TODO TrufiChange
                    // duration: leg.durationLeg(localization),
                    distance: leg.distanceString(localization),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                moveTo(TrufiLatLng(leg.fromPlace.lat, leg.fromPlace.lon));
              },
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              child: Image.asset(
                selectBusImage(forcedColor ?? leg.backgroundColor),
                package: 'trufi_core',
                width: 90,
              ),
            ),
          ],
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
          Container(
            padding: const EdgeInsets.only(top: 0),
            // height: 50,
            child: ExpansionTile(
              title: Text(
                '${leg.intermediatePlaces!.length} ${localization.localeName == 'en' ? 'Journey' : 'Recorrido'}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
              dense: true,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 0),
              textColor: theme.colorScheme.onSurface,
              collapsedTextColor: theme.colorScheme.onSurface,
              iconColor: theme.colorScheme.onSurface,
              collapsedIconColor: theme.colorScheme.onSurface,
              childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                ...leg.intermediatePlaces!.map(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: theme.colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String selectBusImage(Color color) {
    String hexColor = colorToHexString(color);
    String? imageAsset;
    switch (hexColor.toUpperCase()) {
      case "FFDBD9D1":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C2.png';
        break;
      case "FFFEDD00":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C3.png';
        break;
      case "FFFF6900":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C4.png';
        break;
      case "FFFF0000":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C5.png';
        break;
      case "FF8D4925":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C6.png';
        break;
      case "FFAFA96E":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C7.png';
        break;
      case "FF00C996":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C8.png';
        break;
      case "FF10069F":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C9.png';
        break;
      case "FFDF1995":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C10.png';
        break;
      case "FF2F4F4F":
        imageAsset = 'assets/Buses-SITransporte/Hyundai_County_V13C11.png';
        break;
    }
    return imageAsset ?? 'assets/Buses-SITransporte/Hyundai_County_V13C2.png';
  }

  String colorToHexString(Color color) {
    return '${color.alpha.toRadixString(16).padLeft(2, '0')}${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }
}
