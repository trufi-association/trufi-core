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
    return SizedBox(
      width: 250,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: transportMode == TransportMode.bicycle
                  ? Colors.transparent
                  : (backgroundColor ?? Colors.black),
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
                else if (transportMode == TransportMode.bicycle)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: transportMode.getImage(color: transportMode.color),
                  ),
                if (transportMode != TransportMode.bicycle)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      text,
                      style: theme.primaryTextTheme.headline6.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              transportMode != TransportMode.bicycle
                  ? (tripHeadSing ?? '')
                  : 'Rad fahren',
              style: theme.primaryTextTheme.bodyText1
                  .copyWith(fontSize: 13, color: Colors.grey[700]),
              overflow: TextOverflow.visible,
            ),
          ),
          Text(
            ' - ${duration ?? ''}, ${distance ?? ''}',
            style: theme.primaryTextTheme.bodyText1
                .copyWith(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
