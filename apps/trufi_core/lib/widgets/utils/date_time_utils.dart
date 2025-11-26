abstract class DateTimeUtils {
  static String durationToStringTime(Duration duration) {
    final minutes = "${duration.inMinutes.remainder(60)} min";

    if (duration.inHours >= 1) {
      final hours = "${duration.inHours + duration.inDays * 24} h";
      return '$hours $minutes';
    }

    if (duration.inMinutes < 1) {
      return '< 1 min';
    }

    return minutes;
  }

  static String durationToStringMinutes(Duration duration) {
    return duration.inMinutes.toString();
  }
}
