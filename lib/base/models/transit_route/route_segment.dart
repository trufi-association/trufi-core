import 'package:equatable/equatable.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

class RouteSegment extends Equatable {
  final String id;
  final TrufiLatLng start;
  final TrufiLatLng end;
  final List<TrufiLatLng> points;

  const RouteSegment({
    required this.id,
    required this.start,
    required this.end,
    required this.points,
  });

  RouteSegment copyWith({
    String? id,
    TrufiLatLng? start,
    TrufiLatLng? end,
    List<TrufiLatLng>? points,
  }) {
    return RouteSegment(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      points: points ?? this.points,
    );
  }

  factory RouteSegment.fromJson(Map<String, dynamic> json) {
    return RouteSegment(
      id: json['id'] as String,
      start: TrufiLatLng.fromJson(json['start'] as Map<String, dynamic>),
      end: TrufiLatLng.fromJson(json['end'] as Map<String, dynamic>),
      points: List<TrufiLatLng>.from((json['points'] as List<dynamic>).map(
        (x) => TrufiLatLng.fromJson(x as Map<String, dynamic>),
      )),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start.toJson(),
      'end': end.toJson(),
      'points': points.map((x) => x.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, start, end, points];
}
