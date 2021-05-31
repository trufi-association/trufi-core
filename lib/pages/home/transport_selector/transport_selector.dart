import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/icons/other_icons.dart';
import 'package:trufi_core/pages/home/plan_map/mode_transport_screen.dart';
import 'package:trufi_core/widgets/card_transport_mode.dart';

class TransportSelector extends StatelessWidget {
  const TransportSelector({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiLocalization.of(context);
    final modesTransport = context.watch<HomePageCubit>().state.modesTransport;
    return Container(
      color: Colors.grey[100],
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (modesTransport.existBikeAndPublicPlan)
            CardTransportMode(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ModeTransportScreen(
                    title: localization.settingPanelMyModesTransportBike,
                    plan: modesTransport.bikeAndPublicPlan,
                  ),
                ));
              },
              icon: bikeSvg,
              title: modesTransport.bikeAndPublicPlan.itineraries[0]
                  .walkTimeHHmm(localization),
              subtitle: modesTransport.bikeAndPublicPlan.itineraries[0]
                  .getWalkDistanceString(localization),
            ),
          if (modesTransport.existBikeParkPlan)
            CardTransportMode(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ModeTransportScreen(
                    title: localization.settingPanelMyModesTransportBike,
                    plan: modesTransport.bikeParkPlan,
                  ),
                ));
              },
              icon: bikeSvg,
              title: modesTransport.bikeParkPlan.itineraries[0]
                  .durationTripString(localization),
              subtitle: modesTransport.bikeParkPlan.itineraries[0]
                  .getDistanceString(localization),
            ),
          if (modesTransport.existParkRidePlan)
            CardTransportMode(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ModeTransportScreen(
                    title: localization.settingPanelMyModesTransportParkRide,
                    plan: modesTransport.parkRidePlan,
                  ),
                ));
              },
              icon: parkRideSvg,
              title: modesTransport.parkRidePlan.itineraries[0]
                  .durationTripString(localization),
              subtitle: modesTransport.parkRidePlan.itineraries[0]
                  .getDistanceString(localization),
            ),
          if (modesTransport.existCarPlan)
            CardTransportMode(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ModeTransportScreen(
                    title: localization.instructionVehicleCar,
                    plan: modesTransport.carPlan,
                  ),
                ));
              },
              icon: carSvg,
              title: modesTransport.carPlan.itineraries[0]
                  .durationTripString(localization),
              subtitle: modesTransport.carPlan.itineraries[0]
                  .getDistanceString(localization),
            ),
        ],
      ),
    );
  }
}
