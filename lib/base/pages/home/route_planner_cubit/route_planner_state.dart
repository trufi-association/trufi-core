part of 'route_planner_cubit.dart';

@immutable
class RoutePlannerState extends Equatable {
  static const String _fromPlace = "fromPlace";
  static const String _toPlace = "toPlace";
  static const String _plan = "plan";
  static const String _itinerary = "itinerary";

  const RoutePlannerState({
    this.fromPlace,
    this.toPlace,
    this.plan,
    this.selectedItinerary,
  });

  final TrufiLocation? fromPlace;
  final TrufiLocation? toPlace;
  final Plan? plan;
  final Itinerary? selectedItinerary;

  RoutePlannerState copyWith({
    TrufiLocation? fromPlace,
    TrufiLocation? toPlace,
    Plan? plan,
    Itinerary? selectedItinerary,
  }) {
    return RoutePlannerState(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      plan: plan ?? this.plan,
      selectedItinerary: selectedItinerary ?? this.selectedItinerary,
    );
  }

  RoutePlannerState copyWithNullable({
    Optional<TrufiLocation?>? fromPlace = const Optional(),
    Optional<TrufiLocation?>? toPlace = const Optional(),
    Optional<Plan>? plan = const Optional(),
    Optional<Itinerary>? selectedItinerary = const Optional(),
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

  // Json
  factory RoutePlannerState.fromJson(Map<String, dynamic> json) {
    return RoutePlannerState(
      fromPlace:
          TrufiLocation.fromJson(json[_fromPlace] as Map<String, dynamic>),
      toPlace: TrufiLocation.fromJson(json[_toPlace] as Map<String, dynamic>),
      plan: Plan.fromJson(json[_plan] as Map<String, dynamic>),
      selectedItinerary:
          Itinerary.fromJson(json[_itinerary] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _fromPlace: fromPlace?.toJson(),
      _toPlace: toPlace?.toJson(),
      _plan: plan?.toJson(),
      _itinerary: selectedItinerary?.toJson(),
    };
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

class Optional<T> {
  final bool isValid;
  final T? _value;

  T? get value => _value;

  const Optional()
      : isValid = false,
        _value = null;

  const Optional.value(this._value) : isValid = true;
}
