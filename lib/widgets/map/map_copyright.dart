import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/utils/text/outlined_text.dart';
import 'package:url_launcher/url_launcher.dart';

class MapTileAndOSMCopyright extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Shadow> shadows = outlinedText(
      strokeColor: Colors.white.withOpacity(.3),
      precision: 2,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            style: theme.textTheme.caption.copyWith(
              color: Colors.black,
              shadows: shadows,
            ),
            text: "© MapTiler ",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch("https://www.maptiler.com/copyright/");
              },
          ),
          TextSpan(
            style: theme.textTheme.caption.copyWith(
              color: Colors.black,
              shadows: shadows,
            ),
            text: "© OpenStreetMap contributors",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch("https://www.openstreetmap.org/copyright");
              },
          ),
        ],
      ),
    );
  }
}
