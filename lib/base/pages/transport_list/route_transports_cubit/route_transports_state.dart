part of 'route_transports_cubit.dart';

@immutable
class RouteTransportsState extends Equatable {
  final List<PatternOtp> transports;
  final String queryFilter;
  final bool isLoading;
  final bool isGeometryLoading;

  const RouteTransportsState({
    this.transports = const [],
    this.queryFilter = '',
    this.isLoading = false,
    this.isGeometryLoading = false,
  });

  RouteTransportsState copyWith({
    List<PatternOtp>? transports,
    String? queryFilter,
    bool? isLoading,
    bool? isGeometryLoading,
  }) {
    return RouteTransportsState(
      transports: transports ?? this.transports,
      queryFilter: queryFilter ?? this.queryFilter,
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
              ?.map<PatternOtp>((dynamic json) =>
                  PatternOtp.fromJson(json as Map<String, dynamic>))
              ?.toList() as List<PatternOtp>? ??
          <PatternOtp>[],
    );
  }

  @override
  List<Object> get props =>
      [transports, queryFilter, isLoading, isGeometryLoading];

  @override
  String toString() {
    return 'RouteTransportsState: {transports:$transports , queryFilter:$queryFilter '
        'isLoading:$isLoading isGeometryLoading: $isGeometryLoading}';
  }
}
