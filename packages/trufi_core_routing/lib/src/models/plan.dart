import 'itinerary.dart';
import 'itinerary_group.dart';
import 'plan_location.dart';

/// A trip plan containing itineraries from origin to destination.
class Plan {
  const Plan({
    this.from,
    this.to,
    this.itineraries,
    this.groupedItineraries,
    this.type,
  });

  final PlanLocation? from;
  final PlanLocation? to;
  final List<Itinerary>? itineraries;

  /// Itineraries grouped by route pattern.
  /// Each group contains itineraries that use the same routes/stops but differ in timing.
  final List<ItineraryGroup>? groupedItineraries;

  final String? type;

  /// Creates a [Plan] from JSON.
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      from: json['from'] != null
          ? PlanLocation.fromJson(json['from'] as Map<String, dynamic>)
          : null,
      to: json['to'] != null
          ? PlanLocation.fromJson(json['to'] as Map<String, dynamic>)
          : null,
      itineraries: json['itineraries'] != null
          ? (json['itineraries'] as List<dynamic>)
              .map((e) => Itinerary.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      type: json['type'] as String?,
    );
  }

  /// Converts this plan to JSON.
  Map<String, dynamic> toJson() {
    return {
      'from': from?.toJson(),
      'to': to?.toJson(),
      'itineraries': itineraries?.map((e) => e.toJson()).toList(),
      'type': type,
    };
  }

  /// Creates a copy of this plan with the given fields replaced.
  Plan copyWith({
    PlanLocation? from,
    PlanLocation? to,
    List<Itinerary>? itineraries,
    List<ItineraryGroup>? groupedItineraries,
    String? type,
  }) {
    return Plan(
      from: from ?? this.from,
      to: to ?? this.to,
      itineraries: itineraries ?? this.itineraries,
      groupedItineraries: groupedItineraries ?? this.groupedItineraries,
      type: type ?? this.type,
    );
  }

  /// Returns true if this plan has itineraries.
  bool get hasItineraries =>
      itineraries != null && itineraries!.isNotEmpty;

  /// Returns itineraries that are not walk-only.
  List<Itinerary> get transitItineraries {
    return itineraries?.where((i) => !i.isWalkOnly).toList() ?? [];
  }
}
