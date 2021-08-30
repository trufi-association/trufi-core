import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/itinerary_details/itinerary_leg_overview.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
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
    final homePageState = context.watch<HomePageCubit>().state;
    final localization = TrufiLocalization.of(context);
    widget.planPageController.selectedItinerary;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
                child: Text(homePageState.fromPlace.displayName(localization))),
            const Icon(
              Icons.arrow_right_alt,
              color: Colors.white,
              size: 35,
            ),
            Flexible(
                child: Text(homePageState.toPlace.displayName(localization))),
          ],
        ),
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
    final theme = context.read<ThemeCubit>().state.bottomBarTheme;
    final localization = TrufiLocalization.of(context);
    final itinerary = planPageController.selectedItinerary;
    final index = planPageController.plan.itineraries.indexOf(
      itinerary,
    );
    return Theme(
      data: theme,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          Text(
            "Route $index Uber Station X$index",
            style:
                theme.textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                "${itinerary.legs[0].fromPlace.name} ",
                style: theme.textTheme.bodyText1.copyWith(fontSize: 17),
              ),
              Text(
                localization.instructionDurationMinutes(itinerary.time),
                style: theme.textTheme.bodyText2.copyWith(fontSize: 17),
              ),
              Text(
                " (${itinerary.getDistanceString(localization)})",
                style: theme.textTheme.bodyText2.copyWith(fontSize: 17),
              ),
            ],
          ),
          Text(
            "Mehr Bike als Bahn",
            style: theme.primaryTextTheme.bodyText1,
          ),
          Container(
            color: Colors.transparent,
            child: ItineraryLegOverview(
              planPageController: planPageController,
            ),
          ),
        ],
      ),
    );
  }
}
