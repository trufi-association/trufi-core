import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/defaults_location.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

import 'bar_itinerary_details.dart';
import 'line_dash_components.dart';

class LegOverviewAdvanced extends StatelessWidget {
  static const _paddingHeight = 20.0;

  final PlanItinerary itinerary;

  const LegOverviewAdvanced({
    Key key,
    @required this.itinerary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<ConfigurationCubit>().state;
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: _paddingHeight / 2,
        bottom: _paddingHeight / 2,
        left: 10.0,
        right: 32.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        final itineraryLeg = itinerary.legs[index];
        final localization = TrufiLocalization.of(context);
        return Column(
          children: [
            if (index == 0)
              Column(
                children: [
                  BarItineraryDetails(itinerary: itinerary),
                  const Divider(
                    color: Colors.black,
                  ),
                  if (itineraryLeg.transportMode == TransportMode.walk)
                    DashLinePlace(
                      date: itinerary.startTimeHHmm.toString(),
                      location: _getDisplayName(
                          itineraryLeg.fromPlace.name, localization),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: FittedBox(child: config.markers.fromMarker),
                      ),
                    )
                  else if (itinerary.legs.length > 1)
                    TransportDash(
                      leg: itineraryLeg,
                      isFirstTransport: true,
                      isNextTransport: itineraryLeg.endTimeString ==
                          itinerary.legs[index + 1].startTimeString,
                    ),
                ],
              )
            else if (itineraryLeg.transportMode == TransportMode.walk &&
                index < itinerary.legs.length - 1)
              Column(
                children: [
                  WalkDash(
                    leg: itineraryLeg,
                  ),
                  if (itineraryLeg.endTimeString !=
                      itinerary.legs[index + 1].startTimeString)
                    WaitDash(
                      legBefore: itineraryLeg,
                      legAfter: itinerary.legs[index + 1],
                    )
                ],
              )
            else if (index < itinerary.legs.length - 1)
              Column(
                children: [
                  TransportDash(
                    leg: itineraryLeg,
                    isNextTransport: itineraryLeg.endTimeString ==
                        itinerary.legs[index + 1].startTimeString,
                  ),
                  if (itineraryLeg.endTimeString !=
                      itinerary.legs[index + 1].startTimeString)
                    WaitDash(
                      legBefore: itineraryLeg,
                      legAfter: itinerary.legs[index + 1],
                    )
                ],
              ),
            if (index == itinerary.legs.length - 1)
              Column(
                children: [
                  if (itineraryLeg.transportMode == TransportMode.walk)
                    WalkDash(leg: itineraryLeg)
                  else
                    TransportDash(
                      leg: itineraryLeg,
                    ),
                  DashLinePlace(
                    date: itinerary.endTimeHHmm.toString(),
                    location: _getDisplayName(
                        itineraryLeg.toPlace.name, localization),
                    child: SizedBox(
                        height: 24,
                        width: 24,
                        child: FittedBox(child: config.markers.toMarker)),
                  )
                ],
              )
          ],
        );
      },
      itemCount: itinerary.legs.length,
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
