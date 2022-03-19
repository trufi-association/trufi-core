import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:trufi_core/base/utils/text/outlined_text.dart';
import 'package:url_launcher/url_launcher.dart';

class MapTileAndOSMCopyright extends StatelessWidget {
  const MapTileAndOSMCopyright({Key? key}) : super(key: key);

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
            style: theme.textTheme.caption?.copyWith(
              color: Colors.black,
              shadows: shadows,
            ),
            text: "© OpenMapTiles ",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch("https://openmaptiles.org/");
              },
          ),
          TextSpan(
            style: theme.textTheme.caption?.copyWith(
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
