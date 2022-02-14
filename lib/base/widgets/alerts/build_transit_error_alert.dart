import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_core/base/widgets/alerts/base_build_alert.dart';
import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/packge_info_platform.dart';

class BuildTransitErrorAlert extends StatelessWidget {
  const BuildTransitErrorAlert({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    final theme = Theme.of(context);
    final actionTextStyle = TextStyle(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    return BaseBuildAlert(
      title: Text(localization.noRouteError),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reportRouteError(localization.localeName);
            },
            child: Text(
              localization.noRouteErrorActionReportMissingRoute,
              style: actionTextStyle,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localization.noRouteErrorActionCancel,
              style: actionTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reportRouteError(String languageCode) async {
    const routeFeedbackUrl = urlsrouteFeedbackUrl;
    String version = await PackageInfoPlatform.version();
    final LatLng? currentLocation = GPSLocationProvider().myLocation;
    launch(
      "$routeFeedbackUrl?lang=$languageCode&geo=${currentLocation?.latitude},"
      "${currentLocation?.longitude}&app=$version",
    );
  }
}
