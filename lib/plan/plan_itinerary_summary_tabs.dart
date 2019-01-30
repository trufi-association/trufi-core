import 'package:flutter/material.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';

class PlanItinerarySummaryTabPages extends StatefulWidget {
  PlanItinerarySummaryTabPages(
    this.animationDurationHeight,
    this.animationInstructionHeight,
    this.tabController,
    this.itineraries,
    this.toggleInstructions,
  ) : assert(itineraries != null && itineraries.length > 0);

  final double animationDurationHeight;
  final double animationInstructionHeight;
  final TabController tabController;
  final List<PlanItinerary> itineraries;
  final Widget toggleInstructions;

  @override
  PlanItinerarySummaryTabPagesState createState() =>
      PlanItinerarySummaryTabPagesState();
}

class PlanItinerarySummaryTabPagesState
    extends State<PlanItinerarySummaryTabPages> {
  @override
  Widget build(BuildContext context) {
    List itinenarySummaryTabs = List<Column>();
    widget.itineraries.forEach((itinerary) => itinenarySummaryTabs.add(
          Column(
            children: <Widget>[
              _buildTotalDurationFromSelectedItinerary(
                context,
                itinerary,
              ),
              _buildItinerarySummary(
                context,
                itinerary,
              ),
            ],
          ),
        ));
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: TabBarView(
                  controller: widget.tabController,
                  children: itinenarySummaryTabs,
                ),
              ),
              TabPageSelector(
                selectedColor: Theme.of(context).iconTheme.color,
                controller: widget.tabController,
              ),
            ],
          ),
          Positioned(
            top: 16.0,
            right: 10.0,
            child: widget.toggleInstructions,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDurationFromSelectedItinerary(
      BuildContext context, PlanItinerary itinerary) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final legs = itinerary?.legs ?? [];
    var totalTime = 0.0;
    var totalDistance = 0.0;

    for (PlanItineraryLeg leg in legs) {
      totalTime += (leg.duration.ceil() / 60).ceil();
      totalDistance += leg.distance.ceil();
    }
    Color backgroundColor = Theme.of(context).primaryColor;
    return Container(
      height: widget.animationDurationHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: backgroundColor, blurRadius: 4.0)
        ],
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Text(
            "${totalTime.ceil()} ${localizations.instructionMinutes} ",
            style: theme.textTheme.title,
          ),
          totalDistance >= 1000
              ? Text(
                  "(${(totalDistance.ceil() / 1000).ceil()} ${localizations.instructionUnitKm})",
                  style: theme.textTheme.title.copyWith(color: Colors.grey),
                )
              : Text(
                  "(${totalDistance.ceil()} ${localizations.instructionUnitMeter})",
                  style: theme.textTheme.title,
                ),
        ],
      ),
    );
  }

  Widget _buildItinerarySummary(BuildContext context, PlanItinerary itinerary) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final children = List<Widget>();
    final legs = itinerary?.legs ?? [];
    for (var i = 0; i < legs.length; i++) {
      final leg = legs[i];
      children.add(
        Row(
          children: <Widget>[
            Icon(leg.iconData()),
            leg.mode == 'BUS'
                ? Text(
                    leg.route,
                    style: theme.textTheme.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    "${(leg.duration.ceil() / 60).ceil().toString()} ${localizations.instructionMinutes}",
                    style: theme.textTheme.body1,
                  ),
            i < (legs.length - 1)
                ? Icon(Icons.keyboard_arrow_right, color: Colors.grey)
                : Container(),
          ],
        ),
      );
    }
    return Container(
      height: widget.animationInstructionHeight,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Material(
        color: Theme.of(context).primaryColor,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      Row(children: children),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
