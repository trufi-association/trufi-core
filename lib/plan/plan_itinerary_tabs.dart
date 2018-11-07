import 'package:flutter/material.dart';

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_models.dart';

class PlanItineraryTabPages extends StatefulWidget {
  PlanItineraryTabPages(
    this.tabController,
    this.itineraries,
    this.toggleInstructions,
  ) : assert(itineraries != null && itineraries.length > 0);

  final TabController tabController;
  final List<PlanItinerary> itineraries;
  final Widget toggleInstructions;

  @override
  PlanItineraryTabPagesState createState() => PlanItineraryTabPagesState();
}

class PlanItineraryTabPagesState extends State<PlanItineraryTabPages> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
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
          Positioned(
            top: 16.0,
            right: 10.0,
            child: widget.toggleInstructions,
          ),
        ],
      ),
    );
  }

  _buildItinerary(BuildContext context, PlanItinerary itinerary) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
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
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.body2,
                      text: localizations.locale.languageCode == "qu"
                          ? leg.toInstructionQuechua(localizations)
                          : leg.toInstruction(localizations),
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
