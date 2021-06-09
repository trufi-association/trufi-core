import 'package:flutter/material.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class RouteNumber extends StatelessWidget {
  final TransportMode transportMode;
  final Color color;
  final String text;
  final String distance;
  final String duration;
  final Widget icon;

  const RouteNumber({
    Key key,
    this.transportMode,
    this.color,
    this.text,
    this.distance,
    this.duration,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: color ?? transportMode.backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              if (icon != null)
                SizedBox(
                  height: 28,
                  width: 28,
                  child: icon,
                )
              else if (transportMode?.image != null)
                SizedBox(height: 28, width: 28, child: transportMode.image)
              else
                Icon(transportMode.icon, color: Colors.white),
              if (transportMode != TransportMode.walk)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    text,
                    style: theme.primaryTextTheme.headline6.copyWith(
                      fontWeight: FontWeight.w600,
                      color: transportMode == TransportMode.car
                          ? transportMode.color
                          : null,
                    ),
                  ),
                )
            ],
          ),
        ),
        Text(
          '  $duration',
          style: theme.primaryTextTheme.bodyText1,
        ),
        Text(
          '  ($distance)',
          style: theme.primaryTextTheme.bodyText1,
        ),
      ],
    );
  }
}
