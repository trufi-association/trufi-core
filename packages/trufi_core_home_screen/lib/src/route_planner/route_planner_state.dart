import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// State for the route planner.
///
/// Generic over location, plan, and itinerary types to allow
/// different implementations.
@immutable
class RoutePlannerState<TLocation extends ITrufiLocation,
    TPlan extends IPlan, TItinerary extends IItinerary> extends Equatable {
  const RoutePlannerState({
    this.fromPlace,
    this.toPlace,
    this.plan,
    this.selectedItinerary,
  });

  final TLocation? fromPlace;
  final TLocation? toPlace;
  final TPlan? plan;
  final TItinerary? selectedItinerary;

  RoutePlannerState<TLocation, TPlan, TItinerary> copyWith({
    TLocation? fromPlace,
    TLocation? toPlace,
    TPlan? plan,
    TItinerary? selectedItinerary,
  }) {
    return RoutePlannerState(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      plan: plan ?? this.plan,
      selectedItinerary: selectedItinerary ?? this.selectedItinerary,
    );
  }

  RoutePlannerState<TLocation, TPlan, TItinerary> copyWithNullable({
    Optional<TLocation?>? fromPlace = const Optional(),
    Optional<TLocation?>? toPlace = const Optional(),
    Optional<TPlan?>? plan = const Optional(),
    Optional<TItinerary?>? selectedItinerary = const Optional(),
  }) {
    return RoutePlannerState(
      fromPlace: fromPlace!.isValid ? fromPlace.value : this.fromPlace,
      toPlace: toPlace!.isValid ? toPlace.value : this.toPlace,
      plan: plan!.isValid ? plan.value : this.plan,
      selectedItinerary: selectedItinerary!.isValid
          ? selectedItinerary.value
          : this.selectedItinerary,
    );
  }

  bool get isPlacesDefined => fromPlace != null && toPlace != null;

  bool get isPlanCorrect =>
      isPlacesDefined && plan != null && selectedItinerary != null;

  @override
  String toString() {
    return "{ fromPlace ${fromPlace?.description}, toPlace ${toPlace?.description}, "
        "plan ${plan != null} }";
  }

  @override
  List<Object?> get props => [
        fromPlace,
        toPlace,
        plan,
        selectedItinerary,
      ];
}

/// Helper class for nullable updates in copyWithNullable.
class Optional<T> {
  final bool isValid;
  final T? _value;

  T? get value => _value;

  const Optional()
      : isValid = false,
        _value = null;

  const Optional.value(this._value) : isValid = true;
}
