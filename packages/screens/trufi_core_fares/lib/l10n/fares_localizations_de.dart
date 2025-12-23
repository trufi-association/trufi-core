// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fares_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FaresLocalizationsDe extends FaresLocalizations {
  FaresLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menuFares => 'Tarife';

  @override
  String get faresTitle => 'Tarifinformationen';

  @override
  String get faresSubtitle => 'Aktuelle Preise für den öffentlichen Nahverkehr';

  @override
  String get faresRegular => 'Normal';

  @override
  String get faresStudent => 'Schüler/Student';

  @override
  String get faresSenior => 'Senior';

  @override
  String faresLastUpdated(String date) {
    return 'Zuletzt aktualisiert: $date';
  }

  @override
  String get faresMoreInfo => 'Weitere Informationen';
}
