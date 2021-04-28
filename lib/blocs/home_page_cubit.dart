import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:package_info/package_info.dart';
import 'package:trufi_core/blocs/app_review_cubit.dart';
import 'package:trufi_core/blocs/request_manager_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/repository/request_manager.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:trufi_core/widgets/alerts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageCubit extends Cubit<MapRouteState> {
  LocalRepository localRepository;
  RequestManager requestManager;

  CancelableOperation<Plan> currentFetchPlanOperation;
  CancelableOperation<Ad> currentFetchAdOperation;

  HomePageCubit(this.localRepository) : super(const MapRouteState()) {
    _load();
  }

  Future<void> _load() async {
    final jsonString = await localRepository.getStateHomePage();

    if (jsonString != null && jsonString.isNotEmpty) {
      emit(
        MapRouteState.fromJson(jsonDecode(jsonString) as Map<String, dynamic>),
      );
    }
  }

  Future<void> reset() async {
    emit(const MapRouteState());
    await localRepository.deleteStateHomePage();
  }

  Future<void> updateMapRouteState(MapRouteState newState) async {
    await localRepository.saveStateHomePage(jsonEncode(newState.toJson()));

    emit(newState);
  }

  Future<void> setFromPlace(TrufiLocation fromPlace) async {
    await updateMapRouteState(state.copyWith(fromPlace: fromPlace));
  }

  Future<void> setPlan(Plan plan) async {
    await updateMapRouteState(state.copyWith(
      plan: plan,
      isFetching: false,
      showSuccessAnimation: true,
    ));
  }

  Future<void> swapLocations() async {
    await updateMapRouteState(
      state.copyWith(
        fromPlace: state.toPlace,
        toPlace: state.fromPlace,
        isFetching: true,
      ),
    );
  }

  Future<void> setToPlace(TrufiLocation toPlace) async {
    await updateMapRouteState(
        state.copyWith(toPlace: toPlace, isFetching: true));
  }

  Future<void> configSuccessAnimation({bool show}) async {
    await updateMapRouteState(state.copyWith(showSuccessAnimation: show));
  }

  Future<void> updateCurrentRoute(
      TrufiLocation fromLocation, TrufiLocation toLocation) async {
    await updateMapRouteState(
      MapRouteState(
        fromPlace: fromLocation,
        toPlace: toLocation,
        showSuccessAnimation: state.showSuccessAnimation,
        isFetching: state.isFetching,
        ad: state.ad,
      ),
    );
  }

  // TODO: find a better place and optimize
  // TODO: Extract the Context out of this function
  // TODO: remove everything that is related to Alerts / UI
  Future<void> fetchPlan(
      BuildContext context,
      RequestManagerCubit requestManagerCubit,
      AppReviewCubit appReviewCubit,
      TrufiLocalization localization,
      LatLng currentLocation,
      {bool car = false}) async {
    // Cancel the last fetch plan operation for replace with the current request
    if (currentFetchPlanOperation != null) {
      await currentFetchPlanOperation.cancel();
    }
    if (state.toPlace != null && state.fromPlace != null) {
      // Refresh your location
      final yourLocation = localization.searchItemYourLocation;

      final refreshFromPlace = state.fromPlace.description == yourLocation;
      final refreshToPlace = state.toPlace.description == yourLocation;
      if (refreshFromPlace || refreshToPlace) {
        if (currentLocation != null) {
          if (refreshFromPlace) {
            setFromPlace(
                TrufiLocation.fromLatLng(yourLocation, currentLocation));
          }
          if (refreshToPlace) {
            setToPlace(TrufiLocation.fromLatLng(yourLocation, currentLocation));
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => buildAlertLocationServicesDenied(context),
          );
        }
      }
      try {
        currentFetchPlanOperation = car
            ? requestManagerCubit.fetchCarPlan(
                context,
                state.fromPlace,
                state.toPlace,
              )
            : requestManagerCubit.fetchTransitPlan(
                context,
                state.fromPlace,
                state.toPlace,
              );

        final Plan plan =
            await currentFetchPlanOperation.valueOrCancellation(null);

        if (plan == null) {
          throw "Canceled by user";
        } else if (plan.hasError) {
          updateMapRouteState(state.copyWith(isFetching: false));
          if (car) {
            showDialog(
              context: context,
              builder: (context) {
                return buildErrorAlert(
                    context: context, error: plan.error.message);
              },
            );
          } else {
            final cfg = TrufiConfiguration();
            final languageCode = Localizations.localeOf(context).languageCode;
            final packageInfo = await PackageInfo.fromPlatform();
            showDialog(
              context: context,
              builder: (context) {
                return buildTransitErrorAlert(
                  context: context,
                  error: plan.error.message,
                  onReportMissingRoute: () {
                    launch(
                      "${cfg.url.routeFeedback}?lang=$languageCode&geo=${currentLocation?.latitude},"
                      "${currentLocation?.longitude}&app=${packageInfo.version}",
                    );
                  },
                  onShowCarRoute: () {
                    // _fetchPlan(context.read<HomePageCubit>(), car: true);
                  },
                );
              },
            );
          }
        } else {
          appReviewCubit.incrementReviewWorthyActions();
          setPlan(plan);
        }
      } on FetchOfflineRequestException catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(
            context,
            "Offline mode is not implemented yet.",
            false,
            localization.commonError);
      } on FetchOfflineResponseException catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(
            context,
            "Offline mode is not implemented yet.",
            false,
            localization.commonError);
      } on FetchOnlineRequestException catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(context, localization.commonNoInternet,
            true, localization.commonError);
      } on FetchOnlineResponseException catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showOnAndOfflineErrorAlert(context, localization.searchFailLoadingPlan,
            true, localization.commonError);
      } catch (e) {
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch plan: $e");
        _showErrorAlert(context, e.toString());
      }

      try {
        currentFetchAdOperation =
            requestManagerCubit.fetchAd(context, state.toPlace);

        final Ad ad = await currentFetchAdOperation.valueOrCancellation(null);
        await updateMapRouteState(
          state.copyWith(ad: ad),
        );
      } catch (e, stacktrace) {
        await updateMapRouteState(
          MapRouteState(
              fromPlace: state.fromPlace,
              toPlace: state.toPlace,
              isFetching: state.isFetching,
              showSuccessAnimation: state.showSuccessAnimation,
              plan: state.plan),
        );
        // TODO: Replace by proper error handling
        // ignore: avoid_print
        print("Failed to fetch ad: $e");
        // ignore: avoid_print
        print(stacktrace);
      }
    }
  }

  void _showOnAndOfflineErrorAlert(BuildContext context, String message,
      bool online, String commonErrorMessage) {
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
}
