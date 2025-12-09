// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class HomeLocalizationsDe extends HomeLocalizations {
  HomeLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get homeTitle => 'Willkommen bei Trufi';

  @override
  String get homeSubtitle => 'Ihre Reise beginnt hier';

  @override
  String get homeSearchPlaceholder => 'Wohin möchten Sie?';

  @override
  String get homeQuickActions => 'Schnellaktionen';

  @override
  String get homeFavorites => 'Favoriten';

  @override
  String get homePocFeatures => 'POC-Funktionen';
}
