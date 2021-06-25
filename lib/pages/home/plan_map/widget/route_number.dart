import 'package:flutter/material.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class RouteNumber extends StatelessWidget {
  final TransportMode transportMode;
  final Color backgroundColor;
  final String text;
  final String tripHeadSing;
  final String distance;
  final String duration;
  final Widget icon;
  final String mode;

  const RouteNumber({
    Key key,
    this.transportMode,
    this.backgroundColor,
    this.text,
    this.tripHeadSing,
    this.distance,
    this.duration,
    this.icon,
    this.mode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
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
                      Container(
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
              if (transportMode != TransportMode.bicycle &&
                  transportMode != TransportMode.car)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 150,
                  child: Text(
                    tripHeadSing ?? '',
                    style: theme.primaryTextTheme.bodyText1,
                    overflow: TextOverflow.visible,
                  ),
                )
              else
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      duration ?? '',
                      style: theme.primaryTextTheme.bodyText1,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      distance ?? '',
                      style: theme.primaryTextTheme.bodyText1,
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (transportMode != TransportMode.bicycle &&
            transportMode != TransportMode.car)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Text(
                  duration ?? '',
                  style: theme.primaryTextTheme.bodyText1,
                ),
                const SizedBox(width: 10),
                Text(
                  distance ?? '',
                  style: theme.primaryTextTheme.bodyText1,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
