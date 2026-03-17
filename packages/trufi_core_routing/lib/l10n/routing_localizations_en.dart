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
}
