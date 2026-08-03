// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'routing_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class RoutingLocalizationsEn extends RoutingLocalizations {
  RoutingLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get prefsWalkingSpeed => 'Walking speed';

  @override
  String get prefsSpeedSlow => 'Slow';

  @override
  String get prefsSpeedNormal => 'Normal';

  @override
  String get prefsSpeedFast => 'Fast';

  @override
  String get prefsMaxWalkDistance => 'Maximum walking distance';

  @override
  String get prefsNoLimit => 'No limit';

  @override
  String get prefsTransportModes => 'Transport modes';

  @override
  String get prefsModeTransit => 'Transit';

  @override
  String get prefsModeWalk => 'Walk';

  @override
  String get prefsModeBicycle => 'Bicycle';

  @override
  String get prefsWheelchairAccessible => 'Wheelchair accessible';

  @override
  String get prefsWheelchairOn => 'Routes avoid stairs and steep slopes';

  @override
  String get prefsWheelchairOff => 'Include all routes';

  @override
  String serviceActiveClosesAt(String time) {
    return 'Active · closes at $time';
  }

  @override
  String serviceClosedOpensAt(String time) {
    return 'Closed · opens at $time';
  }

  @override
  String serviceClosedOpensDayAt(String day, String time) {
    return 'Closed · opens $day at $time';
  }

  @override
  String get serviceClosed => 'Closed';

  @override
  String get serviceTomorrow => 'tomorrow';

  @override
  String get trufiPlannerLocalDescription =>
      'Runs offline with the GTFS data bundled in the app';

  @override
  String get trufiPlannerRemoteDescription =>
      'Our own routing engine served from our backend';

  @override
  String get trufiPlannerInfoTitle => 'About Trufi Planner';

  @override
  String get trufiPlannerInfoIntro =>
      'Trufi Planner is our own routing engine (not OTP).';

  @override
  String get trufiPlannerInfoLocalBody =>
      'On mobile it runs 100% offline, using the GTFS data bundled with the app — results may differ from online engines.';

  @override
  String get trufiPlannerInfoRemoteBody =>
      'This web version queries our server; results may differ from OTP because it uses a different algorithm and data.';

  @override
  String otpOnlineDescription(String version) {
    return 'OpenTripPlanner $version (Online)';
  }
}
