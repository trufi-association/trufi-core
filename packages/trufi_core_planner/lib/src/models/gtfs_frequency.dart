/// GTFS Frequency entity.
/// Represents a frequency from frequencies.txt
class GtfsFrequency {
  final String tripId;
  final Duration startTime;
  final Duration endTime;
  final int headwaySecs;
  final bool exactTimes;

  const GtfsFrequency({
    required this.tripId,
    required this.startTime,
    required this.endTime,
    required this.headwaySecs,
    this.exactTimes = false,
  });

  /// Headway as Duration.
  Duration get headway => Duration(seconds: headwaySecs);

  // NOTE(#945): the old `displayFrequency` getter ("every 10 min") was an
  // English-only trap for UI code. Use the raw [headway] and format in the
  // widget layer with the screen package's localizations.

  /// Start time as formatted string (HH:MM).
  String get startTimeFormatted => _formatTime(startTime);

  /// End time as formatted string (HH:MM).
  String get endTimeFormatted => _formatTime(endTime);

  static String _formatTime(Duration d) {
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  factory GtfsFrequency.fromCsv(Map<String, String> row) {
    return GtfsFrequency(
      tripId: row['trip_id'] ?? '',
      startTime: _parseTime(row['start_time'] ?? ''),
      endTime: _parseTime(row['end_time'] ?? ''),
      headwaySecs: int.tryParse(row['headway_secs'] ?? '') ?? 600,
      exactTimes: row['exact_times'] == '1',
    );
  }

  static Duration _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 3) return Duration.zero;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}
