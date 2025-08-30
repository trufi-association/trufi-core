import 'package:trufi_core/base/translations/trufi_base_localizations.dart';

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

  /// Returns if the OpeningHours match on given Date
  bool isOpenOn(DateTime date) {
    int testday = date.weekday - 1;
    List<String> times = [];
    times = openingHours.values.toList()[testday];
    bool isOpen = false;
    for (var time in times) {
      //TODO: times like 09:00+ are not supported here
      final timedata = time.split('-');
      if (timedata.length > 1) {
        final timeStart = formatTimeString(timedata[0]);
        final timeEnd = formatTimeString(timedata[1]);
        DateTime openTime = DateTime.parse("2016-01-01 $timeStart:00");
        DateTime closeTime = DateTime.parse("2016-01-01 $timeEnd:00");
        DateTime currentDateTime =
            DateTime.parse("2016-01-01 ${durationToString(date)}");
        bool isDiferentDay = openTime.isAfter(closeTime);

        if (isDiferentDay) {
          closeTime = DateTime.parse("2016-01-02 $timeEnd:00");
        }
        bool isAdte = isDiferentDay
            ? currentDateTime.isAfter(openTime) ||
                currentDateTime
                    .isBefore(DateTime.parse("2016-01-01 $timeEnd:00"))
            : currentDateTime.isAfter(openTime);
        isOpen = isAdte && currentDateTime.isBefore(closeTime);
      }
    }
    return isOpen;
  }

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

  String? getClosingTimeOfDay(DateTime date) {
    int weekdayIndex = date.weekday - 1; // DateTime.weekday: 1=Monday → 0-based
    final keys = ["mo", "tu", "we", "th", "fr", "sa", "su"];
    final key = keys[weekdayIndex];

    final times = openingHours[key];
    if (times != null && times.isEmpty) return null;

    // Obtener el último horario del día
    final lastTimeRange = times!.last;
    final parts = lastTimeRange.split('-');

    if (parts.length != 2) return null;

    return formatTimeString(parts[1]);
  }
}
