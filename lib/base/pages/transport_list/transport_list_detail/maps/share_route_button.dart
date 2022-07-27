import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:trufi_core/base/pages/transport_list/services/models.dart';

class ShareRouteButton extends StatelessWidget {
  final PatternOtp transportData;
  const ShareRouteButton({
    Key? key,
    required this.transportData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        Share.share(Uri(
          scheme: "https",
          host: "cbba.trufi.dev",
          path: "/app/TransportList",
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
