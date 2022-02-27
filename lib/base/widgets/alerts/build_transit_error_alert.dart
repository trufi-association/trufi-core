import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/base/pages/home/services/exception/fetch_online_exception.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_core/base/widgets/alerts/base_build_alert.dart';
import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/utils/packge_info_platform.dart';

class BuildTransitErrorAlert extends StatelessWidget {
  final FetchOnlinePlanException exception;
  const BuildTransitErrorAlert({
    Key? key,
    required this.exception,
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.noRouteError),
          const SizedBox(height: 15),
          Text(
            localizedErrorForPlanError(
              exception.code,
              exception.message,
              localization,
            ),
            style: theme.textTheme.bodyText2,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 10),
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

  String localizedErrorForPlanError(
    int errorId,
    String message,
    TrufiBaseLocalization localization,
  ) {
    if (errorId == 500 || errorId == 503) {
      return localization.errorServerUnavailable;
    } else if (errorId == 400) {
      return localization.errorOutOfBoundary;
    } else if (errorId == 404) {
      return localization.errorPathNotFound;
    } else if (errorId == 406) {
      return localization.errorNoTransitTimes;
    } else if (errorId == 408) {
      return localization.errorServerTimeout;
    } else if (errorId == 409) {
      return localization.errorTrivialDistance;
    } else if (errorId == 413) {
      return localization.errorServerCanNotHandleRequest;
    } else if (errorId == 440) {
      return localization.errorUnknownOrigin;
    } else if (errorId == 450) {
      return localization.errorUnknownDestination;
    } else if (errorId == 460) {
      return localization.errorUnknownOriginDestination;
    } else if (errorId == 470) {
      return localization.errorNoBarrierFree;
    } else if (errorId == 340) {
      return localization.errorAmbiguousOrigin;
    } else if (errorId == 350) {
      return localization.errorAmbiguousDestination;
    } else if (errorId == 360) {
      return localization.errorAmbiguousOriginDestination;
    }
    return message;
  }
}
