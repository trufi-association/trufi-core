import '../models/gtfs_calendar.dart';
import '../models/gtfs_frequency.dart';
import '../models/gtfs_stop_time.dart';
import '../models/gtfs_trip.dart';

/// Departure information for a stop.
class StopDeparture {
  final String tripId;
  final String routeId;
  final String headsign;
  final DateTime departureTime;
  final int stopSequence;

  const StopDeparture({
    required this.tripId,
    required this.routeId,
    required this.headsign,
    required this.departureTime,
    required this.stopSequence,
  });
}

/// Frequency information for a route.
class RouteFrequencyInfo {
  final String routeId;
  final Duration avgHeadway;
  final int tripCount;

  const RouteFrequencyInfo({
    required this.routeId,
    required this.avgHeadway,
    required this.tripCount,
  });
}

/// Index for schedule-based queries (departures, frequencies).
class GtfsScheduleIndex {
  final Map<String, GtfsTrip> _trips;
  final List<GtfsStopTime> _stopTimes;
  final Map<String, GtfsCalendar> _calendars;
  final List<GtfsCalendarDate> _calendarDates;
  final List<GtfsFrequency> _frequencies;

  late final Map<String, List<GtfsStopTime>> _stopTimesByStop;
  late final Map<String, List<GtfsTrip>> _tripsByRoute;

  GtfsScheduleIndex({
    required Map<String, GtfsTrip> trips,
    required List<GtfsStopTime> stopTimes,
    required Map<String, GtfsCalendar> calendars,
    required List<GtfsCalendarDate> calendarDates,
    required List<GtfsFrequency> frequencies,
  })  : _trips = trips,
        _stopTimes = stopTimes,
        _calendars = calendars,
        _calendarDates = calendarDates,
        _frequencies = frequencies {
    _buildIndices();
  }

  void _buildIndices() {
    // Index stop times by stop ID
    _stopTimesByStop = {};
    for (final st in _stopTimes) {
      _stopTimesByStop.putIfAbsent(st.stopId, () => []).add(st);
    }

    // Index trips by route ID
    _tripsByRoute = {};
    for (final trip in _trips.values) {
      _tripsByRoute.putIfAbsent(trip.routeId, () => []).add(trip);
    }

    // Sort stop times by departure time
    for (final stopTimes in _stopTimesByStop.values) {
      stopTimes.sort((a, b) {
        final timeA = a.departureTime ?? a.arrivalTime ?? Duration.zero;
        final timeB = b.departureTime ?? b.arrivalTime ?? Duration.zero;
        return timeA.compareTo(timeB);
      });
    }
  }

  /// Get next departures from a stop.
  List<StopDeparture> getNextDepartures(
    String stopId, {
    DateTime? atTime,
    int limit = 5,
  }) {
    final now = atTime ?? DateTime.now();
    final currentTimeOfDay = Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
    );

    final stopTimes = _stopTimesByStop[stopId] ?? [];
    final departures = <StopDeparture>[];

    for (final st in stopTimes) {
      final departureTime = st.departureTime ?? st.arrivalTime;
      if (departureTime == null) continue;

      final trip = _trips[st.tripId];
      if (trip == null) continue;

      // Simple time comparison (doesn't handle service calendars yet)
      if (departureTime.compareTo(currentTimeOfDay) >= 0) {
        final departureDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          departureTime.inHours,
          departureTime.inMinutes % 60,
          departureTime.inSeconds % 60,
        );

        departures.add(StopDeparture(
          tripId: st.tripId,
          routeId: trip.routeId,
          headsign: trip.headsign ?? '',
          departureTime: departureDateTime,
          stopSequence: st.stopSequence,
        ));

        if (departures.length >= limit) break;
      }
    }

    return departures;
  }

  /// Get frequency info for a route.
  RouteFrequencyInfo? getRouteFrequency(String routeId) {
    final trips = _tripsByRoute[routeId];
    if (trips == null || trips.isEmpty) return null;

    // Calculate average headway from frequencies
    final routeFrequencies = _frequencies.where((f) {
      final trip = _trips[f.tripId];
      return trip?.routeId == routeId;
    }).toList();

    if (routeFrequencies.isEmpty) {
      // No frequency data, return trip count only
      return RouteFrequencyInfo(
        routeId: routeId,
        avgHeadway: Duration.zero,
        tripCount: trips.length,
      );
    }

    // Calculate average headway
    final totalHeadway = routeFrequencies.fold<int>(
      0,
      (sum, f) => sum + f.headwaySecs,
    );
    final avgHeadway = Duration(
      seconds: totalHeadway ~/ routeFrequencies.length,
    );

    return RouteFrequencyInfo(
      routeId: routeId,
      avgHeadway: avgHeadway,
      tripCount: trips.length,
    );
  }
}
