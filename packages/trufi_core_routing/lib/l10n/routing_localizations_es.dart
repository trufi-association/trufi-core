// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'routing_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class RoutingLocalizationsEs extends RoutingLocalizations {
  RoutingLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get prefsWalkingSpeed => 'Velocidad de caminata';

  @override
  String get prefsSpeedSlow => 'Lento';

  @override
  String get prefsSpeedNormal => 'Normal';

  @override
  String get prefsSpeedFast => 'Rápido';

  @override
  String get prefsMaxWalkDistance => 'Distancia máxima de caminata';

  @override
  String get prefsNoLimit => 'Sin límite';

  @override
  String get prefsTransportModes => 'Modos de transporte';

  @override
  String get prefsModeTransit => 'Tránsito';

  @override
  String get prefsModeWalk => 'A pie';

  @override
  String get prefsModeBicycle => 'Bicicleta';

  @override
  String get prefsWheelchairAccessible => 'Accesible en silla de ruedas';

  @override
  String get prefsWheelchairOn =>
      'Las rutas evitan escaleras y pendientes pronunciadas';

  @override
  String get prefsWheelchairOff => 'Incluir todas las rutas';
}
