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
        builder: (dialogContext) =>
            BuildTransitErrorAlert(exception: exception),
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
