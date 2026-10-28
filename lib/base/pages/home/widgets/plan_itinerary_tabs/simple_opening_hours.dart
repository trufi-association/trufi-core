import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

/// Parser for the OSM-style `opening_hours` strings of the per-route
/// schedules (`transportOpeningHours`, `transportFrecuency`).
///
/// Every weekday maps to a list of tokens. A token is either a service
/// window — `05:00-17:30`, the line runs continuously — or a single
/// departure — `17:30`, one bus leaves at that time. Lines with a handful
/// of fixed departures per day (several in Jilotepec) use the latter:
/// `Mo-Su 17:30`, `Mo-Fr 05:00,07:10`, `Mo-Sa 05:30-18:50; Su 08:00`.
class SimpleOpeningHours {
  final String inp;
  final Map<String, List<String>> openingHours = {
    "mo": [],
    "tu": [],
    "we": [],
    "th": [],
    "fr": [],
    "sa": [],
    "su": [],
    "ph": [],
  };

  static const List<String> _weekdayKeys = [
    "mo",
    "tu",
    "we",
    "th",
    "fr",
    "sa",
    "su",
  ];

  static final RegExp _departureToken = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');

  SimpleOpeningHours(this.inp) {
    parse(inp);
  }

  static String getDayName(String key, TrufiBaseLocalization localizationST) {
    final openingHours = <String, String>{
      "mo": localizationST.weekdayMO,
      "tu": localizationST.weekdayTU,
      "we": localizationST.weekdayWE,
      "th": localizationST.weekdayTH,
      "fr": localizationST.weekdayFR,
      "sa": localizationST.weekdaySA,
      "su": localizationST.weekdaySU,
      "ph": localizationST.weekdayPH,
    };
    return openingHours[key]!;
  }

  /// Whether [token] is a single departure (`17:30`) rather than a service
  /// window (`05:00-17:30`) or an open-ended time (`09:00+`).
  static bool isDeparture(String token) => _departureToken.hasMatch(token);

  /// The service windows of the day [dayKey] (`mo` … `su`, `ph`),
  /// e.g. `["05:00-17:30"]`.
  List<String> rangesOf(String dayKey) => (openingHours[dayKey] ?? const [])
      .where((token) => !isDeparture(token))
      .toList();

  /// The single departures of the day [dayKey], zero-padded and sorted,
  /// e.g. `["05:00", "07:10"]`.
  List<String> departuresOf(String dayKey) => (openingHours[dayKey] ?? const [])
      .where(isDeparture)
      .map(formatTimeString)
      .toList()
    ..sort();

  /// The service windows of the weekday of [date].
  List<String> rangesOn(DateTime date) => rangesOf(_dayKey(date));

  /// The single departures of the weekday of [date].
  List<String> departuresOn(DateTime date) => departuresOf(_dayKey(date));

  /// The first departure of the weekday of [date] at or after its time of
  /// day, or null when every departure of that day has already left.
  String? nextDepartureOn(DateTime date) {
    final now = _timeOfDay(date);
    for (final departure in departuresOn(date)) {
      if (!_parseTime(departure).isBefore(now)) return departure;
    }
    return null;
  }

  /// Whether [date] falls inside one of the service windows of its weekday.
  bool isWithinServiceWindowOn(DateTime date) =>
      rangesOn(date).any((range) => _isWithinRange(range, date));

  /// Whether the line is in service at [date]: inside a service window, or
  /// with a departure still ahead that day.
  bool isOpenOn(DateTime date) =>
      isWithinServiceWindowOn(date) || nextDepartureOn(date) != null;

  bool _isWithinRange(String range, DateTime date) {
    //TODO: times like 09:00+ are not supported here
    final timedata = range.split('-');
    if (timedata.length != 2) return false;
    final timeStart = formatTimeString(timedata[0]);
    final timeEnd = formatTimeString(timedata[1]);
    final openTime = DateTime.parse("2016-01-01 $timeStart:00");
    DateTime closeTime = DateTime.parse("2016-01-01 $timeEnd:00");
    final currentDateTime = _timeOfDay(date);
    final isDiferentDay = openTime.isAfter(closeTime);

    if (isDiferentDay) {
      closeTime = DateTime.parse("2016-01-02 $timeEnd:00");
    }
    final isAfterOpening = isDiferentDay
        ? currentDateTime.isAfter(openTime) ||
            currentDateTime.isBefore(DateTime.parse("2016-01-01 $timeEnd:00"))
        : currentDateTime.isAfter(openTime);
    return isAfterOpening && currentDateTime.isBefore(closeTime);
  }

  String _dayKey(DateTime date) => _weekdayKeys[date.weekday - 1];

  DateTime _parseTime(String time) =>
      DateTime.parse("2016-01-01 ${formatTimeString(time)}:00");

  DateTime _timeOfDay(DateTime date) =>
      DateTime.parse("2016-01-01 ${durationToString(date)}");

  String formatTimeString(String timeString) {
    List<String> timeParts = timeString.split(":");

    String hour = timeParts[0].length == 1 ? '0${timeParts[0]}' : timeParts[0];

    String formattedTimeString = "$hour:${timeParts[1]}";

    return formattedTimeString;
  }

  String durationToString(DateTime date) {
    String twoDigits(int n) {
      if (n >= 10) {
        return "$n";
      }
      return "0$n";
    }

    String hours = twoDigits(date.hour);
    String minutes = twoDigits(date.minute);

    return "$hours:$minutes:00";
  }

