import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:trufi_core/base/pages/transport_list/services/models.dart';

class ShareRouteButton extends StatelessWidget {
  final PatternOtp transportData;
  final Uri shareBaseRouteUri;

  const ShareRouteButton({
    Key? key,
    required this.transportData,
    required this.shareBaseRouteUri,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        Share.share(shareBaseRouteUri.replace(
          queryParameters: {
            "id": transportData.code,
          },
        ).toString());
      },
      heroTag: null,
      child: const Icon(
        Icons.share,
      ),
    );
  }
}
