/// GTFS Calendar entity.
/// Represents a service from calendar.txt
class GtfsCalendar {
  final String serviceId;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;
  final DateTime startDate;
  final DateTime endDate;

  const GtfsCalendar({
    required this.serviceId,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.startDate,
    required this.endDate,
  });

  /// Check if this service is active on a given date.
  bool isActiveOn(DateTime date) {
    // Check date range
    if (date.isBefore(startDate) || date.isAfter(endDate)) {
      return false;
    }

    // Check day of week
    switch (date.weekday) {
      case DateTime.monday:
        return monday;
      case DateTime.tuesday:
        return tuesday;
      case DateTime.wednesday:
        return wednesday;
      case DateTime.thursday:
        return thursday;
      case DateTime.friday:
        return friday;
      case DateTime.saturday:
        return saturday;
      case DateTime.sunday:
        return sunday;
      default:
        return false;
    }
  }

  /// Check if this is a weekday service.
  bool get isWeekday => monday && tuesday && wednesday && thursday && friday;

  /// Check if this is a weekend service.
  bool get isWeekend => saturday && sunday;

  factory GtfsCalendar.fromCsv(Map<String, String> row) {
    return GtfsCalendar(
      serviceId: row['service_id'] ?? '',
      monday: row['monday'] == '1',
      tuesday: row['tuesday'] == '1',
      wednesday: row['wednesday'] == '1',
      thursday: row['thursday'] == '1',
      friday: row['friday'] == '1',
      saturday: row['saturday'] == '1',
      sunday: row['sunday'] == '1',
      startDate: _parseDate(row['start_date'] ?? ''),
      endDate: _parseDate(row['end_date'] ?? ''),
    );
  }

  static DateTime _parseDate(String date) {
    if (date.length != 8) return DateTime.now();
    return DateTime(
      int.parse(date.substring(0, 4)),
      int.parse(date.substring(4, 6)),
      int.parse(date.substring(6, 8)),
    );
  }
}

/// GTFS CalendarDate entity.
/// Represents an exception from calendar_dates.txt
class GtfsCalendarDate {
  final String serviceId;
  final DateTime date;
  final GtfsExceptionType exceptionType;

  const GtfsCalendarDate({
    required this.serviceId,
    required this.date,
    required this.exceptionType,
  });

  factory GtfsCalendarDate.fromCsv(Map<String, String> row) {
    return GtfsCalendarDate(
      serviceId: row['service_id'] ?? '',
      date: _parseDate(row['date'] ?? ''),
      exceptionType: GtfsExceptionType.fromValue(
        int.tryParse(row['exception_type'] ?? '') ?? 1,
      ),
    );
  }

  static DateTime _parseDate(String date) {
    if (date.length != 8) return DateTime.now();
    return DateTime(
      int.parse(date.substring(0, 4)),
      int.parse(date.substring(4, 6)),
      int.parse(date.substring(6, 8)),
    );
  }
}

/// Exception type for calendar dates.
enum GtfsExceptionType {
  added(1),
  removed(2);

  final int value;
  const GtfsExceptionType(this.value);

  static GtfsExceptionType fromValue(int value) {
    return GtfsExceptionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GtfsExceptionType.added,
    );
  }
}
