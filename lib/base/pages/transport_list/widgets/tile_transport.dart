import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/utils/text/outlined_text.dart';

class TileTransport extends StatelessWidget {
  final TransitRoute patternOtp;
  final GestureTapCallback onTap;

  const TileTransport({
    super.key,
    required this.patternOtp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: patternOtp.route?.backgroundColor,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(5)),
                        ),
                        // A long route_short_name (the Arequipa feed carries
                        // the operator's sub-brand, up to 32 characters) used
                        // to push the terminal out of the row. The code now
                        // yields only what the terminal needs (the terminal
                        // never takes more than 45 % of the row) and keeps at
                        // least 55 %; both texts end in an ellipsis
                        // (trufi-arequipa#27).
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final textStyle = TextStyle(
                              color: getContrastColor(
                                patternOtp.route?.backgroundColor ??
                                    Colors.white,
                              ),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            );
                            final code = patternOtp.route?.shortName ?? '';
                            final terminal =
                                patternOtp.route?.longNameLast ?? '';
                            final width = constraints.maxWidth;
                            // Measure with the style the Text will render
                            // with (the theme's default merged in: Material 3
                            // adds letterSpacing) and the real scale factor.
                            final renderStyle = DefaultTextStyle.of(context)
                                .style
                                .merge(textStyle);
                            final scale =
                                MediaQuery.of(context).textScaler.scale(16) /
                                    16;
                            final terminalWidth = math.min(
                              calculateTextWidth(terminal, renderStyle) * scale,
                              width * 0.45,
                            );
                            final codeMax = math.max(
                              width * 0.55,
                              width - 8 - terminalWidth,
                            );
                            return Row(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: codeMax,
                                  ),
                                  child: Text(
                                    code,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    terminal,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyle,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: theme.appBarTheme.backgroundColor,
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(5)),
                      ),
                      child: patternOtp.route!.mode?.getImage(
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(5),
                      top: Radius.circular(0),
                    ),
                  ),
                  alignment: FractionalOffset.centerLeft,
                  child: Text(
                    patternOtp.route?.longName ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
            width: 30,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
