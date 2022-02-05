part of 'route_transports_cubit.dart';

@immutable
class RouteTransportsState extends Equatable {
  final List<PatternOtp> transports;
  final bool isLoading;
  final bool isGeometryLoading;

  const RouteTransportsState({
    this.transports = const [],
    this.isLoading = false,
    this.isGeometryLoading = false,
  });

  RouteTransportsState copyWith({
    List<PatternOtp>? transports,
    bool? isLoading,
    bool? isGeometryLoading,
  }) {
    return RouteTransportsState(
      transports: transports ?? this.transports,
      isLoading: isLoading ?? this.isLoading,
      isGeometryLoading: isGeometryLoading ?? this.isGeometryLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transports': transports.map((x) => x.toJson()).toList(),
      // 'isLoading': isLoading,
      // 'isGeometryLoading': isGeometryLoading,
    };
  }

  factory RouteTransportsState.fromJson(Map<String, dynamic> json) {
    return RouteTransportsState(
      transports: json['transports']
              ?.map<PatternOtp>((dynamic json) =>
                  PatternOtp.fromJson(json as Map<String, dynamic>))
              ?.toList() as List<PatternOtp>? ??
          <PatternOtp>[],
      // isLoading: json['isLoading'] ?? false,
      // isGeometryLoading: json['isGeometryLoading'] ?? false,
    );
  }

  @override
  List<Object> get props => [transports, isLoading, isGeometryLoading];

  @override
  String toString() {
    return 'RouteTransportsState: {transports:$transports , isLoading:$isLoading '
        'isGeometryLoading: $isGeometryLoading}';
  }
}
