import 'fares_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FaresLocalizationsEn extends FaresLocalizations {
  FaresLocalizationsEn([super.locale = 'en']);

  @override
  String get menuFares => 'Fares';

  @override
  String get faresTitle => 'Fare Information';

  @override
  String get faresSubtitle => 'Current prices for public transportation';

  @override
  String get faresRegular => 'Regular';

  @override
  String get faresStudent => 'Student';

  @override
  String get faresSenior => 'Senior';

  @override
  String faresLastUpdated(String date) => 'Last updated: $date';

  @override
  String get faresMoreInfo => 'More Information';
}
