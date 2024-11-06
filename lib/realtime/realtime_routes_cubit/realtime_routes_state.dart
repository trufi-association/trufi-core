part of 'realtime_routes_cubit.dart';

@immutable
class RealtimeRoutesState extends Equatable {
  const RealtimeRoutesState({
    required this.hasRealtime,
    required this.transitRoute,
  });

  final bool hasRealtime;
  final TransitRoute? transitRoute;

  RealtimeRoutesState copyWith({
    bool? hasRealtime,
    TransitRoute? transitRoute,
  }) {
    return RealtimeRoutesState(
      hasRealtime: hasRealtime ?? this.hasRealtime,
      transitRoute: transitRoute ?? this.transitRoute,
    );
  }

  RealtimeRoutesState copyWithNullable({
    Optional<bool>? hasRealtime = const Optional(),
    Optional<TransitRoute>? transitRoute = const Optional(),
  }) {
    return RealtimeRoutesState(
      hasRealtime:
          hasRealtime!.isValid ? hasRealtime.value ?? false : this.hasRealtime,
      transitRoute:
          transitRoute!.isValid ? transitRoute.value : this.transitRoute,
    );
  }

  @override
  List<Object?> get props => [
        hasRealtime,
        transitRoute,
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
