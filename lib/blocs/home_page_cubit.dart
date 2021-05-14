import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
import 'package:trufi_core/models/map_route_state.dart';
import 'package:trufi_core/repository/exception/fetch_online_exception.dart';
import 'package:trufi_core/repository/local_repository.dart';
import 'package:trufi_core/services/plan_request/request_manager.dart';
import 'package:trufi_core/trufi_models.dart';

import 'payload_data_plan/payload_data_plan_cubit.dart';

class HomePageCubit extends Cubit<MapRouteState> {
  LocalRepository localRepository;

  final RequestManager requestManager;
  CancelableOperation<PlanEntity> currentFetchPlanOperation;
  CancelableOperation<AdEntity> currentFetchAdOperation;

  HomePageCubit(
    this.localRepository,
    this.requestManager,
  ) : super(const MapRouteState()) {
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
    if (currentFetchPlanOperation != null) {
      await currentFetchPlanOperation.cancel();
    }
  }

  Future<void> updateMapRouteState(MapRouteState newState) async {
    await localRepository.saveStateHomePage(jsonEncode(newState.toJson()));

    emit(newState);
  }

  Future<void> setTappingPlace(LatLng latLng) async {
    if (state.fromPlace == null) {
      await updateMapRouteState(state.copyWith(
          fromPlace: TrufiLocation.fromLatLng("Map Marker", latLng)));
    } else if (state.toPlace == null) {
      await updateMapRouteState(state.copyWith(
          toPlace: TrufiLocation.fromLatLng("Map Marker", latLng)));
    }
  }

  Future<void> setFromPlace(TrufiLocation fromPlace) async {
    await updateMapRouteState(state.copyWith(fromPlace: fromPlace));
  }

  Future<void> swapLocations() async {
    await updateMapRouteState(
      state.copyWith(
        fromPlace: state.toPlace,
        toPlace: state.fromPlace,
      ),
    );
  }

  Future<void> setToPlace(TrufiLocation toPlace) async {
    await updateMapRouteState(state.copyWith(toPlace: toPlace));
  }

  Future<void> configSuccessAnimation({bool show}) async {
    await updateMapRouteState(state.copyWith(showSuccessAnimation: show));
  }

  Future<void> fetchPlan(
    String correlationId, {
    bool car = false,
    PayloadDataPlanState advancedOptions,
  }) async {
    if (state.toPlace != null && state.fromPlace != null) {
      await updateMapRouteState(state.copyWithoutMap(isFetching: true));
      final PlanEntity planEntity = await _fetchPlan(
        correlationId,
        car: car,
        advancedOptions: advancedOptions,
      ).catchError((error) async {
        await updateMapRouteState(state.copyWith(isFetching: false));
        throw error;
      });
      await updateMapRouteState(state.copyWith(
        plan: planEntity,
        isFetching: false,
        showSuccessAnimation: true,
      ));
    }
  }

  Future<PlanEntity> _fetchPlan(
    String correlationId, {
    bool car = false,
    PayloadDataPlanState advancedOptions,
  }) async {
    if (currentFetchPlanOperation != null) {
      await currentFetchPlanOperation.cancel();
    }
    currentFetchPlanOperation = car
        ? CancelableOperation.fromFuture(() async {
            return requestManager.fetchCarPlan(
              state.fromPlace,
              state.toPlace,
              correlationId,
            );
          }())
        : CancelableOperation.fromFuture(
            () async {
              return requestManager.fetchAdvancedPlan(
                  from: state.fromPlace,
                  to: state.toPlace,
                  correlationId: correlationId,
                  advancedOptions: advancedOptions);
            }(),
          );
    final PlanEntity plan = await currentFetchPlanOperation.valueOrCancellation(
      null,
    );
    if (plan != null && !plan.hasError) {
      return plan;
    } else if (plan == null) {
      throw FetchCanceledByUserException("Cancelled by User");
    } else if (plan.hasError) {
      if (car) {
        throw FetchOnlineCarException(plan.error.message);
      } else {
        throw FetchOnlinePlanException(plan.error.message);
      }
    } else {
      // should never happened
      throw Exception("Unknown Error");
    }
  }

// TODO: investigate how works this functions and know why we need it
  Future<void> fetchAd(String correlationId) async {
    try {
      currentFetchAdOperation = CancelableOperation.fromFuture(
        () async {
          return requestManager.fetchAd(
            state.toPlace,
            correlationId,
          );
        }(),
      );
      final AdEntity ad =
          await currentFetchAdOperation.valueOrCancellation(null);
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
