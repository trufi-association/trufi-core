import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

import 'bar_itinerary_details.dart';
import 'line_dash_components.dart';

class LegOverviewAdvenced extends StatelessWidget {
  static const _paddingHeight = 20.0;

  final PlanItinerary itinerary;

  const LegOverviewAdvenced({
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
        return Column(
          children: [
            if (index == 0)
              Column(
                children: [
                  BarItineraryDetails(itinerary: itinerary),
                  DashLinePlace(
                    date: itinerary.startTimeHHmm.toString(),
                    location: itineraryLeg.fromName,
                    child: SizedBox(
                        height: 24,
                        width: 24,
                        child: FittedBox(child: config.markers.fromMarker)),
                  )
                ],
              ),
            if (itineraryLeg.transportMode == TransportMode.walk &&
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
                    location: itineraryLeg.toName,
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
}
