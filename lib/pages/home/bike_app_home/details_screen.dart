import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
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
    final selectedItinerary = planPageController.selectedItinerary;
    final index = planPageController.plan.itineraries.indexOf(
      selectedItinerary,
    );
    return ListView(
      children: [
        Text("Route $index Uber Station X$index"),
      ],
    );
  }
}
