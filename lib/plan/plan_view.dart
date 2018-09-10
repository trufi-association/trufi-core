import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_bloc.dart';
import 'package:trufi_app/plan/plan_itinerary_tab_controller.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/trufi_map_controller.dart';

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
    LocationBloc locationBloc = BlocProvider.of<LocationBloc>(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: StreamBuilder<LatLng>(
            stream: locationBloc.outLocationUpdate,
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
          child: Visibility(
            child: _buildItineraries(context),
            visibility: _visibleFlag,
            removedChild: new Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
              ),
              child: IconButton(
                icon: Icon(Icons.keyboard_arrow_up),
                onPressed: _toggleInstructions,
              ),
            ),
          ),
        ),
        Positioned(
          right: 20.0,
          bottom: 150.0,
          child: Visibility(
            visibility: _visibleFlag == VisibilityFlag.visible
                ? VisibilityFlag.visible
                : VisibilityFlag.gone,
            child: IconButton(
                color: Colors.black,
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: _toggleInstructions),
            removedChild: new Container(),
          ),
        ),
      ],
    );
  }

  Widget _buildItineraries(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: PlanItineraryTabPages(
        tabController,
        widget.plan.itineraries,
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
      if (_visibleFlag == VisibilityFlag.visible) {
        _visibleFlag = VisibilityFlag.gone;
      } else {
        _visibleFlag = VisibilityFlag.visible;
      }
    });
  }
}

enum VisibilityFlag {
  visible,
  invisible,
  offscreen,
  gone,
}

class Visibility extends StatelessWidget {
  final VisibilityFlag visibility;
  final Widget child;
  final Widget removedChild;

  Visibility({
    @required this.child,
    @required this.visibility,
    @required this.removedChild,
  });

  @override
  Widget build(BuildContext context) {
    if (visibility == VisibilityFlag.visible) {
      return child;
    } else if (visibility == VisibilityFlag.invisible) {
      return new IgnorePointer(
        ignoring: true,
        child: new Opacity(
          opacity: 0.0,
          child: child,
        ),
      );
    } else if (visibility == VisibilityFlag.offscreen) {
      return new Offstage(
        offstage: true,
        child: child,
      );
    } else {
      return removedChild;
    }
  }
}
