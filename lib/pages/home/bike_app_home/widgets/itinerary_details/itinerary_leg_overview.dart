import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/defaults_location.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';

import 'bar_itinerary_details.dart';
import 'line_dash_components.dart';

class ItineraryLegOverview extends StatelessWidget {
  final PlanPageController planPageController;
  final void Function() onBackPressed;
  const ItineraryLegOverview({
    Key key,
    @required this.planPageController,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<ConfigurationCubit>().state;
    final localization = TrufiLocalization.of(context);

    final itinerary = planPageController.selectedItinerary;
    final compressedLegs = itinerary.compressLegs;
    return Column(
      children: [
        ...compressedLegs
            .asMap()
            .map<int, Widget>((index, itineraryLeg) {
              return MapEntry(
                index,
                Column(
                  children: [
                    if (index == 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(
                            color: Colors.black,
                          ),
                          BarItineraryDetails(
                            itinerary: itinerary,
                          ),
                          const Divider(
                            color: Colors.black,
                          ),
                          if (itineraryLeg.transportMode ==
                              TransportMode.bicycle)
                            Column(
                              children: [
                                DashLinePlace(
                                  date: itinerary.startTimeHHmm.toString(),
                                  location: _getDisplayName(
                                      itineraryLeg.fromPlace.name,
                                      localization),
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: FittedBox(
                                        child: config.map.markersConfiguration.fromMarker),
                                  ),
                                ),
                                TransportDash(
                                  leg: itineraryLeg,
                                  itinerary: itinerary,
                                  planPageController: planPageController,
                                  isBeforeTransport: false,
                                ),
                              ],
                            )
                          else if (compressedLegs.length > 1)
                            TransportDash(
                                planPageController: planPageController,
                                itinerary: itinerary,
                                leg: itineraryLeg,
                                isFirstTransport: true,
                                isNextTransport: (itineraryLeg.endTime
                                                    .millisecondsSinceEpoch -
                                                compressedLegs[index + 1]
                                                    .startTime
                                                    .millisecondsSinceEpoch)
                                            .abs() >=
                                        0 &&
                                    (itineraryLeg.transportMode !=
                                            TransportMode.bicycle ||
                                        compressedLegs[index + 1]
                                                .transportMode ==
                                            TransportMode.walk))
                        ],
                      )
                    else if (itineraryLeg.transportMode == TransportMode.walk &&
                        index < compressedLegs.length - 1)
                      Column(
                        children: [
                          WalkDash(
                            leg: itineraryLeg,
                            legBefore: compressedLegs[index - 1],
                          ),
                          if (itineraryLeg.endTime.millisecondsSinceEpoch <
                              compressedLegs[index + 1]
                                  .startTime
                                  .millisecondsSinceEpoch)
                            WaitDash(
                              legBefore: itineraryLeg,
                              legAfter: compressedLegs[index + 1],
                            )
                        ],
                      )
                    else if (index < compressedLegs.length - 1)
                      Column(
                        children: [
                          TransportDash(
                              planPageController: planPageController,
                              itinerary: itinerary,
                              leg: itineraryLeg,
                              isBeforeTransport: itineraryLeg.transportMode !=
                                      TransportMode.bicycle ||
                                  compressedLegs[index - 1].transportMode ==
                                      TransportMode.walk ||
                                  index == 0,
                              isNextTransport:
                                  (itineraryLeg.endTime.millisecondsSinceEpoch -
                                              compressedLegs[index + 1]
                                                  .startTime
                                                  .millisecondsSinceEpoch)
                                          .abs() >=
                                      0),
                          if (itineraryLeg.endTime.millisecondsSinceEpoch <
                              compressedLegs[index + 1]
                                  .startTime
                                  .millisecondsSinceEpoch)
                            WaitDash(
                              legBefore: itineraryLeg,
                              legAfter: compressedLegs[index + 1],
                            )
                        ],
                      ),
                    if (index == compressedLegs.length - 1)
                      Column(
                        children: [
                          if (itineraryLeg.transportMode ==
                                  TransportMode.walk &&
                              compressedLegs.length > 1)
                            WalkDash(leg: itineraryLeg)
                          else if (itineraryLeg.transportMode !=
                                  TransportMode.walk &&
                              compressedLegs.length > 1)
                            TransportDash(
                              planPageController: planPageController,
                              itinerary: itinerary,
                              leg: itineraryLeg,
                              isFirstTransport: index == 0,
                              isBeforeTransport: itineraryLeg.transportMode !=
                                      TransportMode.bicycle ||
                                  compressedLegs[index - 1].transportMode ==
                                      TransportMode.walk ||
                                  index == 0,
                            )
                          else if (itineraryLeg.transportMode !=
                              TransportMode.bicycle)
                            TransportDash(
                              planPageController: planPageController,
                              itinerary: itinerary,
                              leg: itineraryLeg,
                              isFirstTransport: index == 0,
                              isBeforeTransport: itineraryLeg.transportMode !=
                                      TransportMode.bicycle ||
                                  index == 0,
                            ),
                          DashLinePlace(
                            date: itinerary.endTimeHHmm.toString(),
                            location: _getDisplayName(
                                itineraryLeg.toPlace.name, localization),
                            child: SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    FittedBox(child: config.map.markersConfiguration.toMarker)),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            })
            .values
            .toList(),
        const SizedBox(height: 30)
      ],
    );
  }

  String _getDisplayName(String name, TrufiLocalization localization) {
    if (name == DefaultLocation.defaultHome.keyLocation) {
      return localization.defaultLocationHome;
    } else if (name == DefaultLocation.defaultWork.keyLocation) {
      return localization.defaultLocationWork;
    }
    return name;
  }
}
