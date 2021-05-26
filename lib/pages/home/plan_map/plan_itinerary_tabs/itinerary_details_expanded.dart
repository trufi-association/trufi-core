import 'package:flutter/material.dart';

import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';

import 'itinerary_details_expanded/leg_overview.dart';
import 'itinerary_details_expanded/leg_overview_advenced/leg_overview_advenced.dart';

class ItineraryDetailsExpanded extends StatelessWidget {
  final Animation<double> animationDetailHeight;
  final PlanItinerary itinerary;
  final AdEntity ad;

  const ItineraryDetailsExpanded({
    Key key,
    @required this.animationDetailHeight,
    @required this.itinerary,
    @required this.ad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: animationDetailHeight.value,
      child: itinerary.hasAdvencedData
          ? LegOverviewAdvenced(itinerary: itinerary)
          : LegOverview(itinerary: itinerary, ad: ad),
    );
  }
}
