import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

import 'bar_itinerary_details.dart';
import 'route_details.dart';

class ItineraryDetailsCard extends StatelessWidget {
  final Itinerary itinerary;
  final void Function() onBackPressed;
  final Function(TrufiLatLng) moveTo;

  const ItineraryDetailsCard({
    Key? key,
    required this.itinerary,
    required this.onBackPressed,
    required this.moveTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        controller: ScrollController(),
        primary: false,
        child: Column(
          children: [
            Row(
              children: [
                BackButton(
                  onPressed: onBackPressed,
                ),
                Expanded(
                  child: BarItineraryDetails(
                    itinerary: itinerary,
                  ),
                ),
              ],
            ),
            const Divider(height: 0),
            RouteDetails(
              itinerary: itinerary,
              moveTo: moveTo,
            )
          ],
        ),
      ),
    );
  }
}
