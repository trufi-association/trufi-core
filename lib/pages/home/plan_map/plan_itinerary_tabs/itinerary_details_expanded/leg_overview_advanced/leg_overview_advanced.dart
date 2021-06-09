import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/entities/plan_entity/utils/fare_utils.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/defaults_location.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinerary_details_expanded/leg_overview_advanced/ticket_information.dart';
import 'package:trufi_core/services/models_otp/fare_component.dart';

import 'bar_itinerary_details.dart';
import 'line_dash_components.dart';

class LegOverviewAdvanced extends StatefulWidget {
  static const _paddingHeight = 20.0;

  final PlanItinerary itinerary;

  const LegOverviewAdvanced({
    Key key,
    @required this.itinerary,
  }) : super(key: key);

  @override
  _LegOverviewAdvancedState createState() => _LegOverviewAdvancedState();
}

class _LegOverviewAdvancedState extends State<LegOverviewAdvanced> {
  bool loading = true;
  String fetchError;
  List<FareComponent> fares;
  List<FareComponent> unknownFares;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = context.read<ConfigurationCubit>().state;

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: LegOverviewAdvanced._paddingHeight / 2,
        bottom: LegOverviewAdvanced._paddingHeight / 2,
        left: 10.0,
        right: 32.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        final itineraryLeg = widget.itinerary.legs[index];
        final localization = TrufiLocalization.of(context);
        return Column(
          children: [
            if (index == 0)
              Column(
                children: [
                  if (fares != null)
                    TicketInformation(
                      legs: widget.itinerary.legs,
                      fares: fares,
                      unknownFares: unknownFares,
                    ),
                  BarItineraryDetails(itinerary: widget.itinerary),
                  const Divider(
                    color: Colors.black,
                  ),
                  if (itineraryLeg.transportMode == TransportMode.walk)
                    Column(
                      children: [
                        DashLinePlace(
                          date: widget.itinerary.startTimeHHmm.toString(),
                          location: _getDisplayName(
                              itineraryLeg.fromPlace.name, localization),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: FittedBox(child: config.markers.fromMarker),
                          ),
                        ),
                        WalkDash(
                          leg: itineraryLeg,
                        ),
                      ],
                    )
                  else if (widget.itinerary.legs.length > 1)
                    TransportDash(
                      leg: itineraryLeg,
                      isFirstTransport: true,
                      isNextTransport: itineraryLeg.endTimeString ==
                          widget.itinerary.legs[index + 1].startTimeString,
                    )
                ],
              )
            else if (itineraryLeg.transportMode == TransportMode.walk &&
                index < widget.itinerary.legs.length - 1)
              Column(
                children: [
                  WalkDash(
                    leg: itineraryLeg,
                  ),
                  if (itineraryLeg.endTimeString !=
                      widget.itinerary.legs[index + 1].startTimeString)
                    WaitDash(
                      legBefore: itineraryLeg,
                      legAfter: widget.itinerary.legs[index + 1],
                    )
                ],
              )
            else if (index < widget.itinerary.legs.length - 1)
              Column(
                children: [
                  TransportDash(
                    leg: itineraryLeg,
                    isNextTransport: itineraryLeg.endTimeString ==
                        widget.itinerary.legs[index + 1].startTimeString,
                  ),
                  if (itineraryLeg.endTimeString !=
                      widget.itinerary.legs[index + 1].startTimeString)
                    WaitDash(
                      legBefore: itineraryLeg,
                      legAfter: widget.itinerary.legs[index + 1],
                    )
                ],
              ),
            if (index == widget.itinerary.legs.length - 1)
              Column(
                children: [
                  if (itineraryLeg.transportMode == TransportMode.walk)
                    WalkDash(leg: itineraryLeg)
                  else
                    TransportDash(
                      leg: itineraryLeg,
                    ),
                  DashLinePlace(
                    date: widget.itinerary.endTimeHHmm.toString(),
                    location: _getDisplayName(
                        itineraryLeg.toPlace.name, localization),
                    child: SizedBox(
                        height: 24,
                        width: 24,
                        child: FittedBox(child: config.markers.toMarker)),
                  ),
                ],
              ),
          ],
        );
      },
      itemCount: widget.itinerary.legs.length,
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

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() {
      fetchError = null;
      loading = true;
    });
    fetchFares(widget.itinerary).then((value) {
      if (mounted) {
        setState(() {
          fares = getFares(value);
          unknownFares =
              getUnknownFares(value, fares, getRoutes(widget.itinerary.legs));
          loading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          fetchError = "$error";
          loading = false;
        });
      }
    });
  }
}