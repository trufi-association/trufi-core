import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeleton_animation/skeleton_animation.dart';

import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/entities/plan_entity/utils/geo_utils.dart';
import 'package:trufi_core/entities/plan_entity/utils/time_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/pages/home/plan_map/mode_transport_screen.dart';
import 'package:trufi_core/widgets/card_transport_mode.dart';

class TransportSelector extends StatelessWidget {
  const TransportSelector({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final homePageState = context.watch<HomePageCubit>().state;
    final modesTransport = homePageState.modesTransport;
    final payloadDataPlanState = context.watch<PayloadDataPlanCubit>().state;
    return homePageState.isFetchingModes
        ? Container(
            color: Colors.grey[100],
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Skeleton(
                  padding: 5,
                  width: 100,
                  height: 5,
                  textColor: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                Skeleton(
                  padding: 5,
                  width: 100,
                  height: 5,
                  textColor: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                Skeleton(
                  padding: 5,
                  width: 100,
                  height: 5,
                  textColor: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                Skeleton(
                  padding: 5,
                  width: 100,
                  height: 5,
                  textColor: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          )
        : homePageState.hasTransportModes
            ? Container(
                color: Colors.grey[100],
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (modesTransport.existWalkPlan &&
                        !payloadDataPlanState.wheelchair)
                      CardTransportMode(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ModeTransportScreen(
                              title: localization.commonWalk,
                              plan: modesTransport.walkPlan,
                            ),
                          ));
                        },
                        icon: walkSvg,
                        title: durationToString(
                            localization,
                            modesTransport
                                .walkPlan.itineraries[0].durationTrip),
                        subtitle: displayDistanceWithLocale(
                            localization,
                            modesTransport
                                .walkPlan.itineraries[0].walkDistance),
                      ),
                    if (modesTransport.existBikePlan &&
                        !payloadDataPlanState.wheelchair &&
                        payloadDataPlanState.includeBikeSuggestions)
                      CardTransportMode(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ModeTransportScreen(
                              title:
                                  localization.settingPanelMyModesTransportBike,
                              plan: modesTransport.bikePlan,
                            ),
                          ));
                        },
                        icon: bikeSvg(),
                        title: durationToString(
                            localization,
                            modesTransport
                                .bikePlan.itineraries[0].durationTrip),
                        subtitle: displayDistanceWithLocale(
                            localization,
                            modesTransport
                                .bikePlan.itineraries[0].totalDistance),
                      ),
                    if (modesTransport.existBikeAndVehicle &&
                        !payloadDataPlanState.wheelchair &&
                        payloadDataPlanState.includeBikeSuggestions)
                      CardTransportMode(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ModeTransportScreen(
                              title: localization
                                  .settingPanelMyModesTransportBikeRide,
                              plan: modesTransport.bikeAndVehicle,
                            ),
                          ));
                        },
                        icon: bikeSvg(),
                        secondaryIcon: SizedBox(
                          height: 12,
                          width: 12,
                          child:
                              modesTransport.bikeAndVehicle.iconSecondaryPublic,
                        ),
                        title: durationToString(
                            localization,
                            modesTransport
                                .bikeAndVehicle.itineraries[0].durationTrip),
                        subtitle: displayDistanceWithLocale(
                            localization,
                            modesTransport.bikeAndVehicle.itineraries[0]
                                .totalBikingDistance),
                      ),
                    if (modesTransport.existParkRidePlan &&
                        payloadDataPlanState.includeParkAndRideSuggestions)
                      CardTransportMode(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ModeTransportScreen(
                              title: localization
                                  .settingPanelMyModesTransportParkRide,
                              plan: modesTransport.parkRidePlan,
                            ),
                          ));
                        },
                        icon: carSvg(),
                        secondaryIcon: SizedBox(
                          height: 12,
                          width: 12,
                          child:
                              modesTransport.parkRidePlan.iconSecondaryPublic,
                        ),
                        title: durationToString(
                            localization,
                            modesTransport
                                .parkRidePlan.itineraries[0].durationTrip),
                        subtitle: displayDistanceWithLocale(
                            localization,
                            modesTransport
                                .parkRidePlan.itineraries[0].totalDistance),
                      ),
                    if (modesTransport.existCarAndCarPark &&
                        payloadDataPlanState.includeCarSuggestions)
                      CardTransportMode(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ModeTransportScreen(
                              title: localization.instructionVehicleCar,
                              plan: modesTransport.carAndCarPark,
                            ),
                          ));
                        },
                        icon: carSvg(),
                        title: durationToString(
                            localization,
                            modesTransport
                                .carAndCarPark.itineraries[0].durationTrip),
                        subtitle: displayDistanceWithLocale(
                            localization,
                            modesTransport
                                .carAndCarPark.itineraries[0].totalDistance),
                      ),
                    if (modesTransport.existOnDemandTaxi)
                      CardTransportMode(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ModeTransportScreen(
                              title: localization.instructionVehicleTaxi,
                              plan: modesTransport.onDemandTaxiPlan,
                            ),
                          ));
                        },
                        icon: onDemandTaxiSvg(),
                        title: durationToString(
                            localization,
                            modesTransport
                                .onDemandTaxiPlan.itineraries[0].durationTrip),
                        subtitle: displayDistanceWithLocale(
                            localization,
                            modesTransport
                                .onDemandTaxiPlan.itineraries[0].totalDistance),
                      ),
                  ],
                ),
              )
            : Container();
  }
}
