import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_models.dart';

typedef OnTapCallback = void Function();

class PlanItineraryTabPages extends StatefulWidget {
  final TabController tabController;
  final List<PlanItinerary> itineraries;

  PlanItineraryTabPages(
    this.tabController,
    this.itineraries,
  ) : assert(itineraries != null && itineraries.length > 0);

  @override
  PlanItineraryTabPagesState createState() => PlanItineraryTabPagesState();
}

class PlanItineraryTabPagesState extends State<PlanItineraryTabPages> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: TabBarView(
                    controller: widget.tabController,
                    children: widget.itineraries.map<Widget>((
                      PlanItinerary itinerary,
                    ) {
                      return _buildItinerary(context, itinerary);
                    }).toList(),
                  ),
                ),
                TabPageSelector(
                  selectedColor: Colors.black,
                  controller: widget.tabController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildItinerary(BuildContext context, PlanItinerary itinerary) {
    ThemeData theme = Theme.of(context);
    return SafeArea(
      child: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {
          PlanItineraryLeg leg = itinerary.legs[index];
          return Row(
            children: <Widget>[
              Icon(leg.iconData()),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.body2,
                      text: leg.toInstruction(context),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        itemCount: itinerary.legs.length,
      ),
    );
  }
}
