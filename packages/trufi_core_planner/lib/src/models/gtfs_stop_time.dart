/// GTFS StopTime entity.
/// Represents a stop time from stop_times.txt
class GtfsStopTime {
  final String tripId;
  final Duration? arrivalTime;
  final Duration? departureTime;
  final String stopId;
  final int stopSequence;
  final String? stopHeadsign;
  final GtfsPickupType pickupType;
  final GtfsDropOffType dropOffType;
  final double? shapeDistTraveled;
  final GtfsTimepoint timepoint;

  const GtfsStopTime({
    required this.tripId,
    this.arrivalTime,
    this.departureTime,
    required this.stopId,
    required this.stopSequence,
    this.stopHeadsign,
    this.pickupType = GtfsPickupType.regular,
    this.dropOffType = GtfsDropOffType.regular,
    this.shapeDistTraveled,
    this.timepoint = GtfsTimepoint.exact,
  });

  factory GtfsStopTime.fromCsv(Map<String, String> row) {
    return GtfsStopTime(
      tripId: row['trip_id'] ?? '',
      arrivalTime: _parseTime(row['arrival_time']),
      departureTime: _parseTime(row['departure_time']),
      stopId: row['stop_id'] ?? '',
      stopSequence: int.tryParse(row['stop_sequence'] ?? '') ?? 0,
      stopHeadsign: row['stop_headsign'],
      pickupType: GtfsPickupType.fromValue(
        int.tryParse(row['pickup_type'] ?? '') ?? 0,
      ),
      dropOffType: GtfsDropOffType.fromValue(
        int.tryParse(row['drop_off_type'] ?? '') ?? 0,
      ),
      shapeDistTraveled: double.tryParse(row['shape_dist_traveled'] ?? ''),
      timepoint: GtfsTimepoint.fromValue(
        int.tryParse(row['timepoint'] ?? '') ?? 1,
      ),
    );
  }

  /// Parse GTFS time format (HH:MM:SS) to Duration.
  /// GTFS times can exceed 24:00:00 for trips past midnight.
  static Duration? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;

    final parts = time.split(':');
    if (parts.length != 3) return null;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}

/// Pickup type for stop times.
enum GtfsPickupType {
  regular(0),
  noPickup(1),
  phoneAgency(2),
  coordinateDriver(3);

  final int value;
  const GtfsPickupType(this.value);

  static GtfsPickupType fromValue(int value) {
    return GtfsPickupType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsPickupType.regular,
    );
  }
}

/// Drop-off type for stop times.
enum GtfsDropOffType {
  regular(0),
  noDropOff(1),
  phoneAgency(2),
  coordinateDriver(3);

  final int value;
  const GtfsDropOffType(this.value);

  static GtfsDropOffType fromValue(int value) {
    return GtfsDropOffType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsDropOffType.regular,
    );
  }
}

/// Timepoint indicator.
enum GtfsTimepoint {
  approximate(0),
  exact(1);

  final int value;
  const GtfsTimepoint(this.value);

  static GtfsTimepoint fromValue(int value) {
    return GtfsTimepoint.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsTimepoint.exact,
    );
  }
}
