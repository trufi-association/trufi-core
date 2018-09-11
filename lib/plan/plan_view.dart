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
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: StreamBuilder<LatLng>(
            stream: locationProviderBloc.outLocationUpdate,
            initialData: locationProviderBloc.lastLocation,
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
        Positioned(
          height: _visibleFlag == VisibilityFlag.visible ? 200.0 : 50.0,
          left: 20.0,
          right: 20.0,
          bottom: 0.0,
          child: VisibleWidget(
            child: _buildItinerariesVisible(context),
            visibility: _visibleFlag,
            removedChild: _buildItinerariesGone(context),
          ),
        ),
      ],
    );
  }

  Widget _buildItinerariesVisible(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: IconButton(
        icon: Icon(Icons.keyboard_arrow_up),
        onPressed: _toggleInstructions,
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
}
