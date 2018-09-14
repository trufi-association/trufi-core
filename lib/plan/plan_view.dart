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

class PlanViewState extends State<PlanView> with TickerProviderStateMixin {
  PlanItinerary selectedItinerary;
  TabController tabController;
  VisibilityFlag _visibleFlag = VisibilityFlag.visible;

  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    animation = Tween(begin: 200.0, end: 60.0).animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    if (widget.plan.itineraries.length > 0) {
      selectedItinerary = widget.plan.itineraries.first;
    }
    tabController = TabController(
      length: widget.plan.itineraries.length,
      vsync: this,
    )..addListener(() {
        _setItinerary(widget.plan.itineraries[tabController.index]);
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget _buildItinerariesVisible(BuildContext context) {
    return Container(
      height: animation.value,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: PlanItineraryTabPages(
        tabController,
        widget.plan.itineraries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    ThemeData theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<LatLng>(
                stream: locationProviderBloc.outLocationUpdate,
                builder:
                    (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
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
        ),
        Positioned(
          bottom: animation.value - 28.0,
          right: 16.0,
          child: FloatingActionButton(
            child: _visibleFlag == VisibilityFlag.visible
                ? Icon(Icons.keyboard_arrow_down, color: Colors.black)
                : Icon(Icons.keyboard_arrow_up, color: Colors.black),
            onPressed: _toggleInstructions,
            backgroundColor: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildItinerariesGone(BuildContext context) {
    return Container(
      height: animation.value,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: _toggleInstructions,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(child: _buildItinerarySummary(selectedItinerary)),
              ],
            ),
          ),
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
      if (_visibleFlag == VisibilityFlag.gone) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
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
