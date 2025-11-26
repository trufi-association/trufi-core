import 'package:flutter/material.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/widgets/travel_bottom_sheet/travel_mode_section.dart/transit_mode_section/itinerary_card/itinerary_path.dart';
import 'package:trufi_core/widgets/utils/date_time_utils.dart';

class ItineraryCard extends StatelessWidget {
  final PlanItinerary itinerary;
  final VoidCallback onTap;
  const ItineraryCard({
    super.key,
    required this.itinerary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: ItineraryPath(itinerary: itinerary)),
                  Text(
                    DateTimeUtils.durationToStringTime(itinerary.duration),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                itinerary.getFirstLegDepartureMessage(),
                style: TextStyle(color: theme.dividerColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
