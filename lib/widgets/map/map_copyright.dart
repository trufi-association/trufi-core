import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../trufi_configuration.dart';

class MapCopyright extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cfg = TrufiConfiguration();
    return Container(
      margin: const EdgeInsets.all(10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              style: theme.textTheme.caption.copyWith(
                color: Colors.black,
              ),
              text: "© MapTiler ",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch(cfg.url.mapTilerCopyright);
                },
            ),
            TextSpan(
              style: theme.textTheme.caption.copyWith(
                color: Colors.black,
              ),
              text: "© OpenStreetMap contributors",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch(cfg.url.openStreetMapCopyright);
                },
            ),
          ],
        ),
      ),
    );
  }
}
