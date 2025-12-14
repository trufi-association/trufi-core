import 'package:equatable/equatable.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// State for the route planner.
class RoutePlannerState extends Equatable {
  final TrufiLocation? fromPlace;
  final TrufiLocation? toPlace;
  final routing.Plan? plan;
  final routing.Itinerary? selectedItinerary;
  final bool isLoading;
  final String? error;

  const RoutePlannerState({
    this.fromPlace,
    this.toPlace,
    this.plan,
    this.selectedItinerary,
    this.isLoading = false,
    this.error,
  });

  RoutePlannerState copyWith({
    TrufiLocation? fromPlace,
    TrufiLocation? toPlace,
    routing.Plan? plan,
    routing.Itinerary? selectedItinerary,
    bool? isLoading,
    String? error,
  }) {
    return RoutePlannerState(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      plan: plan ?? this.plan,
      selectedItinerary: selectedItinerary ?? this.selectedItinerary,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Copy with nullable values support
  RoutePlannerState copyWithNullable({
    Optional<TrufiLocation?>? fromPlace,
    Optional<TrufiLocation?>? toPlace,
    Optional<routing.Plan?>? plan,
    Optional<routing.Itinerary?>? selectedItinerary,
    bool? isLoading,
    Optional<String?>? error,
  }) {
    return RoutePlannerState(
      fromPlace: fromPlace != null ? fromPlace.value : this.fromPlace,
      toPlace: toPlace != null ? toPlace.value : this.toPlace,
      plan: plan != null ? plan.value : this.plan,
      selectedItinerary: selectedItinerary != null
          ? selectedItinerary.value
          : this.selectedItinerary,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  /// Check if both origin and destination are defined
  bool get isPlacesDefined => fromPlace != null && toPlace != null;

  /// Check if we have a valid plan with selected itinerary
  bool get isPlanReady =>
      isPlacesDefined && plan != null && selectedItinerary != null;

  /// Check if the plan has an error
  bool get hasError => error != null;

  // JSON serialization
  factory RoutePlannerState.fromJson(Map<String, dynamic> json) {
    return RoutePlannerState(
      fromPlace: json['fromPlace'] != null
          ? TrufiLocation.fromJson(json['fromPlace'] as Map<String, dynamic>)
          : null,
      toPlace: json['toPlace'] != null
          ? TrufiLocation.fromJson(json['toPlace'] as Map<String, dynamic>)
          : null,
      plan: json['plan'] != null
          ? routing.Plan.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
      selectedItinerary: json['selectedItinerary'] != null
          ? routing.Itinerary.fromJson(
              json['selectedItinerary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromPlace': fromPlace?.toJson(),
      'toPlace': toPlace?.toJson(),
      'plan': plan?.toJson(),
      'selectedItinerary': selectedItinerary?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        fromPlace,
        toPlace,
        plan,
        selectedItinerary,
        isLoading,
        error,
      ];
}

/// Helper class for nullable optional values
class Optional<T> {
  final T value;
  const Optional(this.value);
}
