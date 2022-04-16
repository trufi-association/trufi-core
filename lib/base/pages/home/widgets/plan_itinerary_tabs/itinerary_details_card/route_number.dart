import 'package:flutter/material.dart';

import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';

class RouteNumber extends StatelessWidget {
  final TransportMode? transportMode;
  final Color? backgroundColor;
  final String text;
  final String? tripHeadSing;
  final String? distance;
  final String? duration;
  final Widget? textContainer;
  final String? mode;

  const RouteNumber({
    Key? key,
    this.transportMode,
    this.backgroundColor,
    required this.text,
    this.tripHeadSing,
    this.distance,
    this.duration,
    this.textContainer,
    this.mode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (transportMode != TransportMode.bicycle &&
            transportMode != TransportMode.car)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (transportMode != TransportMode.bicycle &&
            transportMode != TransportMode.car)
          const SizedBox(width: 5),
        Text(
          '${duration ?? ''}, ${distance ?? ''}',
          style: TextStyle(
            fontSize: 15,
            color: hintTextColor(theme),
          ),
        ),
      ],
    );
  }
}
