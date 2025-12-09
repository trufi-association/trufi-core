// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SearchLocalizationsEn extends SearchLocalizations {
  SearchLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchTitle => 'Search Location';

  @override
  String get searchOrigin => 'Origin';

  @override
  String get searchDestination => 'Destination';

  @override
  String get searchMyLocation => 'My Location';

  @override
  String get searchChooseOnMap => 'Choose on map';

  @override
  String get searchSwap => 'Swap';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get searchSearching => 'Searching...';
}
