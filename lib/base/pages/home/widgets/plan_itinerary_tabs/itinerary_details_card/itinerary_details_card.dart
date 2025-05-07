import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';

import 'bar_itinerary_details.dart';
import 'line_dash_components.dart';

class ItineraryDetailsCard extends StatefulWidget {
  final Itinerary itinerary;
  final void Function() onBackPressed;
  final bool Function(TrufiLatLng) moveTo;

  const ItineraryDetailsCard({
    super.key,
    required this.itinerary,
    required this.onBackPressed,
    required this.moveTo,
  });

  @override
  State<ItineraryDetailsCard> createState() => _ItineraryDetailsCardState();
}

class _ItineraryDetailsCardState extends State<ItineraryDetailsCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final localization = SavedPlacesLocalization.of(context);
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;
    final compresedLegs = widget.itinerary.compressLegs;
    final sizeLegs = compresedLegs.length;
    // TODO Implement a boolean to configure if the backend has a server or not
    // Implement for otpServer without route color configuration
    bool isPrimary = false;

    return Scrollbar(
      child: SingleChildScrollView(
        controller: _scrollController,
        primary: false,
        child: Column(
          children: [
            Row(
              children: [
                BackButton(
                  onPressed: widget.onBackPressed,
                ),
                Expanded(
                  child: BarItineraryDetails(
                    itinerary: widget.itinerary,
                  ),
                ),
              ],
            ),
            const Divider(height: 0),
            ListView.builder(
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
                        date: widget.itinerary.startTimeHHmm.toString(),
                        location: routePlannerState.fromPlace
                                ?.displayName(localization) ??
                            '',
                        moveInMap: () =>
                            widget.moveTo(routePlannerState.fromPlace!.latLng),
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
                                child: mapConfiguratiom
                                    .markersConfiguration.fromMarker,
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
                          moveTo: (location) {
                            final isRequiredScroll = widget.moveTo(location);
                            if (isRequiredScroll) {
                              _scrolling(index);
                            }
                          },
                          forcedColor: isPrimary ? null : Colors.green,
                        );
                      })
                    else
                      WalkDash(
                        leg: itineraryLeg,
                        moveTo: (location) {
                          final isRequiredScroll = widget.moveTo(location);
                          if (isRequiredScroll) {
                            _scrolling(index);
                          }
                        },
                      ),

                    // toDashLine
                    if (index == sizeLegs - 1)
                      DashLinePlace(
                        date: widget.itinerary.endTimeHHmm.toString(),
                        location: routePlannerState.toPlace
                                ?.displayName(localization) ??
                            '',
                        moveInMap: () {
                          final isRequiredScroll =
                              widget.moveTo(routePlannerState.toPlace!.latLng);
                          if (isRequiredScroll) {
                            _scrolling(index);
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const SizedBox(height: 18, width: 24),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scrolling(int index) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scrollController.animateTo(
      70.0 * index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
