import 'package:equatable/equatable.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

class RouteSegmentReport extends Equatable {
  final String id;
  final TrufiLatLng start;
  final TrufiLatLng end;

  const RouteSegmentReport({
    required this.id,
    required this.start,
    required this.end,
  });

  RouteSegmentReport copyWith({
    String? id,
    TrufiLatLng? start,
    TrufiLatLng? end,
  }) {
    return RouteSegmentReport(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  factory RouteSegmentReport.fromJson(Map<String, dynamic> json) {
    return RouteSegmentReport(
      id: json['id'] as String,
      start: TrufiLatLng.fromJson(json['start'] as Map<String, dynamic>),
      end: TrufiLatLng.fromJson(json['end'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start.toJson(),
      'end': end.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, start, end];
}
