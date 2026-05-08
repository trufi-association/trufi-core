import 'package:flutter/material.dart' show TimeOfDay;

/// Operating hours for a transit route, derived from the GTFS
/// calendar (which days the service runs) plus a representative
/// daily window — usually the union of `frequencies.txt` ranges or
/// the bounds of `stop_times.txt` for the trip.
///
/// All fields are local-time as expressed in the feed; the consumer
/// is responsible for applying the agency's timezone if needed.
///
/// Lives in `trufi_core_routing` so both the transit list (route
/// detail / list tile) and the home screen (itinerary plan leg) can
/// render the same indicator without a cross-screen dependency.
class ServiceHours {
  /// Days the service runs, keyed by `DateTime.weekday` (1=Mon … 7=Sun).
  /// Empty set means the data wasn't available; the UI should fall
  /// back to "operating hours unavailable" rather than rendering
  /// "Closed every day".
  final Set<int> daysOfWeek;

  /// Earliest service start across the days listed above.
  final TimeOfDay startTime;

  /// Latest service end across the days listed above. May be after
  /// midnight (i.e. `startTime` > `endTime`) when the schedule wraps.
  final TimeOfDay endTime;

  const ServiceHours({
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
  });

  /// Whether the service is currently active given a [now] timestamp.
  /// `now` defaults to `DateTime.now()` so callers in widgets can omit
  /// it; tests pass an explicit value for reproducibility.
  bool isActiveAt(DateTime now) {
    if (!daysOfWeek.contains(now.weekday)) return false;
    final mins = now.hour * 60 + now.minute;
    final start = startTime.hour * 60 + startTime.minute;
    final end = endTime.hour * 60 + endTime.minute;
    if (start <= end) {
      return mins >= start && mins < end;
    }
    return mins >= start || mins < end;
  }

  /// JSON shape: `{daysOfWeek: [1,2,...], startMinutes: int, endMinutes: int}`.
  /// Encoding minutes-from-midnight is more compact than a `HH:mm` string
  /// and matches how the model is reasoned about internally.
  Map<String, dynamic> toJson() => {
    'daysOfWeek': daysOfWeek.toList(),
    'startMinutes': startTime.hour * 60 + startTime.minute,
    'endMinutes': endTime.hour * 60 + endTime.minute,
  };

  factory ServiceHours.fromJson(Map<String, dynamic> json) {
    final start = (json['startMinutes'] as num).toInt();
    final end = (json['endMinutes'] as num).toInt();
    return ServiceHours(
      daysOfWeek: (json['daysOfWeek'] as List).map((e) => e as int).toSet(),
      startTime: TimeOfDay(hour: start ~/ 60, minute: start % 60),
      endTime: TimeOfDay(hour: end ~/ 60, minute: end % 60),
    );
  }
}
