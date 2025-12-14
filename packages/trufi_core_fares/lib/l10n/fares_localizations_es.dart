import 'fares_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish (`es`).
class FaresLocalizationsEs extends FaresLocalizations {
  FaresLocalizationsEs([super.locale = 'es']);

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
  String faresLastUpdated(String date) => 'Última actualización: $date';

  @override
  String get faresMoreInfo => 'Más Información';
}
