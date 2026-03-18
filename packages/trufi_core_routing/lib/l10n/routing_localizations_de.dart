// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'routing_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class RoutingLocalizationsDe extends RoutingLocalizations {
  RoutingLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get prefsWalkingSpeed => 'Gehgeschwindigkeit';

  @override
  String get prefsSpeedSlow => 'Langsam';

  @override
  String get prefsSpeedNormal => 'Normal';

  @override
  String get prefsSpeedFast => 'Schnell';

  @override
  String get prefsMaxWalkDistance => 'Maximale Gehentfernung';

  @override
  String get prefsNoLimit => 'Kein Limit';

  @override
  String get prefsTransportModes => 'Verkehrsmittel';

  @override
  String get prefsModeTransit => 'ÖPNV';

  @override
  String get prefsModeWalk => 'Zu Fuß';

  @override
  String get prefsModeBicycle => 'Fahrrad';

  @override
  String get prefsWheelchairAccessible => 'Rollstuhlgerecht';

  @override
  String get prefsWheelchairOn => 'Routen vermeiden Treppen und steile Hänge';

  @override
  String get prefsWheelchairOff => 'Alle Routen einschließen';
}
