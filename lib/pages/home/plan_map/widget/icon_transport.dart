import 'package:flutter/material.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';

class IconTransport extends StatelessWidget {
  final TransportMode transportMode;
  final Color color;
  final String text;
  final String distance;
  final String duration;
  final Widget icon;

  const IconTransport({
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
    return Container(
      decoration: BoxDecoration(
        color: color ?? transportMode.backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
        child: Row(
          children: [
            if (icon != null)
              SizedBox(
                height: 22,
                width: 22,
                child: ClipRRect(child: icon),
              )
            else if (transportMode?.getImage() != null)
              SizedBox(
                height: 22,
                width: 22,
                child: ClipRRect(child: transportMode.getImage(color: color)),
              )
            else
              ClipRRect(child: Icon(transportMode.icon, color: Colors.white)),
            if (transportMode != TransportMode.walk)
              Flexible(
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
    );
  }
}
