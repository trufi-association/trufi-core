import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/pages/home/plan_map/custom_itinerary/custom_itinerary.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';
import 'package:trufi_core/pages/home/plan_map/plan_map.dart';
import 'package:trufi_core/widgets/custom_scrollable_container.dart';

class ModeTransportScreen extends StatelessWidget {
  final PlanEntity plan;
  final String title;

  const ModeTransportScreen({
    Key key,
    @required this.plan,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
          BlocBuilder<HomePageCubit, MapRouteState>(builder: (context, state) {
        PlanEntity currentPlan;
        switch (plan.type) {
          case 'walkPlan':
            currentPlan = state.modesTransport.walkPlan;
            break;
          case 'bikePlan':
            currentPlan = state.modesTransport.bikePlan;
            break;
          case 'bikeAndPublicPlan':
            currentPlan = state.modesTransport.bikeAndVehicle;
            break;
          case 'parkRidePlan':
            currentPlan = state.modesTransport.parkRidePlan;
            break;
          case 'carPlan':
            currentPlan = state.modesTransport.carAndCarPark;
            break;
          case 'onDemandTaxiPlan':
            currentPlan = state.modesTransport.onDemandTaxiPlan;
            break;
          default:
            currentPlan = state.modesTransport.walkPlan;
        }
        return PlanTransportScren(
          planPageController: PlanPageController(currentPlan, null),
        );
      }),
    );
  }
}

class PlanTransportScren extends StatefulWidget {
  final PlanPageController planPageController;
  const PlanTransportScren({Key key, @required this.planPageController})
      : super(key: key);

  @override
  _PlanTransportScrenState createState() => _PlanTransportScrenState();
}

class _PlanTransportScrenState extends State<PlanTransportScren>
    with TickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    if (widget.planPageController.plan.itineraries.isNotEmpty) {
      widget.planPageController.inSelectedItinerary.add(
        widget.planPageController.plan.itineraries.first,
      );
    }
    _tabController = TabController(
      length: widget.planPageController.plan.itineraries.length,
      vsync: this,
    )..addListener(() {
        widget.planPageController.inSelectedItinerary.add(
          widget.planPageController.plan.itineraries[_tabController.index],
        );
      });
    widget.planPageController.outSelectedItinerary.listen((selectedItinerary) {
      _tabController.animateTo(
        widget.planPageController.plan.itineraries.indexOf(selectedItinerary),
      );
    });
  }

  @override
  void dispose() {
    widget.planPageController?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigurationCubit>().state;
    final homePageCubit = context.watch<HomePageCubit>();
    final homePageState = homePageCubit.state;
    return Stack(
      children: [
        CustomScrollableContainer(
          openedPosition: 200,
          body: PlanMapPage(
            planPageController: widget.planPageController,
            customOverlayWidget: null,
            customBetweenFabWidget: null,
            mapConfiguration: cfg.map,
          ),
          panel: homePageState.isFetching
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CustomItinerary(
                  planPageController: widget.planPageController,
                ),
        ),
        if (cfg.animations.loading != null && homePageState.isFetching)
          Positioned.fill(child: cfg.animations.loading)
      ],
    );
  }
}
