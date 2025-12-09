// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SearchLocalizationsDe extends SearchLocalizations {
  SearchLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get searchTitle => 'Ort suchen';

  @override
  String get searchOrigin => 'Start';

  @override
  String get searchDestination => 'Ziel';

  @override
  String get searchMyLocation => 'Mein Standort';

  @override
  String get searchChooseOnMap => 'Auf Karte wählen';

  @override
  String get searchSwap => 'Tauschen';

  @override
  String get searchNoResults => 'Keine Ergebnisse gefunden';

  @override
  String get searchSearching => 'Suche...';
}
