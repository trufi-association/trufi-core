import 'package:flutter/material.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class RouteNumber extends StatelessWidget {
  final TransportMode transportMode;
  final Color backgroundColor;
  final String text;
  final String distance;
  final String duration;
  final Widget icon;
  final String mode;

  const RouteNumber({
    Key key,
    this.transportMode,
    this.backgroundColor,
    this.text,
    this.distance,
    this.duration,
    this.icon,
    this.mode,
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
            color: backgroundColor ?? Colors.black,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              if (icon != null)
                SizedBox(
                  height: 20,
                  width: 20,
                  child: icon,
                )
              else
                SizedBox(
                    height: 20,
                    width: 20,
                    child: transportMode.getImage(
                        color: transportMode == TransportMode.bicycle
                            ? transportMode.color
                            : Colors.white)),
              if (transportMode != TransportMode.walk &&
                  transportMode != TransportMode.bicycle)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    text,
                    style: theme.primaryTextTheme.headline6.copyWith(
                      fontWeight: FontWeight.w600,
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
