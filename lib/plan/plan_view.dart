import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/plan/plan_itinerary_tab_controller.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_controller.dart';

class PlanView extends StatefulWidget {
  final Plan plan;
  final LatLng yourLocation;

  PlanView(this.plan, this.yourLocation);

  @override
  PlanViewState createState() => PlanViewState();
}

class PlanViewState extends State<PlanView>
    with SingleTickerProviderStateMixin {
  List<PlanItinerary> itineraries;
  PlanItinerary selectedItinerary;
  TabController tabController;

  @override
  void initState() {
    super.initState();
    itineraries = widget.plan?.itineraries ?? List();
    if (itineraries.length > 0) {
      selectedItinerary = itineraries.first;
    }
    tabController =
        TabController(length: widget.plan.itineraries.length, vsync: this)
          ..addListener(() {
            _setItinerary(itineraries[tabController.index]);
          });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: MapControllerPage(
            plan: widget.plan,
            yourLocation: widget.yourLocation,
            onSelected: _setItinerary,
            selectedItinerary: selectedItinerary,
          ),
        ),
        Positioned(
          height: 150.0,
          left: 20.0,
          right: 20.0,
          bottom: 0.0,
          child: _buildItineraries(context),
        ),
      ],
    );
  }

  Widget _buildItineraries(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
      height: 200.0,
      child: PlanItineraryTabPages(
        tabController,
        itineraries,
      ),
    );
  }

  void _setItinerary(PlanItinerary value) {
    setState(() {
      selectedItinerary = value;
      tabController.animateTo(itineraries.indexOf(value));
    });
  }
}
