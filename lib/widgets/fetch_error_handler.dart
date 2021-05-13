import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/gps_location/location_provider_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/preferences/preferences_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:url_launcher/url_launcher.dart';

import 'alerts.dart';

Future<void> onFetchError(BuildContext context, Exception exception) async {
  final TrufiLocalization localization = TrufiLocalization.of(context);
  switch (exception.runtimeType) {
    case FetchOfflineRequestException:
      return _showOnAndOfflineErrorAlert(
        context,
        "Offline mode is not implemented yet.",
        false,
        localization.commonError,
      );
      break;
    case FetchOfflineResponseException:
      return _showOnAndOfflineErrorAlert(
        context,
        "Offline mode is not implemented yet.",
        false,
        localization.commonError,
      );
      break;
    case FetchOnlineRequestException:
      return _showOnAndOfflineErrorAlert(
        context,
        localization.commonNoInternet,
        true,
        localization.commonError,
      );
      break;
    case FetchOnlineResponseException:
      return _showOnAndOfflineErrorAlert(
        context,
        localization.searchFailLoadingPlan,
        true,
        localization.commonError,
      );
      break;
    case FetchOnlinePlanException:
      final languageCode = Localizations.localeOf(context).languageCode;
      final packageInfo = await PackageInfo.fromPlatform();
      final routeFeedbackUrl =
          context.read<ConfigurationCubit>().state.urls.routeFeedbackUrl;
      return showDialog(
        context: context,
        builder: (dialogContext) {
          return buildTransitErrorAlert(
            context: dialogContext,
            error: exception.toString(),
            onReportMissingRoute: () async {
              final LatLng currentLocation = dialogContext
                  .read<LocationProviderCubit>()
                  .state
                  .currentLocation;
              launch(
                "$routeFeedbackUrl?lang=$languageCode&geo=${currentLocation?.latitude},"
                "${currentLocation?.longitude}&app=${packageInfo.version}",
              );
            },
            onShowCarRoute: () {
              // TODO: improve onShowCarRoute action
              final homePageCubit = dialogContext.read<HomePageCubit>();
              final appReviewCubit = dialogContext.read<AppReviewCubit>();
              homePageCubit.updateMapRouteState(
                homePageCubit.state.copyWith(isFetching: true),
              );
              final correlationId =
                  dialogContext.read<PreferencesCubit>().state.correlationId;
              homePageCubit
                  .fetchPlan(correlationId, car: true)
                  .then(
                      (value) => appReviewCubit.incrementReviewWorthyActions())
                  .catchError(
                    (error) => onFetchError(context, error as Exception),
                  );
            },
          );
        },
      );
      break;

    default:
      return _showErrorAlert(context, exception.toString());
  }
}

Future<void> _showOnAndOfflineErrorAlert(
  BuildContext context,
  String message,
  bool online,
  String commonErrorMessage,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return buildOnAndOfflineErrorAlert(
        context: context,
        online: online,
        title: Text(commonErrorMessage),
        content: Text(message),
      );
    },
  );
}

Future<void> _showErrorAlert(BuildContext context, String error) {
  return showDialog(
    context: context,
    builder: (context) {
      return buildErrorAlert(context: context, error: error);
    },
  );
}
