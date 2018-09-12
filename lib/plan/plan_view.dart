import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/plan/plan_itinerary_tab_controller.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_controller.dart';
import 'package:trufi_app/widgets/visible.dart';

class PlanView extends StatefulWidget {
  final Plan plan;

  PlanView(this.plan) : assert(plan != null);

  @override
  PlanViewState createState() => PlanViewState();
}

class PlanViewState extends State<PlanView>
    with SingleTickerProviderStateMixin {
  PlanItinerary selectedItinerary;
  TabController tabController;
  VisibilityFlag _visibleFlag = VisibilityFlag.visible;

  @override
  void initState() {
    super.initState();
    if (widget.plan.itineraries.length > 0) {
      selectedItinerary = widget.plan.itineraries.first;
    }
    tabController =
        TabController(length: widget.plan.itineraries.length, vsync: this)
          ..addListener(() {
            _setItinerary(widget.plan.itineraries[tabController.index]);
          });
  }

  @override
  Widget build(BuildContext context) {
    LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder<LatLng>(
            stream: locationProviderBloc.outLocationUpdate,
            initialData: locationProviderBloc.location,
            builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
              return MapControllerPage(
                plan: widget.plan,
                initialPosition: snapshot.data,
                onSelected: _setItinerary,
                selectedItinerary: selectedItinerary,
              );
            },
          ),
        ),
        VisibleWidget(
          child: _buildItinerariesVisible(context),
          visibility: _visibleFlag,
          removedChild: _buildItinerariesGone(context),
        ),
      ],
    );
  }

  Widget _buildItinerariesVisible(BuildContext context) {
    return Container(
      height: 200.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: PlanItineraryTabPages(
        tabController,
        widget.plan.itineraries,
        _toggleInstructions,
      ),
    );
  }

  Widget _buildItinerariesGone(BuildContext context) {
    return Container(
      height: 60.0,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: InkWell(
        onTap: _toggleInstructions,
        child: Row(
          children: <Widget>[
            Expanded(
              child: _buildItinerarySummary(selectedItinerary),
            ),
            Icon(Icons.keyboard_arrow_up),
          ],
        ),
      ),
    );
  }

  void _setItinerary(PlanItinerary value) {
    setState(() {
      selectedItinerary = value;
      tabController.animateTo(widget.plan.itineraries.indexOf(value));
    });
  }

  void _toggleInstructions() {
    setState(() {
      _visibleFlag = _visibleFlag == VisibilityFlag.visible
          ? VisibilityFlag.gone
          : VisibilityFlag.visible;
    });
  }

  Widget _buildItinerarySummary(PlanItinerary itinerary) {
    List<Widget> summary = List();
    var legs = itinerary.legs;
    for (var i = 0; i < legs.length; i++) {
      var leg = legs[i];
      summary.add(
        Row(
          children: <Widget>[
            Icon(leg.iconData()),
            leg.mode == 'BUS'
                ? Text(
                    leg.route,
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  )
                : Text((leg.duration.ceil() ~/ 60).toString()),
            i < (legs.length - 1)
                ? Icon(Icons.keyboard_arrow_right)
                : Container(),
          ],
        ),
      );
    }
    return Row(
      children: summary,
    );
  }
}
