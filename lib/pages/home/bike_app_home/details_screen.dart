import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/plan_map/plan_itinerary_tabs/itinerary_details_expanded/leg_overview_advanced/leg_overview_advanced.dart';
import 'package:trufi_core/pages/home/plan_map/plan_map.dart';
import 'package:trufi_core/widgets/custom_scrollable_container.dart';

class BikeDetailScreen extends StatefulWidget {
  const BikeDetailScreen({
    Key key,
    @required this.planPageController,
  }) : super(key: key);

  final PlanPageController planPageController;

  @override
  _BikeDetailScreenState createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends State<BikeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigurationCubit>().state;
    widget.planPageController.selectedItinerary;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Title"),
      ),
      body: CustomScrollableContainer(
        openedPosition: 200,
        body: PlanMapPage(
          planPageController: widget.planPageController,
          customOverlayWidget: null,
          customBetweenFabWidget: null,
          markerConfiguration: cfg.markers,
          transportConfiguration: cfg.transportConf,
        ),
        panel: ItineraryDetails(
          planPageController: widget.planPageController,
        ),
      ),
    );
  }
}

class ItineraryDetails extends StatelessWidget {
  const ItineraryDetails({
    Key key,
    @required this.planPageController,
  }) : super(key: key);

  final PlanPageController planPageController;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final itinerary = planPageController.selectedItinerary;
    final index = planPageController.plan.itineraries.indexOf(
      itinerary,
    );
    return ListView(
      children: [
        Text("Route $index Uber Station X$index"),
        Row(
          children: [
            Text(
              "${itinerary.legs[0].fromPlace.name} ",
              style: theme.textTheme.bodyText2,
            ),
            Text(localization.instructionDurationMinutes(itinerary.time)),
            Text(
              " (${itinerary.getDistanceString(localization)})",
              style: theme.textTheme.bodyText2,
            ),
          ],
        ),
        const Text("Mehr Bike als Bahn"),
        Container(
          color: Colors.black,
          child: LegOverviewAdvanced(
            planPageController: planPageController,
            itinerary: itinerary,
          ),
        ),
      ],
    );
  }
}
