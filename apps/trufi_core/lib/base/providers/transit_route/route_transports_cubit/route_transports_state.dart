part of 'route_transports_cubit.dart';

@immutable
class RouteTransportsState extends Equatable {
  final List<TransitRoute> transports;
  final List<TransitRoute> filterTransports;
  final bool isLoading;
  final bool isGeometryLoading;

  const RouteTransportsState({
    this.transports = const [],
    this.filterTransports = const [],
    this.isLoading = false,
    this.isGeometryLoading = false,
  });

  RouteTransportsState copyWith({
    List<TransitRoute>? transports,
    List<TransitRoute>? filterTransports,
    bool? isLoading,
    bool? isGeometryLoading,
  }) {
    return RouteTransportsState(
      transports: transports ?? this.transports,
      filterTransports: filterTransports ?? this.filterTransports,
      isLoading: isLoading ?? this.isLoading,
      isGeometryLoading: isGeometryLoading ?? this.isGeometryLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transports': transports.map((x) => x.toJson()).toList(),
    };
  }

  factory RouteTransportsState.fromJson(Map<String, dynamic> json) {
    return RouteTransportsState(
      transports: json['transports']
              ?.map<TransitRoute>((dynamic json) =>
                  TransitRoute.fromJson(json as Map<String, dynamic>))
              ?.toList() as List<TransitRoute>? ??
          <TransitRoute>[],
    );
  }

  @override
  List<Object> get props =>
      [transports, isLoading, isGeometryLoading, filterTransports];

  @override
  String toString() {
    return 'RouteTransportsState: {transports:$transports,'
        'isLoading:$isLoading isGeometryLoading: $isGeometryLoading}';
  }
}
