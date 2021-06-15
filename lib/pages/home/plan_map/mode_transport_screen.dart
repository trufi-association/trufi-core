import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/pages/home/plan_map/custom_itinerary/custom_itinerary.dart';
import 'package:trufi_core/pages/home/plan_map/plan.dart';
import 'package:trufi_core/pages/home/plan_map/plan_map.dart';
import 'package:trufi_core/widgets/custom_scrollable_container.dart';

class ModeTransportScreen extends StatefulWidget {
  final PlanEntity plan;
  final String title;

  const ModeTransportScreen({
    Key key,
    @required this.plan,
    @required this.title,
  }) : super(key: key);

  @override
  _ModeTransportScreenState createState() => _ModeTransportScreenState();
}

class _ModeTransportScreenState extends State<ModeTransportScreen>
    with TickerProviderStateMixin {
  PlanPageController _planPageController;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _planPageController = PlanPageController(widget.plan, null);
    if (_planPageController.plan.itineraries.isNotEmpty) {
      _planPageController.inSelectedItinerary.add(
        _planPageController.plan.itineraries.first,
      );
    }
    _tabController = TabController(
      length: _planPageController.plan.itineraries.length,
      vsync: this,
    )..addListener(() {
        _planPageController.inSelectedItinerary.add(
          _planPageController.plan.itineraries[_tabController.index],
        );
      });
    _planPageController.outSelectedItinerary.listen((selectedItinerary) {
      _tabController.animateTo(
        _planPageController.plan.itineraries.indexOf(selectedItinerary),
      );
    });
  }

  @override
  void dispose() {
    _planPageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigurationCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: CustomScrollableContainer(
        openedPosition: 200,
        body: PlanMapPage(
          planPageController: _planPageController,
          customOverlayWidget: null,
          customBetweenFabWidget: null,
          markerConfiguration: cfg.markers,
        ),
        panel: CustomItinerary(
          planPageController: _planPageController,
        ),
      ),
      //  Stack(
      //   children: <Widget>[
      //     Column(
      //       children: <Widget>[
      //         Expanded(
      //           child: PlanMapPage(
      //             planPageController: _planPageController,
      //             customOverlayWidget: null,
      //             customBetweenFabWidget: null,
      //             markerConfiguration: cfg.markers,
      //           ),
      //         ),
      //         PlanItineraryTabPages(
      //           _tabController,
      //           _planPageController.plan.itineraries,
      //           _planPageController.ad,
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}
