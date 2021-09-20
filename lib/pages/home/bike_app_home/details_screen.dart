import 'package:flutter/material.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/payload_data_plan/payload_data_plan_cubit.dart';
import 'package:trufi_core/blocs/theme_bloc.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () async {
            // await homePageCubit.reset();
            Navigator.maybePop(context);
          },
        ),
        actions: const [
          Icon(
            Icons.update,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 20)
        ],
        title: Row(
          children: [
            Flexible(
                child: Text(
              homePageState.fromPlace.displayName(localization),
              style: const TextStyle(fontSize: 17),
            )),
            const Icon(
              Icons.arrow_right_alt,
              color: Colors.white,
              size: 35,
            ),
            Flexible(
                child: Text(
              homePageState.toPlace.displayName(localization),
              style: const TextStyle(fontSize: 17),
            )),
          ],
        ),
      ),
      body: CustomScrollableContainer(
        openedPosition: 200,
        body: PlanMapPage(
          planPageController: widget.planPageController,
          customOverlayWidget: null,
          customBetweenFabWidget: null,
          mapConfiguration: cfg.map,
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
    final homePageState = context.read<HomePageCubit>().state;
    final payloadDataPlanState = context.read<PayloadDataPlanCubit>().state;
    final itinerary = planPageController.selectedItinerary;
    return Theme(
      data: theme,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(height: 10),
          Text(
            // TODO translate
            itinerary.firstDeparture()?.headSign ?? "Nur Fahrradroute",
            style: theme.textTheme.bodyText1.copyWith(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            homePageState.fromPlace.displayName(localization),
            style: theme.textTheme.subtitle1.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xffADADAD),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            payloadDataPlanState.triangleFactor.translateValue(localization),
            style: theme.primaryTextTheme.bodyText2.copyWith(
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
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
