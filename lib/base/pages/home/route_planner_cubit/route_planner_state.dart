part of 'route_planner_cubit.dart';

@immutable
class RoutePlannerState extends Equatable {
  static const String _fromPlace = "fromPlace";
  static const String _toPlace = "toPlace";
  static const String _plan = "plan";
  static const String _itinerary = "itinerary";
  static const String _dateTime = "selectedDateTime";
  static const String _enableDebugOutput = "enableDebugOutput";

  const RoutePlannerState({
    this.fromPlace,
    this.toPlace,
    this.plan,
    this.selectedItinerary,
    this.selectedDateTime,
    this.enableDebugOutput,
  });

  final TrufiLocation? fromPlace;
  final TrufiLocation? toPlace;
  final Plan? plan;
  final Itinerary? selectedItinerary;
  final DateTime? selectedDateTime;
  final bool? enableDebugOutput;

  RoutePlannerState copyWith({
    TrufiLocation? fromPlace,
    TrufiLocation? toPlace,
    Plan? plan,
    Itinerary? selectedItinerary,
    DateTime? selectedDateTime,
    bool? enableDebugOutput,
  }) {
    return RoutePlannerState(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      plan: plan ?? this.plan,
      selectedItinerary: selectedItinerary ?? this.selectedItinerary,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      enableDebugOutput: enableDebugOutput ?? this.enableDebugOutput,
    );
  }

  RoutePlannerState copyWithNullable({
    Optional<TrufiLocation?>? fromPlace = const Optional(),
    Optional<TrufiLocation?>? toPlace = const Optional(),
    Optional<Plan>? plan = const Optional(),
    Optional<Itinerary>? selectedItinerary = const Optional(),
    Optional<DateTime>? selectedDateTime = const Optional(),
    Optional<bool>? enableDebugOutput = const Optional(),
  }) {
    return RoutePlannerState(
      fromPlace: fromPlace!.isValid ? fromPlace.value : this.fromPlace,
      toPlace: toPlace!.isValid ? toPlace.value : this.toPlace,
      plan: plan!.isValid ? plan.value : this.plan,
      selectedItinerary: selectedItinerary!.isValid
          ? selectedItinerary.value
          : this.selectedItinerary,
      selectedDateTime: selectedDateTime!.isValid
          ? selectedDateTime.value
          : this.selectedDateTime,
      enableDebugOutput: enableDebugOutput!.isValid
          ? enableDebugOutput.value
          : this.enableDebugOutput,
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
      selectedDateTime:
          json[_dateTime] != null ? DateTime.parse(json[_dateTime]) : null,
      enableDebugOutput: json[_enableDebugOutput],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _fromPlace: fromPlace?.toJson(),
      _toPlace: toPlace?.toJson(),
      _plan: plan?.toJson(),
      _itinerary: selectedItinerary?.toJson(),
      _dateTime: selectedDateTime?.toIso8601String(),
      _enableDebugOutput: enableDebugOutput,
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
        selectedDateTime,
        enableDebugOutput,
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
