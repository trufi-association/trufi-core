import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/utils/text/outlined_text.dart';

class RouteNumber extends StatelessWidget {
  final TransportMode? transportMode;
  final bool realTime;
  final Color? textColor;
  final Color? backgroundColor;
  final String text;
  final String? lastStopName;
  final String? agencyName;
  final String? tripHeadSing;
  final String? distance;
  final String? duration;
  final Widget? textContainer;
  final String? mode;

  const RouteNumber({
    super.key,
    this.transportMode,
    this.realTime = false,
    this.textColor,
    this.backgroundColor,
    required this.text,
    this.lastStopName,
    this.agencyName,
    this.tripHeadSing,
    this.distance,
    this.duration,
    this.textContainer,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: getContrastColor(
                            backgroundColor ?? Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (transportMode != TransportMode.bicycle &&
                transportMode != TransportMode.car)
              const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Text(
                '${duration!=null?'$duration, ':  ''}${distance ?? ''}',
                style: TextStyle(
                  fontSize: 15,
                  color: hintTextColor(theme),
                ),
              ),
            ),
            if (lastStopName != null)
              Container(
                padding: const EdgeInsets.only(left: 5,right: 5, top: 5),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "A:",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: lastStopName!,
                        style: TextStyle(
                          fontSize: 15,
                          color: hintTextColor(theme),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            if (agencyName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Operador: ",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: agencyName!,
                        style: TextStyle(
                          fontSize: 15,
                          color: hintTextColor(theme),
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
        // if (realTime) Text("Is Real Time"),
      ],
    );
  }
}
