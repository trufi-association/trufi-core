import 'package:flutter/foundation.dart';

import '../models/gtfs_models.dart';

/// Departure information for a stop.
class StopDeparture {
  final String tripId;
  final String routeId;
  final Duration departureTime;
  final String? headsign;
  final String serviceId;

  const StopDeparture({
    required this.tripId,
    required this.routeId,
    required this.departureTime,
    this.headsign,
    required this.serviceId,
  });

  /// Format departure time as HH:MM.
  String get departureTimeFormatted {
    final hours = (departureTime.inMinutes ~/ 60) % 24;
    final minutes = departureTime.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}

/// Route frequency information.
class RouteFrequencyInfo {
  final String routeId;
  final Duration? startTime;
  final Duration? endTime;
  final int? headwaySecs;
  final String? headsign;

  const RouteFrequencyInfo({
    required this.routeId,
    this.startTime,
    this.endTime,
    this.headwaySecs,
    this.headsign,
  });

  /// Display string for frequency (e.g., "every 10 min").
  String? get frequencyDisplay {
    if (headwaySecs == null) return null;
    final minutes = headwaySecs! ~/ 60;
    if (minutes < 60) {
      return 'every $minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return 'every $hours hr';
    }
    return 'every $hours hr $remainingMinutes min';
  }

  /// Display string for operating hours.
  String? get hoursDisplay {
    if (startTime == null || endTime == null) return null;
    return '${_formatTime(startTime!)} - ${_formatTime(endTime!)}';
  }

  static String _formatTime(Duration d) {
    final hours = (d.inMinutes ~/ 60) % 24;
    final minutes = d.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}

/// Index for schedule-based queries.
class GtfsScheduleIndex {
  final Map<String, GtfsTrip> _trips;
  final List<GtfsStopTime> _stopTimes;
  final Map<String, GtfsCalendar> _calendars;
  final List<GtfsCalendarDate> _calendarDates;
  final List<GtfsFrequency> _frequencies;

  /// Departures at each stop, grouped by service.
  late final Map<String, List<StopDeparture>> _stopDepartures;

  /// Frequencies by route.
  late final Map<String, List<GtfsFrequency>> _routeFrequencies;

  /// Active service IDs for a given date (cache).
  final Map<DateTime, Set<String>> _activeServicesCache = {};

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
    _buildIndex();
  }

  void _buildIndex() {
    final sw = Stopwatch()..start();

    _buildStopDepartures();
    _buildRouteFrequencies();

    sw.stop();
    debugPrint('GtfsScheduleIndex: Built in ${sw.elapsedMilliseconds}ms');
  }

  void _buildStopDepartures() {
    _stopDepartures = {};

    for (final st in _stopTimes) {
      if (st.departureTime == null) continue;

      final trip = _trips[st.tripId];
      if (trip == null) continue;

      _stopDepartures.putIfAbsent(st.stopId, () => []).add(StopDeparture(
        tripId: st.tripId,
        routeId: trip.routeId,
        departureTime: st.departureTime!,
        headsign: st.stopHeadsign ?? trip.headsign,
        serviceId: trip.serviceId,
      ));
    }

    // Sort by departure time
    for (final departures in _stopDepartures.values) {
      departures.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }
  }

  void _buildRouteFrequencies() {
    _routeFrequencies = {};

    for (final freq in _frequencies) {
      final trip = _trips[freq.tripId];
      if (trip == null) continue;

      _routeFrequencies.putIfAbsent(trip.routeId, () => []).add(freq);
    }
  }

  /// Get active service IDs for a date.
  Set<String> getActiveServices(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (_activeServicesCache.containsKey(dateOnly)) {
      return _activeServicesCache[dateOnly]!;
    }

    final activeServices = <String>{};

    // Check regular calendar
    for (final calendar in _calendars.values) {
      if (calendar.isActiveOn(dateOnly)) {
        activeServices.add(calendar.serviceId);
      }
    }

    // Apply exceptions
    for (final exception in _calendarDates) {
      if (exception.date.year == dateOnly.year &&
          exception.date.month == dateOnly.month &&
          exception.date.day == dateOnly.day) {
        if (exception.exceptionType == GtfsExceptionType.added) {
          activeServices.add(exception.serviceId);
        } else {
          activeServices.remove(exception.serviceId);
        }
      }
    }

    _activeServicesCache[dateOnly] = activeServices;
    return activeServices;
  }

  /// Get next departures from a stop.
  List<StopDeparture> getNextDepartures(
    String stopId, {
    DateTime? atTime,
    int limit = 5,
  }) {
    atTime ??= DateTime.now();
    final currentTime = Duration(
      hours: atTime.hour,
      minutes: atTime.minute,
    );

    final activeServices = getActiveServices(atTime);
    final departures = _stopDepartures[stopId] ?? [];

    return departures
        .where((d) => activeServices.contains(d.serviceId))
        .where((d) => d.departureTime >= currentTime)
        .take(limit)
        .toList();
  }

  /// Get frequency info for a route.
  RouteFrequencyInfo? getRouteFrequency(String routeId) {
    final frequencies = _routeFrequencies[routeId];
    if (frequencies == null || frequencies.isEmpty) return null;

    // Use first frequency as representative
    final freq = frequencies.first;
    final trip = _trips[freq.tripId];

    return RouteFrequencyInfo(
      routeId: routeId,
      startTime: freq.startTime,
      endTime: freq.endTime,
      headwaySecs: freq.headwaySecs,
      headsign: trip?.headsign,
    );
  }

  /// Check if a route has frequency-based service.
  bool hasFrequency(String routeId) =>
      _routeFrequencies.containsKey(routeId) &&
      _routeFrequencies[routeId]!.isNotEmpty;
}
