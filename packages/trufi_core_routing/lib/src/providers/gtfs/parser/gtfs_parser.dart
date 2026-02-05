import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/gtfs_models.dart';
import 'csv_parser.dart';

/// Result of parsing a GTFS feed.
class GtfsData {
  final List<GtfsAgency> agencies;
  final Map<String, GtfsStop> stops;
  final Map<String, GtfsRoute> routes;
  final Map<String, GtfsTrip> trips;
  final List<GtfsStopTime> stopTimes;
  final Map<String, GtfsCalendar> calendars;
  final List<GtfsCalendarDate> calendarDates;
  final List<GtfsFrequency> frequencies;
  final Map<String, GtfsShape> shapes;

  const GtfsData({
    required this.agencies,
    required this.stops,
    required this.routes,
    required this.trips,
    required this.stopTimes,
    required this.calendars,
    required this.calendarDates,
    required this.frequencies,
    required this.shapes,
  });

  /// Empty GTFS data.
  static const empty = GtfsData(
    agencies: [],
    stops: {},
    routes: {},
    trips: {},
    stopTimes: [],
    calendars: {},
    calendarDates: [],
    frequencies: [],
    shapes: {},
  );
}

/// Parser for GTFS feeds.
class GtfsParser {
  /// Parse a GTFS ZIP file from assets.
  static Future<GtfsData> parseFromAsset(String assetPath) async {
    final sw = Stopwatch()..start();
    debugPrint('GtfsParser: Loading GTFS from $assetPath');

    final bytes = await rootBundle.load(assetPath);
    final data = bytes.buffer.asUint8List();

    final result = await compute(_parseGtfsInIsolate, data);

    sw.stop();
    debugPrint('GtfsParser: Parsed GTFS in ${sw.elapsedMilliseconds}ms');
    debugPrint('GtfsParser: ${result.stops.length} stops, ${result.routes.length} routes, ${result.trips.length} trips');

    return result;
  }

  /// Parse GTFS data from raw bytes (synchronous, for use in isolates).
  static GtfsData parseFromBytes(Uint8List data) {
    final sw = Stopwatch()..start();

    final result = _parseGtfsInIsolate(data);

    sw.stop();
    debugPrint('GtfsParser: Parsed GTFS in ${sw.elapsedMilliseconds}ms');
    debugPrint('GtfsParser: ${result.stops.length} stops, ${result.routes.length} routes, ${result.trips.length} trips');

    return result;
  }

  /// Parse GTFS data in an isolate.
  static GtfsData _parseGtfsInIsolate(Uint8List data) {
    final archive = ZipDecoder().decodeBytes(data);
    final files = <String, String>{};

    // Extract all files
    for (final file in archive) {
      if (file.isFile) {
        final name = file.name.split('/').last;
        files[name] = utf8.decode(file.content as List<int>);
      }
    }

    // Parse each file
    final agencies = _parseAgencies(files['agency.txt']);
    final stops = _parseStops(files['stops.txt']);
    final routes = _parseRoutes(files['routes.txt']);
    final trips = _parseTrips(files['trips.txt']);
    final stopTimes = _parseStopTimes(files['stop_times.txt']);
    final calendars = _parseCalendars(files['calendar.txt']);
    final calendarDates = _parseCalendarDates(files['calendar_dates.txt']);
    final frequencies = _parseFrequencies(files['frequencies.txt']);
    final shapes = _parseShapes(files['shapes.txt']);

    return GtfsData(
      agencies: agencies,
      stops: stops,
      routes: routes,
      trips: trips,
      stopTimes: stopTimes,
      calendars: calendars,
      calendarDates: calendarDates,
      frequencies: frequencies,
      shapes: shapes,
    );
  }

  static List<GtfsAgency> _parseAgencies(String? content) {
    if (content == null) return [];
    return CsvParser.parse(content).map(GtfsAgency.fromCsv).toList();
  }

  static Map<String, GtfsStop> _parseStops(String? content) {
    if (content == null) return {};
    final stops = CsvParser.parse(content).map(GtfsStop.fromCsv);
    return {for (final s in stops) s.id: s};
  }

  static Map<String, GtfsRoute> _parseRoutes(String? content) {
    if (content == null) return {};
    final routes = CsvParser.parse(content).map(GtfsRoute.fromCsv);
    return {for (final r in routes) r.id: r};
  }

  static Map<String, GtfsTrip> _parseTrips(String? content) {
    if (content == null) return {};
    final trips = CsvParser.parse(content).map(GtfsTrip.fromCsv);
    return {for (final t in trips) t.id: t};
  }

  static List<GtfsStopTime> _parseStopTimes(String? content) {
    if (content == null) return [];
    return CsvParser.parse(content).map(GtfsStopTime.fromCsv).toList();
  }

  static Map<String, GtfsCalendar> _parseCalendars(String? content) {
    if (content == null) return {};
    final calendars = CsvParser.parse(content).map(GtfsCalendar.fromCsv);
    return {for (final c in calendars) c.serviceId: c};
  }

  static List<GtfsCalendarDate> _parseCalendarDates(String? content) {
    if (content == null) return [];
    return CsvParser.parse(content).map(GtfsCalendarDate.fromCsv).toList();
  }

  static List<GtfsFrequency> _parseFrequencies(String? content) {
    if (content == null) return [];
    return CsvParser.parse(content).map(GtfsFrequency.fromCsv).toList();
  }

  static Map<String, GtfsShape> _parseShapes(String? content) {
    if (content == null) return {};

    final points = CsvParser.parse(content).map(GtfsShapePoint.fromCsv).toList();

    // Group by shape ID
    final grouped = <String, List<GtfsShapePoint>>{};
    for (final point in points) {
      grouped.putIfAbsent(point.shapeId, () => []).add(point);
    }

    // Sort by sequence and create shapes
    final shapes = <String, GtfsShape>{};
    for (final entry in grouped.entries) {
      final sortedPoints = entry.value..sort((a, b) => a.sequence.compareTo(b.sequence));
      shapes[entry.key] = GtfsShape(id: entry.key, points: sortedPoints);
    }

    return shapes;
  }
}
