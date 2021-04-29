import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/location_provider_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';
import 'package:latlong/latlong.dart';
import 'alerts.dart';

void onFetchError(BuildContext context, dynamic exception) {
  final TrufiLocalization localization = TrufiLocalization.of(context);
  switch (exception.runtimeType) {
    case FetchOfflineRequestException:
      _showOnAndOfflineErrorAlert(
        context,
        "Offline mode is not implemented yet.",
        false,
        localization.commonError,
      );
      break;
    case FetchOfflineResponseException:
      _showOnAndOfflineErrorAlert(
        context,
        "Offline mode is not implemented yet.",
        false,
        localization.commonError,
      );
      break;
    case FetchOnlineRequestException:
      _showOnAndOfflineErrorAlert(
        context,
        localization.commonNoInternet,
        true,
        localization.commonError,
      );
      break;
    case FetchOnlineResponseException:
      _showOnAndOfflineErrorAlert(
        context,
        localization.searchFailLoadingPlan,
        true,
        localization.commonError,
      );
      break;
    case FetchOnlinePlanException:
      final cfg = TrufiConfiguration();
      final languageCode = Localizations.localeOf(context).languageCode;
      PackageInfo.fromPlatform().then((packageInfo) => {
            showDialog(
              context: context,
              builder: (context) {
                return buildTransitErrorAlert(
                  context: context,
                  error: exception.toString(),
                  onReportMissingRoute: () async {
                    final LatLng currentLocation = await context
                        .read<LocationProviderCubit>()
                        .getCurrentLocation()
                        .catchError((error) => null);
                    launch(
                      "${cfg.url.routeFeedback}?lang=$languageCode&geo=${currentLocation?.latitude},"
                      "${currentLocation?.longitude}&app=${packageInfo.version}",
                    );
                  },
                  onShowCarRoute: () {
                    // TODO: improve onShowCarRoute action
                    final homePageCubit = context.read<HomePageCubit>();
                    final appReviewCubit = context.read<AppReviewCubit>();
                    homePageCubit.updateMapRouteState(
                      homePageCubit.state.copyWith(isFetching: true),
                    );
                    final correlationId =
                        context.read<PreferencesCubit>().state.correlationId;
                    homePageCubit
                        .fetchPlan(correlationId, car: true)
                        .then((value) =>
                            appReviewCubit.incrementReviewWorthyActions())
                        .catchError((error) => onFetchError(context, error));
                  },
                );
              },
            )
          });
      break;

    default:
      _showErrorAlert(context, exception.toString());
  }
}

void _showOnAndOfflineErrorAlert(
  BuildContext context,
  String message,
  bool online,
  String commonErrorMessage,
) {
  showDialog(
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

void _showErrorAlert(BuildContext context, String error) {
  showDialog(
    context: context,
    builder: (context) {
      return buildErrorAlert(context: context, error: error);
    },
  );
}
