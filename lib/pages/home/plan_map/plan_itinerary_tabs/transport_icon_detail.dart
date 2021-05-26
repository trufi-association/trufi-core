import 'package:flutter/material.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class LegTransportIcon extends StatelessWidget {
  final PlanItineraryLeg leg;

  const LegTransportIcon({
    Key key,
    @required this.leg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Row(
      children: [
        Icon(leg.transportMode.icon, color: Colors.white),
        if (leg.transportMode != TransportMode.walk)
          Text(
            " ${leg.route}",
            style: theme.primaryTextTheme.headline6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Text(
            localization
                .instructionDurationMinutes((leg.duration.ceil() / 60).ceil()),
            style: theme.primaryTextTheme.headline6,
          ),
        const SizedBox(width: 4)
      ],
    );
  }
}
