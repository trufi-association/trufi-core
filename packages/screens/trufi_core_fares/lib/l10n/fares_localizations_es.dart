// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fares_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FaresLocalizationsEs extends FaresLocalizations {
  FaresLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get menuFares => 'Tarifas';

  @override
  String get faresTitle => 'Información de Tarifas';

  @override
  String get faresSubtitle => 'Precios actuales del transporte público';

  @override
  String get faresRegular => 'Regular';

  @override
  String get faresStudent => 'Estudiante';

  @override
  String get faresSenior => 'Adulto Mayor';

  @override
  String faresLastUpdated(String date) {
    return 'Última actualización: $date';
  }

  @override
  String get faresMoreInfo => 'Más Información';
}
