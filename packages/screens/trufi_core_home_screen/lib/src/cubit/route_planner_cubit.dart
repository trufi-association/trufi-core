import 'package:async/async.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import '../models/route_planner_state.dart';
import '../repository/home_screen_repository.dart';
import '../repository/home_screen_repository_impl.dart';
import '../services/request_plan_service.dart';

/// Error key emitted when no routes are found (UI resolves to localized string).
const String noRoutesErrorKey = 'no_routes_found';

/// Error key emitted when origin and destination are within
/// [minPlanningDistanceMeters] of each other.
const String tooCloseErrorKey = 'origin_destination_too_close';

/// Below this distance (meters), planning is short-circuited and the user is
/// shown a "too close" message instead of a degenerate routing-engine result.
const double minPlanningDistanceMeters = 100;

/// Cubit for managing route planning state.
///
/// If [repository] is not provided, uses [HomeScreenRepositoryImpl] by default.
class RoutePlannerCubit extends Cubit<RoutePlannerState> {
  final HomeScreenRepository _repository;
  final RequestPlanService _requestService;

  /// Optional fixed time-of-day used in place of `DateTime.now()` for
  /// routing requests. Threaded down from `AppConfiguration` (see
  /// `routingTimeOverride`). When non-null, every plan request is
  /// resolved against today at this time.
  final TimeOfDay? _routingTimeOverride;

  /// Optional GTFS-backed lookup used to enrich [routing.Leg.serviceHours]
  /// after the provider has parsed a plan. OTP REST/GraphQL doesn't
  /// expose calendar+frequencies in a directly usable shape, so this
  /// side-channel lets OTP-backed legs show the same operating-hours
  /// indicator as the local Trufi planner.
  final routing.ServiceHoursLookup? _serviceHoursLookup;

  CancelableOperation<routing.Plan>? _currentFetchOperation;

  RoutePlannerCubit({
    HomeScreenRepository? repository,
    required RequestPlanService requestService,
    TimeOfDay? routingTimeOverride,
    routing.ServiceHoursLookup? serviceHoursLookup,
  }) : _repository = repository ?? HomeScreenRepositoryImpl(),
       _requestService = requestService,
       _routingTimeOverride = routingTimeOverride,
       _serviceHoursLookup = serviceHoursLookup,
       super(const RoutePlannerState());

  /// Returns [plan] with each transit leg's `serviceHours` populated
  /// when the lookup has a record for the leg's route id. Legs that
  /// already have `serviceHours` (e.g. produced by the local Trufi
  /// planner) are left untouched.
  routing.Plan _enrichServiceHours(routing.Plan plan) {
    final lookup = _serviceHoursLookup;
    if (lookup == null) return plan;
    final itineraries = plan.itineraries;
    if (itineraries == null) return plan;
    return plan.copyWith(
      itineraries: itineraries.map((it) {
        final newLegs = it.legs.map((leg) {
          if (leg.serviceHours != null) return leg;
          final routeId = leg.route?.gtfsId;
          if (routeId == null || routeId.isEmpty) return leg;
          final sh = lookup.serviceHoursForRouteId(routeId);
          return sh != null ? leg.copyWith(serviceHours: sh) : leg;
        }).toList();
        return it.copyWith(legs: newLegs);
      }).toList(),
    );
  }

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

    if (state.fromPlace!.latLng.distanceTo(state.toPlace!.latLng) <
        minPlanningDistanceMeters) {
      await _cancelCurrentFetch();
      emit(
        state.copyWithNullable(
          isLoading: false,
          plan: const Optional(null),
          selectedItinerary: const Optional(null),
          error: Optional(tooCloseErrorKey),
        ),
      );
      return;
    }

    await _cancelCurrentFetch();

    emit(
      state.copyWithNullable(
        isLoading: true,
        plan: const Optional(null),
        selectedItinerary: const Optional(null),
        error: const Optional(null),
      ),
    );

    // Compute dateTime and arriveBy from time settings.
    //
    // Two modes:
    //
    // - `routingTimeOverride` set → resolve every request against
    //   today @ override-time, ignoring `state.timeMode/dateTime`.
    //   The picker UI is hidden in this mode, so the user can't
    //   even reach the other branch.
    //
    // - Override not set → honour the user's choice from the
    //   departure-time chip: `leaveNow` uses `DateTime.now()`,
    //   `departAt`/`arriveBy` use the time the user picked
    //   (`state.dateTime`), with `arriveBy` flipping the flag.
    final DateTime now = DateTime.now();
    final DateTime effectiveDateTime;
    final bool arriveBy;

    final override = _routingTimeOverride;
    if (override != null) {
      effectiveDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        override.hour,
        override.minute,
      );
      arriveBy = false;
    } else {
      switch (state.timeMode) {
        case TimeMode.leaveNow:
          effectiveDateTime = now;
          arriveBy = false;
        case TimeMode.departAt:
          effectiveDateTime = state.dateTime ?? now;
          arriveBy = false;
        case TimeMode.arriveBy:
          effectiveDateTime = state.dateTime ?? now;
          arriveBy = true;
      }
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

      final rawPlan = await _currentFetchOperation?.valueOrCancellation();

      if (rawPlan == null) {
        // Operation was cancelled
        return;
      }

      if (!rawPlan.hasItineraries) {
        emit(state.copyWith(isLoading: false, error: noRoutesErrorKey));
        return;
      }

      // Enrich legs with operating hours from the bundled GTFS so OTP
      // 1.5/2.8 plans show the indicator just like the local planner.
      final plan = _enrichServiceHours(rawPlan);

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
