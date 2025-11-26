import 'package:flutter/material.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/widgets/travel_bottom_sheet/travel_mode_section.dart/transit_mode_section/itinerary_card/itinerary_card.dart';


class TransitModeSection extends StatelessWidget {
  final void Function(PlanItinerary) onSelectItinerary;
  final PlanEntity plan;
  const TransitModeSection({
    super.key,
    required this.onSelectItinerary,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final itineraries = plan.itineraries ?? [];
    return Column(
      children: [
        Row(children: []),
        ...itineraries.map((itinerary) {
          return Column(
            children: [
              ItineraryCard(
                itinerary: itinerary,
                onTap: () {
                  onSelectItinerary(itinerary);
                },
              ),
              Divider(height: 0),
            ],
          );
        }),
      ],
    );
  }
}
