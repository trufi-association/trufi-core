import 'package:flutter/material.dart';
import 'package:trufi_core/models/enums/transport_mode.dart';
import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/widgets/utils.dart';
import 'package:trufi_core/widgets/utils/date_time_utils.dart';

class ItineraryPath extends StatelessWidget {
  final PlanItinerary itinerary;
  const ItineraryPath({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: itinerary.legs.asMap().entries.map((entry) {
        final index = entry.key;
        final leg = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: leg.transitLeg
                  ? TransitIcon(leg: leg)
                  : WalkIcon(leg: leg),
            ),
            if (index != itinerary.legs.length - 1)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                child: FittedBox(
                  fit: BoxFit.none,
                  child: Icon(Icons.keyboard_arrow_right, size: 18),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class TransitIcon extends StatelessWidget {
  final PlanItineraryLeg leg;
  const TransitIcon({super.key, required this.leg});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        leg.transportMode.getImage(
          color: Theme.of(context).colorScheme.onSurface,
          size: leg.transportMode != TransportMode.walk ? 24 : 22,
        ),
        Container(
          margin: EdgeInsets.only(right: 4),
          padding: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: hexToColor(leg.route?.color),
          ),
          child: Text(
            leg.route?.shortName ?? '',
            style: TextStyle(
              color: hexToColor(leg.route?.textColor ?? 'ffffff'),
            ),
          ),
        ),
      ],
    );
  }
}

class WalkIcon extends StatelessWidget {
  final PlanItineraryLeg leg;
  const WalkIcon({super.key, required this.leg});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          // color: Colors.amber,
          width: 14,
          height: 24,
          child: FittedBox(
            fit: BoxFit.none,
            child: leg.transportMode.getImage(
              color: Theme.of(context).colorScheme.onSurface,
              size: leg.transportMode != TransportMode.walk ? 24 : 22,
            ),
          ),
        ),
        Text(
          DateTimeUtils.durationToStringMinutes(leg.duration),
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
