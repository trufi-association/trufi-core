import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import '../models/route_planner_state.dart';
import '../repository/home_screen_repository.dart';
import '../repository/home_screen_repository_impl.dart';
import '../services/request_plan_service.dart';

/// Error key emitted when no routes are found (UI resolves to localized string).
const String noRoutesErrorKey = 'no_routes_found';

/// Cubit for managing route planning state.
///
/// If [repository] is not provided, uses [HomeScreenRepositoryImpl] by default.
class RoutePlannerCubit extends Cubit<RoutePlannerState> {
  final HomeScreenRepository _repository;
  final RequestPlanService _requestService;

  CancelableOperation<routing.Plan>? _currentFetchOperation;

  RoutePlannerCubit({
    HomeScreenRepository? repository,
    required RequestPlanService requestService,
  }) : _repository = repository ?? HomeScreenRepositoryImpl(),
       _requestService = requestService,
       super(const RoutePlannerState());

  /// Initialize and load saved state.
  Future<void> initialize() async {
    await _repository.initialize();

    final fromPlace = await _repository.getFromPlace();
    final toPlace = await _repository.getToPlace();
    final plan = await _repository.getPlan();
    final selectedItinerary = await _repository.getSelectedItinerary();

    emit(
      state.copyWith(
        fromPlace: fromPlace,
        toPlace: toPlace,
        plan: plan,
        selectedItinerary: selectedItinerary,
      ),
    );
  }

  /// Set the origin location.
  Future<void> setFromPlace(TrufiLocation fromPlace) async {
    await _repository.saveFromPlace(fromPlace);
    emit(state.copyWith(fromPlace: fromPlace));
  }

  /// Set the destination location.
  Future<void> setToPlace(TrufiLocation toPlace) async {
    await _repository.saveToPlace(toPlace);
    emit(state.copyWith(toPlace: toPlace));
  }

  /// Reset the origin location.
  Future<void> resetFromPlace() async {
    await _repository.saveFromPlace(null);
    emit(state.copyWithNullable(fromPlace: const Optional(null)));
  }

  /// Reset the destination location.
  Future<void> resetToPlace() async {
    await _repository.saveToPlace(null);
    emit(state.copyWithNullable(toPlace: const Optional(null)));
  }

  /// Clear the current plan and selected itinerary.
  Future<void> clearPlan() async {
    await _cancelCurrentFetch();
    await _repository.savePlan(null);
    await _repository.saveSelectedItinerary(null);
    emit(
      state.copyWithNullable(
        plan: const Optional(null),
        selectedItinerary: const Optional(null),
        error: const Optional(null),
      ),
    );
  }

  /// Swap origin and destination.
  Future<void> swapLocations() async {
    final newFromPlace = state.toPlace;
    final newToPlace = state.fromPlace;

    await _repository.saveFromPlace(newFromPlace);
    await _repository.saveToPlace(newToPlace);

    emit(state.copyWith(fromPlace: newFromPlace, toPlace: newToPlace));
  }

  /// Reset all state.
  Future<void> reset() async {
    await _cancelCurrentFetch();
    await _repository.clear();
    emit(const RoutePlannerState());
  }

  /// Set the time mode (leave now, depart at, arrive by).
  void setTimeMode(TimeMode mode) {
    emit(state.copyWith(timeMode: mode));
  }

  /// Set the departure/arrival date and time.
  void setDateTime(DateTime? dateTime) {
    emit(state.copyWithNullable(dateTime: Optional(dateTime)));
  }

  /// Fetch route plan.
  Future<void> fetchPlan({int? selectedItineraryIndex}) async {
    if (state.fromPlace == null || state.toPlace == null) return;

    await _cancelCurrentFetch();

    emit(
      state.copyWithNullable(
        isLoading: true,
        plan: const Optional(null),
        selectedItinerary: const Optional(null),
        error: const Optional(null),
      ),
    );

    // Compute dateTime and arriveBy from time settings
    final DateTime effectiveDateTime;
    final bool arriveBy;

    switch (state.timeMode) {
      case TimeMode.leaveNow:
        effectiveDateTime = DateTime.now();
        arriveBy = false;
      case TimeMode.departAt:
        effectiveDateTime = state.dateTime ?? DateTime.now();
        arriveBy = false;
      case TimeMode.arriveBy:
        effectiveDateTime = state.dateTime ?? DateTime.now();
        arriveBy = true;
    }

    try {
      _currentFetchOperation = CancelableOperation.fromFuture(
        _requestService.fetchPlan(
          from: state.fromPlace!,
          to: state.toPlace!,
          dateTime: effectiveDateTime,
          arriveBy: arriveBy,
        ),
      );

      final plan = await _currentFetchOperation?.valueOrCancellation();

      if (plan == null) {
        // Operation was cancelled
        return;
      }

      if (!plan.hasItineraries) {
        emit(state.copyWith(isLoading: false, error: noRoutesErrorKey));
        return;
      }

      final index = selectedItineraryIndex ?? 0;
      final selectedItinerary =
          plan.itineraries![index < plan.itineraries!.length ? index : 0];

      await _repository.savePlan(plan);
      await _repository.saveSelectedItinerary(selectedItinerary);

      emit(
        state.copyWith(
          plan: plan,
          selectedItinerary: selectedItinerary,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Select an itinerary from the plan.
  Future<void> selectItinerary(routing.Itinerary itinerary) async {
    await _repository.saveSelectedItinerary(itinerary);
    emit(state.copyWith(selectedItinerary: itinerary));
  }

  Future<void> _cancelCurrentFetch() async {
    await _currentFetchOperation?.cancel();
    _currentFetchOperation = null;
  }

  @override
  Future<void> close() async {
    await _cancelCurrentFetch();
    return super.close();
  }
}
