import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';

import 'bar_itinerary_details.dart';
import 'line_dash_components.dart';

class ItineraryDetailsCard extends StatelessWidget {
  final Itinerary itinerary;
  final void Function() onBackPressed;

  const ItineraryDetailsCard({
    Key? key,
    required this.itinerary,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalization.of(context);
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    final mapRouteCubit = context.read<MapRouteCubit>();
    final mapRouteState = mapRouteCubit.state;
    final compresedLegs = itinerary.compressLegs;
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              BackButton(
                onPressed: onBackPressed,
              ),
              Expanded(
                child: BarItineraryDetails(
                  itinerary: itinerary,
                ),
              ),
            ],
          ),
          const Divider(height: 0),
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: compresedLegs.length,
            itemBuilder: (context, index) {
              final itineraryLeg = compresedLegs[index];
              return Column(
                children: [
                  if (index == 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (itineraryLeg.transportMode == TransportMode.walk)
                          Column(
                            children: [
                              DashLinePlace(
                                date: itinerary.startTimeHHmm.toString(),
                                location: mapRouteState.fromPlace
                                        ?.displayName(localization) ??
                                    '',
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const SizedBox(height: 18, width: 24),
                                    Positioned(
                                      top: -5,
                                      right: -1,
                                      left: -1,
                                      child: SizedBox(
                                        height: 28,
                                        width: 28,
                                        child: FittedBox(
                                          child: mapConfiguratiom
                                              .markersConfiguration.fromMarker,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              WalkDash(
                                leg: itineraryLeg,
                              ),
                              if (compresedLegs.length > 1 &&
                                  compresedLegs[index + 1]
                                          .startTime
                                          .difference(itineraryLeg.endTime)
                                          .inSeconds >
                                      0)
                                WaitDash(
                                  legBefore: itineraryLeg,
                                  legAfter: compresedLegs[index + 1],
                                )
                            ],
                          )
                        else if (compresedLegs.length > 1)
                          Column(
                            children: [
                              TransportDash(
                                  itinerary: itinerary,
                                  leg: itineraryLeg,
                                  isFirstTransport: true,
                                  isNextTransport: (itineraryLeg.endTime
                                                      .millisecondsSinceEpoch -
                                                  compresedLegs[index + 1]
                                                      .startTime
                                                      .millisecondsSinceEpoch)
                                              .abs() >=
                                          0 &&
                                      (itineraryLeg.transportMode !=
                                              TransportMode.bicycle ||
                                          compresedLegs[index + 1]
                                                  .transportMode ==
                                              TransportMode.walk)),
                              if (compresedLegs[index + 1]
                                      .startTime
                                      .difference(itineraryLeg.endTime)
                                      .inSeconds >
                                  0)
                                WaitDash(
                                  legBefore: itineraryLeg,
                                  legAfter: compresedLegs[index + 1],
                                )
                            ],
                          )
                      ],
                    )
                  else if (itineraryLeg.transportMode == TransportMode.walk &&
                      index < compresedLegs.length - 1)
                    Column(
                      children: [
                        WalkDash(
                          leg: itineraryLeg,
                          legBefore: compresedLegs[index - 1],
                        ),
                        if (compresedLegs[index + 1]
                                .startTime
                                .difference(itineraryLeg.endTime)
                                .inSeconds >
                            0)
                          WaitDash(
                            legBefore: itineraryLeg,
                            legAfter: compresedLegs[index + 1],
                          )
                      ],
                    )
                  else if (index < compresedLegs.length - 1)
                    Column(
                      children: [
                        TransportDash(
                            itinerary: itinerary,
                            leg: itineraryLeg,
                            isBeforeTransport: itineraryLeg.transportMode !=
                                    TransportMode.bicycle ||
                                compresedLegs[index - 1].transportMode ==
                                    TransportMode.walk ||
                                index == 0,
                            isNextTransport:
                                (itineraryLeg.endTime.millisecondsSinceEpoch -
                                            compresedLegs[index + 1]
                                                .startTime
                                                .millisecondsSinceEpoch)
                                        .abs() >=
                                    0),
                        if (compresedLegs[index + 1]
                                .startTime
                                .difference(itineraryLeg.endTime)
                                .inSeconds >
                            0)
                          WaitDash(
                            legBefore: itineraryLeg,
                            legAfter: compresedLegs[index + 1],
                          )
                      ],
                    ),
                  if (index == compresedLegs.length - 1)
                    Column(
                      children: [
                        if (itineraryLeg.transportMode == TransportMode.walk &&
                            compresedLegs.length > 1)
                          WalkDash(leg: itineraryLeg)
                        else if (itineraryLeg.transportMode !=
                                TransportMode.walk &&
                            compresedLegs.length > 1)
                          TransportDash(
                            itinerary: itinerary,
                            leg: itineraryLeg,
                            isFirstTransport: index == 0,
                            isBeforeTransport: itineraryLeg.transportMode !=
                                    TransportMode.bicycle ||
                                compresedLegs[index - 1].transportMode ==
                                    TransportMode.walk ||
                                index == 0,
                          )
                        else if (itineraryLeg.transportMode !=
                            TransportMode.walk)
                          TransportDash(
                            itinerary: itinerary,
                            leg: itineraryLeg,
                            isFirstTransport: index == 0,
                            isBeforeTransport: itineraryLeg.transportMode !=
                                    TransportMode.bicycle ||
                                index == 0,
                          ),
                        DashLinePlace(
                          date: itinerary.endTimeHHmm.toString(),
                          location: mapRouteState.toPlace
                                  ?.displayName(localization) ??
                              '',
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const SizedBox(height: 24, width: 24),
                              Positioned(
                                top: -3,
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: FittedBox(
                                    child: mapConfiguratiom
                                        .markersConfiguration.toMarker,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
