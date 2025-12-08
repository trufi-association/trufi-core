import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper function for outlined text shadows.
List<Shadow> outlinedText({
  Color strokeColor = Colors.black,
  double strokeWidth = 1,
  int precision = 5,
}) {
  List<Shadow> result = [];
  for (int x = 1; x <= precision; x++) {
    for (int y = 1; y <= precision; y++) {
      double offsetX = strokeWidth * x / precision;
      double offsetY = strokeWidth * y / precision;
      result.addAll([
        Shadow(offset: Offset(-offsetX, -offsetY), color: strokeColor),
        Shadow(offset: Offset(-offsetX, offsetY), color: strokeColor),
        Shadow(offset: Offset(offsetX, -offsetY), color: strokeColor),
        Shadow(offset: Offset(offsetX, offsetY), color: strokeColor),
      ]);
    }
  }
  return result;
}

/// Default map copyright widget for OpenMapTiles and OpenStreetMap.
class MapTileAndOSMCopyright extends StatelessWidget {
  const MapTileAndOSMCopyright({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Shadow> shadows = outlinedText(
      strokeColor: Colors.white.withValues(alpha: 0.3),
      precision: 2,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black,
              shadows: shadows,
            ),
            text: "© OpenMapTiles ",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse("https://openmaptiles.org/"));
              },
          ),
          TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black,
              shadows: shadows,
            ),
            text: "© OpenStreetMap contributors",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse("https://www.openstreetmap.org/copyright"));
              },
          ),
        ],
      ),
    );
  }
}
