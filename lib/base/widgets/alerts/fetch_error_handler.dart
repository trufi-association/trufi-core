import 'package:flutter/material.dart';
import 'package:trufi_core/base/widgets/alerts/build_transit_error_alert.dart';

import 'package:trufi_core/base/pages/home/services/exception/fetch_online_exception.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/alerts/error_base_alert.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

Future<dynamic> onFetchError(BuildContext context, dynamic exception) async {
  final localization = TrufiBaseLocalization.of(context);
  switch (exception.runtimeType) {
    case FetchOnlineRequestException:
      return _showErrorAlert(
        context: context,
        error: localization.commonNoInternet,
      );
    case FetchOnlineResponseException:
      return _showErrorAlert(
        context: context,
        error: localization.searchFailLoadingPlan,
      );
    case FetchOnlinePlanException:
      return showTrufiDialog(
        context: context,
        builder: (dialogContext) => const BuildTransitErrorAlert(),
      );
    default:
      return _showErrorAlert(
        context: context,
        error: exception.toString(),
      );
  }
}

Future<void> _showErrorAlert({
  required BuildContext context,
  required String error,
}) {
  return showTrufiDialog(
    context: context,
    builder: (context) {
      return ErrorAlert(
        error: error,
      );
    },
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
