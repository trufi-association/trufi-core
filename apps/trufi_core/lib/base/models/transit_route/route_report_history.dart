import 'package:equatable/equatable.dart';
import 'package:trufi_core/base/models/transit_route/route_segment_report.dart';

// idDevice: string
// idEdition: string
// transportCode: string
// typeRoute: TYPEROUTE
// state: STATE
// userLocation?: POSITION
// description?: string
// phone?: string
// segment?: SEGMENT
// segments?: SEGMENT[]
class RouteReportHistory extends Equatable {
  final String id;
  final String state;
  final String description;
  final Map<String, RouteSegmentReport> reportedSegments;

  const RouteReportHistory({
    required this.id,
    required this.state,
    required this.description,
    required this.reportedSegments,
  });

  RouteReportHistory copyWith({
    String? id,
    String? state,
    String? description,
    Map<String, RouteSegmentReport>? reportedSegments,
  }) {
    return RouteReportHistory(
      id: id ?? this.id,
      state: state ?? this.state,
      description: description ?? this.description,
      reportedSegments: reportedSegments ?? this.reportedSegments,
    );
  }

  factory RouteReportHistory.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> jsonReportedSegments =
        json['reportedSegments'] as Map<String, dynamic>;
    final Map<String, RouteSegmentReport> reportedSegments =
        jsonReportedSegments.map(
      (key, value) => MapEntry<String, RouteSegmentReport>(
          key, RouteSegmentReport.fromJson(value as Map<String, dynamic>)),
    );

    return RouteReportHistory(
      id: json['id'].toString(),
      state: json['state'].toString(),
      description: json['description'].toString(),
      reportedSegments: reportedSegments,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonReportedSegments =
        reportedSegments.map((key, value) => MapEntry(key, value.toJson()));

    return {
      'id': id,
      'state': state,
      'description': description,
      'reportedSegments': jsonReportedSegments,
    };
  }

  @override
  List<Object?> get props => [id, state, description, reportedSegments];
}
