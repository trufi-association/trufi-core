import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:async/async.dart';
import 'package:equatable/equatable.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/repository/hive_local_repository.dart';
import 'package:trufi_core/base/pages/home/repository/local_repository.dart';
import 'package:trufi_core/base/pages/home/services/exception/fetch_online_exception.dart';
import 'package:trufi_core/base/pages/home/services/online_request_plan/rest_request_plan.dart';
import 'package:trufi_core/base/pages/home/services/request_plan_service.dart';

part 'route_planner_state.dart';

class RoutePlannerCubit extends Cubit<RoutePlannerState> {
  final MapRouteLocalRepository _localRepository =
      MapRouteHiveLocalRepository();

  final RequestPlanService _requestManager;

  CancelableOperation<Plan?>? currentFetchPlanOperation;

  RoutePlannerCubit(String otpEndpoint,
      {RequestPlanService? customRequestPlanService})
      : _requestManager = customRequestPlanService ??
            RestRequestPlanService(otpEndpoint: otpEndpoint),
        super(const RoutePlannerState()) {
    _load();
  }

  Future<void> _load() async {
    await _localRepository.loadRepository();
    emit(state.copyWith(
      fromPlace: await _localRepository.getFromPlace(),
      toPlace: await _localRepository.getToPlace(),
      plan: await _localRepository.getPlan(),
      selectedItinerary: await _localRepository.getSelectedItinerary(),
      selectedDateTime: await _localRepository.getDateTime(),
      enableDebugOutput: await _localRepository.getEnableDebugOutput(),
    ));
  }

  Future<void> reset() async {
    await updateMapRouteState(const RoutePlannerState());
  }

  Future<void> swapLocations() async {
    await updateMapRouteState(
      state.copyWith(
        fromPlace: state.toPlace,
        toPlace: state.fromPlace,
      ),
    );
  }

  Future<void> setPlace(TrufiLocation place) async {
    if (state.fromPlace == null) {
      setFromPlace(place);
    } else if (state.toPlace == null) {
      setToPlace(place);
    }
  }

  Future<void> setFromPlace(TrufiLocation fromPlace) async {
    await updateMapRouteState(state.copyWith(fromPlace: fromPlace));
  }

  Future<void> setToPlace(TrufiLocation toPlace) async {
    await updateMapRouteState(state.copyWith(toPlace: toPlace));
  }

  Future<void> resetFromPlace() async {
    await updateMapRouteState(
        state.copyWithNullable(fromPlace: const Optional.value(null)));
  }

  Future<void> resetToPlace() async {
    await updateMapRouteState(
        state.copyWithNullable(toPlace: const Optional.value(null)));
  }

  Future<void> updateMapRouteState(RoutePlannerState newState) async {
    await _localRepository.savePlan(newState.plan);
    await _localRepository.saveFromPlace(newState.fromPlace);
    await _localRepository.saveToPlace(newState.toPlace);
    await _localRepository.saveSelectedItinerary(newState.selectedItinerary);
    await _localRepository.saveDateTime(newState.selectedDateTime);
    await _localRepository.saveEnableDebugOutput(newState.enableDebugOutput);
    emit(newState);
  }

  Future<void> fetchPlan({int? numItinerary}) async {
    if (state.toPlace != null && state.fromPlace != null) {
      await updateMapRouteState(state.copyWithNullable(
        plan: const Optional.value(null),
        selectedItinerary: const Optional.value(null),
      ));
      await cancelCurrentFetchIfExist();
      try {
        currentFetchPlanOperation = CancelableOperation.fromFuture(
          () {
            return _requestManager.fetchAdvancedPlan(
              from: state.fromPlace!,
              to: state.toPlace!,
              transportModes: [TransportMode.transit, TransportMode.walk],
              enableDebugOutput: state.enableDebugOutput,
            );
          }(),
        );
        Plan? plan = await currentFetchPlanOperation?.valueOrCancellation();
        if (plan != null) {
          if (plan.error != null) {
            throw FetchOnlinePlanException(plan.error!.id, plan.error!.message);
          }
          final numItineraryValue = numItinerary ?? 0;
          await updateMapRouteState(state.copyWith(
            plan: plan,
            selectedItinerary: plan.itineraries![
                numItineraryValue < plan.itineraries!.length
                    ? numItineraryValue
                    : 0],
          ));
        } else {
          throw FetchCancelPlanException();
        }
      } catch (e) {
        if (e.runtimeType != FetchCancelPlanException) rethrow;
      }
    }
  }

  Future<void> cancelCurrentFetchIfExist() async {
    await currentFetchPlanOperation?.cancel();
    currentFetchPlanOperation = null;
  }

  Future<void> selectItinerary(Itinerary selectedItinerary) async {
    await updateMapRouteState(
        state.copyWith(selectedItinerary: selectedItinerary));
  }

  Future<void> setDataDate({
    DateTime? date,
    bool? arriveBy,
  }) async {
    await updateMapRouteState(state.copyWithNullable(
      selectedDateTime: Optional.value(date),
    ));
  }

  Future<void> activeDebugOutput(bool? value) async {
    await updateMapRouteState(state.copyWith(
      enableDebugOutput: value ?? false,
    ));
  }
}
