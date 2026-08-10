import 'package:flutter/material.dart';

/// Formats a clock time the way the user's locale (and device setting)
/// expects — "21:13" for a 24-hour convention, "9:13 PM" for en_US, and
/// so on.
///
/// This replaces the hardcoded `DateFormat('HH:mm')` calls that assumed
/// every rider reads 24-hour time (#945). It goes through
/// [MaterialLocalizations], so it follows the app's locale — including
/// languages served by the fallback delegates (#944) — and honors the
/// device's "use 24-hour format" setting via [MediaQuery].
String formatClockTime(BuildContext context, DateTime time) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay.fromDateTime(time),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
}