  /// Compares to timestrings e.g. "18:00"
  /// if time1 > time2 -> 1
  /// if time1 < time2 -> -1
  /// if time1 == time2 -> 0
  int compareTime(String time1, String time2,
      {bool isDiferentDay = false, bool isDiferentDayB = false}) {
    final date1 =
        DateTime.parse("2016-${isDiferentDay ? "02" : "01"}-01 $time1:00");
    final date2 =
        DateTime.parse("2016-${isDiferentDayB ? "02" : "01"}-01 $time2:00");
    return date1.compareTo(date2);
  }

  bool isOpenNow() {
    return isOpenOn(DateTime.now());
  }

  void parse(String inp) {
    inp = simplify(inp);
    final parts = splitHard(inp);
    for (var part in parts) {
      parseHardPart(part);
    }
  }

  String simplify(String input) {
    if (input == "24/7") {
      input = "mo-su 00:00-24:00; ph 00:00-24:00";
    }
    input = input.toLowerCase();
    input = input.trim();
    input = input.replaceAll(RegExp(r' +(?= )'), ''); //replace double spaces

    input = input.replaceAll(' -', '-');
    input = input.replaceAll('- ', '-');

    input = input.replaceAll(' :', ':');
    input = input.replaceAll(': ', ':');

    input = input.replaceAll(' ,', ',');
    input = input.replaceAll(', ', ',');

    input = input.replaceAll(' ;', ';');
    input = input.replaceAll('; ', ';');
    return input;
  }

  List<String> splitHard(String inp) {
    return inp.split(';');
  }

  void parseHardPart(String part) {
    if (part == "24/7") {
      part = "mo-su 00:00-24:00";
    }
    final segments = part.split(RegExp(r' |\,'));

    Map<String, List<String>> tempData = {};
    List<String> days = [];
    List<String> times = [];
    for (var segment in segments) {
      if (checkDay(segment)) {
        if (times.isEmpty) {
          days.addAll(parseDays(segment));
        } else {
          //append
          for (var day in days) {
            if (tempData.containsKey(day)) {
              tempData[day] = [...?tempData[day], ...times];
            } else {
              tempData[day] = times;
            }
          }
          days = parseDays(segment);
          times = [];
        }
      }
      if (checkTime(segment)) {
        if (segment == "off") {
          times = [];
        } else {
          times.add(segment);
        }
      }
    }

    //commit last times to it days
    for (var day in days) {
      if (tempData.containsKey(day)) {
        tempData[day] = [...?tempData[day], ...times];
      } else {
        tempData[day] = times;
      }
    }

    //apply data to main obj
    for (final key in tempData.keys) {
      openingHours[key] = tempData[key]!;
    }
  }

  List<String> parseDays(String part) {
    part = part.toLowerCase();
    List<String> days = [];
    final softparts = part.split(',');
    for (var part in softparts) {
      int rangecount = (RegExp(r'\-').allMatches(part)).length;
      if (rangecount == 0) {
        days.add(part);
      } else {
        days.addAll(calcDayRange(part));
      }
    }

    return days;
  }

  /// Calculates the days in range "mo-we" -> ["mo", "tu", "we"]
  List<String> calcDayRange(String range) {
    final def = {
      "su": 0,
      "mo": 1,
      "tu": 2,
      "we": 3,
      "th": 4,
      "fr": 5,
      "sa": 6,
    };

    final rangeElements = range.split('-');

    int dayStart = def[rangeElements[0]]!;
    int dayEnd = def[rangeElements[1]]!;

    final numberRange = calcRange(dayStart, dayEnd, 6);
    List<String> outRange = [];
    for (var n in numberRange) {
      for (final key in def.keys) {
        if (def[key] == n) {
          outRange.add(key);
        }
      }
    }
    return outRange;
  }

  /// Creates a range between two number.
  /// if the max value is 6 a range bewteen 6 and 2 is 6, 0, 1, 2
  List<int> calcRange(int min, int max, int maxval) {
    if (min == max) {
      return [min];
    }
    List<int> range = [min];
    int rangepoint = min;
    while (rangepoint < ((min < max) ? max : maxval)) {
      rangepoint++;
      range.add(rangepoint);
    }
    if (min > max) {
      //add from first in list to max value
      range.addAll(calcRange(0, max, maxval));
    }

    return range;
  }

  /// Check if string is time range
  bool checkTime(String inp) {
    //e.g. 09:00+
    if (RegExp(r'[0-9]{1,2}:[0-9]{2}\+').hasMatch(inp)) {
      return true;
    }
    //e.g. 08:00-12:00
    if (RegExp(r'[0-9]{1,2}:[0-9]{2}\-[0-9]{1,2}:[0-9]{2}').hasMatch(inp)) {
      return true;
    }
    //e.g. 17:30 — a single departure
    if (isDeparture(inp)) {
      return true;
    }
    //off
    if (RegExp(r'off').hasMatch(inp)) {
      return true;
    }
    return false;
  }

  /// check if string is day or dayrange
  bool checkDay(String inp) {
    final days = ["mo", "tu", "we", "th", "fr", "sa", "su", "ph"];
    if (RegExp(r'\-').allMatches(inp).isNotEmpty) {
      final rangelements = inp.split('-');
      if (days.contains(rangelements[0]) && days.contains(rangelements[1])) {
        return true;
      }
    } else {
      if (days.contains(inp)) {
        return true;
      }
    }
    return false;
  }

  /// The end of the last service window of the weekday of [date]; null when
  /// that day only has single departures, or nothing at all.
  String? getClosingTimeOfDay(DateTime date) {
    final ranges = rangesOn(date);
    if (ranges.isEmpty) return null;

    // Obtener el último horario del día
    final parts = ranges.last.split('-');

    if (parts.length != 2) return null;

    return formatTimeString(parts[1]);
  }
}
