import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';

import 'line_dash_components.dart';

class RouteDetails extends StatelessWidget {
  final Itinerary itinerary;
  final Function(TrufiLatLng) moveTo;
  const RouteDetails({
    super.key,
    required this.itinerary,
    required this.moveTo,
  });

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalization.of(context);
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    final mapRouteCubit = context.read<MapRouteCubit>();
    final mapRouteState = mapRouteCubit.state;
    final compresedLegs = itinerary.compressLegs;
    final sizeLegs = compresedLegs.length;
    // TODO Implement a boolean to configure if the backend has a server or not
    // Implement for otpServer without route color configuration
    final showTimeItinerary = mapConfiguratiom.showTimeItinerary;
    bool isPrimary = false;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      physics: const NeverScrollableScrollPhysics(),
      controller: ScrollController(),
      primary: false,
      shrinkWrap: true,
      itemCount: sizeLegs,
      itemBuilder: (context, index) {
        final itineraryLeg = compresedLegs[index];
        return Column(
          children: [
            // fromDashLine
            if (index == 0)
              DashLinePlace(
                date: showTimeItinerary
                    ? itinerary.startTimeHHmm.toString()
                    : null,
                location:
                    mapRouteState.fromPlace?.displayName(localization) ?? '',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const SizedBox(height: 18, width: 24),
                    Positioned(
                      top: -5,
                      right: -1,
                      left: -1,
                      child: Container(
                        height: 28,
                        width: 28,
                        padding: const EdgeInsets.all(4),
                        child: mapConfiguratiom.markersConfiguration.fromMarker,
                      ),
                    ),
                  ],
                ),
              ),

            // Route
            if (itineraryLeg.transitLeg)
              Builder(builder: (_) {
                isPrimary = !isPrimary;
                return TransportDash(
                  leg: itineraryLeg,
                  showBeforeLine: index != 0,
                  showAfterLine: index != sizeLegs - 1 &&
                      !compresedLegs[index + 1].transitLeg,
                  moveTo: moveTo,
                  showTimeItinerary: showTimeItinerary,
                  forcedColor: isPrimary ? null : Colors.green,
                );
              })
            else
              NoTransportDash(leg: itineraryLeg),

            // toDashLine
            if (index == sizeLegs - 1)
              DashLinePlace(
                date:
                    showTimeItinerary ? itinerary.endTimeHHmm.toString() : null,
                location:
                    mapRouteState.toPlace?.displayName(localization) ?? '',
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
                          child: mapConfiguratiom.markersConfiguration.toMarker,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
