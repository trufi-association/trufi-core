import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:async/async.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' show TransportMode;

import '../repository/local_repository.dart';
import '../services/fetch_online_exception.dart';
import '../services/request_plan_service.dart';
import 'route_planner_state.dart';

/// Abstract cubit for route planning functionality.
///
/// Generic over location, plan, and itinerary types to allow
/// different implementations. Subclasses must provide concrete
/// repository and request service implementations.
abstract class BaseRoutePlannerCubit<
    TLocation extends ITrufiLocation,
    TPlan extends IPlan,
    TItinerary extends IItinerary> extends Cubit<RoutePlannerState<TLocation, TPlan, TItinerary>> {

  BaseRoutePlannerCubit({
    required MapRouteLocalRepository<TLocation, TPlan, TItinerary> localRepository,
    required RequestPlanService<TLocation, TPlan> requestPlanService,
  })  : _localRepository = localRepository,
        _requestManager = requestPlanService,
        super(const RoutePlannerState()) {
    _load();
  }

  final MapRouteLocalRepository<TLocation, TPlan, TItinerary> _localRepository;
  final RequestPlanService<TLocation, TPlan> _requestManager;
  CancelableOperation<TPlan?>? currentFetchPlanOperation;

  Future<void> _load() async {
    await _localRepository.loadRepository();
    emit(state.copyWith(
      fromPlace: await _localRepository.getFromPlace(),
      toPlace: await _localRepository.getToPlace(),
      plan: await _localRepository.getPlan(),
      selectedItinerary: await _localRepository.getSelectedItinerary(),
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

  Future<void> setPlace(TLocation place) async {
    if (state.fromPlace == null) {
      setFromPlace(place);
    } else if (state.toPlace == null) {
      setToPlace(place);
    }
  }

  Future<void> setFromPlace(TLocation fromPlace) async {
    await updateMapRouteState(state.copyWith(fromPlace: fromPlace));
  }

  Future<void> setToPlace(TLocation toPlace) async {
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

  Future<void> updateMapRouteState(RoutePlannerState<TLocation, TPlan, TItinerary> newState) async {
    await _localRepository.savePlan(newState.plan);
    await _localRepository.saveFromPlace(newState.fromPlace);
    await _localRepository.saveToPlace(newState.toPlace);
    await _localRepository.saveSelectedItinerary(newState.selectedItinerary);
    emit(newState);
  }

  /// Get the selected itinerary from a plan.
  /// Override this if your plan type has a different structure.
  TItinerary? getItineraryFromPlan(TPlan plan, int index);

  /// Check if a plan has an error.
  /// Override this if your plan type has a different error structure.
  bool planHasError(TPlan plan);

  /// Get error info from plan if there's an error.
  /// Returns (errorId, errorMessage) or null if no error.
  (int, String)? getPlanError(TPlan plan);

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
              from: state.fromPlace as TLocation,
              to: state.toPlace as TLocation,
              transportModes: [TransportMode.transit, TransportMode.walk],
            );
          }(),
        );
        TPlan? plan = await currentFetchPlanOperation?.valueOrCancellation();
        if (plan != null) {
          final error = getPlanError(plan);
          if (error != null) {
            throw FetchOnlinePlanException(error.$1, error.$2);
          }
          final numItineraryValue = numItinerary ?? 0;
          final itineraryCount = plan.itineraries?.length ?? 0;
          final selectedIndex = numItineraryValue < itineraryCount ? numItineraryValue : 0;
          await updateMapRouteState(state.copyWith(
            plan: plan,
            selectedItinerary: getItineraryFromPlan(plan, selectedIndex),
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

  Future<void> selectItinerary(TItinerary selectedItinerary) async {
    await updateMapRouteState(
        state.copyWith(selectedItinerary: selectedItinerary));
  }
}
